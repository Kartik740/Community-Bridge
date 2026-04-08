// lib/providers/survey_provider.dart
// Handles survey search by code — online Firestore first, offline Hive fallback.

import 'package:flutter/foundation.dart';
import '../core/services/firebase_service.dart';
import '../core/services/hive_service.dart';
import '../core/utils/connectivity_helper.dart';
import '../models/survey_model.dart';

enum SurveySearchState { idle, loading, found, notFound, error, offlineMiss }

class SurveyProvider extends ChangeNotifier {
  SurveySearchState _state = SurveySearchState.idle;
  SurveyModel? _currentSurvey;
  bool _isOfflineMode = false;
  String? _errorMessage;

  SurveySearchState get state => _state;
  SurveyModel? get currentSurvey => _currentSurvey;
  bool get isOfflineMode => _isOfflineMode;
  String? get errorMessage => _errorMessage;

  List<SurveyModel> get recentSurveys {
    return HiveService.getRecentSurveys()
        .map((m) => SurveyModel.fromJson(m))
        .toList();
  }

  /// Searches for a survey by its code.
  /// Online: queries Firestore and caches result.
  /// Offline: reads from Hive cache.
  Future<SurveyModel?> searchByCode(String code) async {
    _state = SurveySearchState.loading;
    _errorMessage = null;
    _currentSurvey = null;
    notifyListeners();

    final isOnline = await ConnectivityHelper.isOnline();

    if (isOnline) {
      return _fetchOnline(code);
    } else {
      return _fetchOffline(code);
    }
  }

  Future<SurveyModel?> _fetchOnline(String code) async {
    try {
      final data = await FirebaseService.getSurveyByCode(code);
      if (data == null) {
        _state = SurveySearchState.notFound;
        _errorMessage =
            'Survey not found. Check the code and try again.';
        notifyListeners();
        return null;
      }

      final survey = SurveyModel.fromJson(data);
      // Cache for offline use
      await HiveService.cacheSurvey(code, survey.toJson());

      _currentSurvey = survey;
      _isOfflineMode = false;
      _state = SurveySearchState.found;
      notifyListeners();
      return survey;
    } catch (e) {
      debugPrint('[SurveyProvider] _fetchOnline error: $e');
      _state = SurveySearchState.error;
      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return null;
    }
  }

  Future<SurveyModel?> _fetchOffline(String code) async {
    final cached = HiveService.getCachedSurvey(code);
    if (cached == null) {
      _state = SurveySearchState.offlineMiss;
      _errorMessage =
          'You are offline. This survey is not cached on your device.';
      notifyListeners();
      return null;
    }

    final survey = SurveyModel.fromJson(cached);
    _currentSurvey = survey;
    _isOfflineMode = true;
    _state = SurveySearchState.found;
    notifyListeners();
    return survey;
  }

  void reset() {
    _state = SurveySearchState.idle;
    _currentSurvey = null;
    _errorMessage = null;
    notifyListeners();
  }
}
