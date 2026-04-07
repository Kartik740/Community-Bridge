import 'package:flutter/material.dart';
import '../survey/survey_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _codeCtrl = TextEditingController();

  void _fetchSurvey() {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please enter a valid 6-character code'))
       );
       return;
    }
    // Navigate to SurveyScreen passing the code
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurveyScreen(surveyCode: code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter Survey Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Enter the 6-digit code provided by your NGO organiser to fetch the form structure.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            TextField(
              controller: _codeCtrl,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, trackingSpacing: 8),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                hintText: 'XXXXXX',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _fetchSurvey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Fetch Survey', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
