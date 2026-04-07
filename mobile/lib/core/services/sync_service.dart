import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final Connectivity _connectivity = Connectivity();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void initConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final isOnline = !results.contains(ConnectivityResult.none);
      if (isOnline) {
        _syncPendingResponses();
      }
    });
  }

  Future<void> _syncPendingResponses() async {
    try {
      final box = Hive.box('responses_sync');
      final pendingKeys = box.keys.toList();

      if (pendingKeys.isEmpty) return;

      debugPrint('Syncing ${pendingKeys.length} pending responses to Firestore...');

      final batch = _firestore.batch();
      final collection = _firestore.collection('responses');

      for (var key in pendingKeys) {
        final data = Map<String, dynamic>.from(box.get(key));
        
        // Ensure data is ready for upload
        data['syncedAt'] = FieldValue.serverTimestamp();
        data['status'] = 'pending'; // Requires admin review
        
        final docRef = collection.doc();
        batch.set(docRef, data);
      }

      await batch.commit();

      // Clear synced items
      await box.deleteAll(pendingKeys);
      debugPrint('Sync complete!');

    } catch (e) {
      debugPrint('Error syncing to Firestore: $e');
    }
  }

  Future<void> saveResponseOffline(Map<String, dynamic> responseData) async {
    final box = Hive.box('responses_sync');
    await box.add(responseData);
  }
}
