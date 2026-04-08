// lib/core/services/sync_service.dart
// Full sync engine — syncs pending offline responses to Firestore.
// Listens to connectivity changes and auto-syncs on reconnection.
// Exposes a ChangeNotifier for progress updates on the UI.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'hive_service.dart';

class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  bool _isSyncing = false;
  int _pendingCount = 0;
  String? _lastSyncMessage;

  bool get isSyncing => _isSyncing;
  int get pendingCount => _pendingCount;
  String? get lastSyncMessage => _lastSyncMessage;

  // ─── Connectivity Listener ─────────────────────────────────────────────────

  /// Must be called after app start. Automatically syncs on reconnection.
  void initConnectivityListener() {
    _refreshPendingCount();
    Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = !results.contains(ConnectivityResult.none);
      if (isOnline) {
        debugPrint('[SyncService] Connection restored — attempting sync...');
        attemptSync();
      }
    });
  }

  // ─── Sync Logic ────────────────────────────────────────────────────────────

  /// Syncs all pending offline responses to Firestore.
  /// Safe to call multiple times — no-ops if already syncing or offline.
  Future<void> attemptSync() async {
    if (_isSyncing) return;

    final pending = HiveService.getPendingResponses();
    if (pending.isEmpty) {
      _refreshPendingCount();
      return;
    }

    _isSyncing = true;
    _lastSyncMessage = null;
    notifyListeners();

    int successCount = 0;

    for (final entry in pending) {
      try {
        final data = Map<String, dynamic>.from(entry.value);
        data['syncedAt'] = FieldValue.serverTimestamp();

        final ref = await FirebaseFirestore.instance
            .collection('responses')
            .add(data);

        await HiveService.removePendingResponse(entry.key);
        await HiveService.markSynced(ref.id);
        successCount++;
      } catch (e) {
        debugPrint('[SyncService] Failed to sync entry ${entry.key}: $e');
        // Keep in Hive, try again next time
      }
    }

    _isSyncing = false;

    if (successCount > 0) {
      _lastSyncMessage =
          '$successCount response${successCount == 1 ? '' : 's'} synced successfully';
    }

    _refreshPendingCount();
    notifyListeners();
  }

  // ─── Offline Save ──────────────────────────────────────────────────────────

  /// Saves a response locally when offline.
  Future<void> saveResponseOffline(Map<String, dynamic> data) async {
    await HiveService.savePendingResponse(data);
    _refreshPendingCount();
    notifyListeners();
  }

  // ─── Internal ──────────────────────────────────────────────────────────────

  void _refreshPendingCount() {
    _pendingCount = HiveService.pendingCount;
  }
}
