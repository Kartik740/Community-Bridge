// lib/providers/response_provider.dart
// Handles survey response submission — online direct or offline Hive save.

import 'package:flutter/foundation.dart';
import '../core/services/firebase_service.dart';
import '../core/services/sync_service.dart';
import '../core/utils/connectivity_helper.dart';
import '../models/response_model.dart';

enum SubmitState { idle, submitting, success, savedOffline, error }

class ResponseProvider extends ChangeNotifier {
  SubmitState _state = SubmitState.idle;
  String? _errorMessage;
  String? _responseId;

  SubmitState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get responseId => _responseId;

  /// Submits a response — online writes to Firestore, offline saves to Hive.
  Future<bool> submit(ResponseModel response) async {
    _state = SubmitState.submitting;
    _errorMessage = null;
    notifyListeners();

    final isOnline = await ConnectivityHelper.isOnline();

    if (isOnline) {
      return _submitOnline(response);
    } else {
      return _saveOffline(response);
    }
  }

  Future<bool> _submitOnline(ResponseModel response) async {
    try {
      final id = await FirebaseService.submitResponse(response.toFirestore());
      if (id == null) throw Exception('Firestore write failed');
      _responseId = id;
      _state = SubmitState.success;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[ResponseProvider] _submitOnline error: $e');
      _errorMessage = 'Failed to submit. Please try again.';
      _state = SubmitState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _saveOffline(ResponseModel response) async {
    try {
      await SyncService().saveResponseOffline(response.toJson());
      _state = SubmitState.savedOffline;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[ResponseProvider] _saveOffline error: $e');
      _errorMessage = 'Failed to save offline.';
      _state = SubmitState.error;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _state = SubmitState.idle;
    _errorMessage = null;
    _responseId = null;
    notifyListeners();
  }
}
