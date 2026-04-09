import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/services/sync_service.dart';

class SurveyScreen extends StatefulWidget {
  final String surveyCode;
  const SurveyScreen({super.key, required this.surveyCode});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  bool _isLoading = true;
  String? _surveyId;
  String? _orgId;
  String _surveyTitle = '';
  List<dynamic> _fields = [];
  final Map<String, dynamic> _answers = {};
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchSchemaAndLocation();
  }

  Future<void> _fetchSchemaAndLocation() async {
    // 1. Fetch GPS silently
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
          debugPrint('Location services are disabled.');
      } else {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
              _currentPosition = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.best);
          }
      }
    } catch(e) {
      debugPrint("Error fetching GPS: $e");
    }

    // 2. Try Firestore, fallback to Hive
    try {
      final dynamic connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult is List
          ? !connectivityResult.contains(ConnectivityResult.none)
          : connectivityResult != ConnectivityResult.none;
      
      final box = Hive.box('surveys');

      if (isOnline) {
         final query = await FirebaseFirestore.instance
           .collection('surveys')
           .where('surveyCode', isEqualTo: widget.surveyCode)
           .limit(1).get();
           
         if (query.docs.isNotEmpty) {
            final doc = query.docs.first;
            final data = doc.data();
            
            // Save schema to hive for offline
            await box.put(widget.surveyCode, data);
            
            _surveyId = doc.id;
            _orgId = data['orgId'];
            _surveyTitle = data['title'] ?? 'Survey';
            _fields = data['fields'] ?? [];
         }
      } else {
         // Offline mode: Fetch from Hive
         final offlineData = box.get(widget.surveyCode);
         if (offlineData != null) {
            _surveyId = 'offline_survey_id'; // We don't have document id in plain Hive typically unless stored
            _orgId = offlineData['orgId'];
            _surveyTitle = offlineData['title'] ?? 'Survey';
            _fields = offlineData['fields'] ?? [];
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Offline Mode: Loaded from Cache'))
            );
         }
      }
    } catch (e) {
      debugPrint("Error fetching survey: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submit() async {
     // Validation
     for (var f in _fields) {
        if (f['required'] == true && (_answers[f['id']] == null || _answers[f['id']] == '')) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${f['label']} is required.')));
           return;
        }
     }

     setState(() => _isLoading = true);
     
     final submissionData = {
        'surveyId': _surveyId,
        'orgId': _orgId,
        'volunteerId': 'local_user_v1', // Mocked user
        'answers': _answers.entries.map((e) => {'fieldId': e.key, 'value': e.value}).toList(),
        'location': _currentPosition != null 
             ? {'lat': _currentPosition!.latitude, 'lng': _currentPosition!.longitude}
             : null,
        'submittedAt': DateTime.now().toIso8601String()
     };

     final dynamic connectivityResult = await Connectivity().checkConnectivity();
     final isOnline = connectivityResult is List
         ? !connectivityResult.contains(ConnectivityResult.none)
         : connectivityResult != ConnectivityResult.none;

     if (isOnline) {
         submissionData['syncedAt'] = FieldValue.serverTimestamp();
         submissionData['status'] = 'pending';
         await FirebaseFirestore.instance.collection('responses').add(submissionData);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Server')));
     } else {
         // Offline logic
         await SyncService().saveResponseOffline(submissionData);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
           content: Text('Saved Offline. It will sync automatically when online.'),
           backgroundColor: Colors.orange,
         ));
     }
     
     if (mounted) Navigator.pop(context);
  }

  // Dynamic Widget Renderer
  Widget _buildField(dynamic field) {
    switch (field['type']) {
      case 'text':
      case 'number':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            keyboardType: field['type'] == 'number' ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              labelText: field['label'],
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) => _answers[field['id']] = val,
          ),
        );
      case 'dropdown':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: field['label'],
               filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
            ),
            items: (field['options'] as List<dynamic>? ?? []).map((opt) => 
               DropdownMenuItem<String>(value: opt.toString(), child: Text(opt.toString()))
            ).toList(),
            onChanged: (val) => _answers[field['id']] = val,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_fields.isEmpty) {
       return Scaffold(
         appBar: AppBar(title: const Text('Error')),
         body: const Center(child: Text('Survey not found or device offline without cache.')),
       );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_surveyTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
             if (_currentPosition != null)
               Container(
                 margin: const EdgeInsets.only(bottom: 24),
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                 child: Row(
                   children: [
                      const Icon(Icons.gps_fixed, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('GPS Acquired: ${_currentPosition!.latitude.toStringAsFixed(3)}, ${_currentPosition!.longitude.toStringAsFixed(3)}')
                   ],
                 ),
               )
             else
                Container(
                 margin: const EdgeInsets.only(bottom: 24),
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12)),
                 child: Row(
                   children: [
                      const Icon(Icons.gps_off, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text('GPS Unknown. Map functionality restricted.')
                   ],
                 ),
               ),

             ..._fields.map((f) => _buildField(f)),
             
             const SizedBox(height: 32),
             SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Submit Response', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
             )
          ],
        )
      ),
    );
  }
}
