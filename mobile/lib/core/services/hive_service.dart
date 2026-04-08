// lib/core/services/hive_service.dart
// Opens and exposes all Hive boxes used for offline storage.

import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  HiveService._();

  // Box name constants
  static const String pendingResponsesBox = 'pendingResponses';
  static const String cachedSurveysBox = 'cachedSurveys';
  static const String volunteerProfileBox = 'volunteerProfile';
  static const String syncedResponseIdsBox = 'syncedResponseIds';

  /// Initialises Hive and opens all required boxes.
  /// Must be called before runApp().
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(pendingResponsesBox);
    await Hive.openBox<Map>(cachedSurveysBox);
    await Hive.openBox(volunteerProfileBox);
    await Hive.openBox<String>(syncedResponseIdsBox);
  }

  // ─── Pending Responses ─────────────────────────────────────────────────────

  static Box<Map> get _pendingBox => Hive.box<Map>(pendingResponsesBox);

  /// Saves a response locally for later sync.
  static Future<void> savePendingResponse(Map<String, dynamic> data) async {
    await _pendingBox.add(Map<String, dynamic>.from(data));
  }

  /// Returns all pending responses as a list with their Hive keys.
  static List<MapEntry<dynamic, Map>> getPendingResponses() {
    return _pendingBox.toMap().entries.toList();
  }

  /// Removes a synced response by its Hive key.
  static Future<void> removePendingResponse(dynamic key) async {
    await _pendingBox.delete(key);
  }

  /// Returns number of pending responses.
  static int get pendingCount => _pendingBox.length;

  // ─── Cached Surveys ────────────────────────────────────────────────────────

  static Box<Map> get _surveysBox => Hive.box<Map>(cachedSurveysBox);

  /// Caches a survey schema keyed by surveyCode.
  static Future<void> cacheSurvey(String code, Map<String, dynamic> data) async {
    await _surveysBox.put(code, Map<String, dynamic>.from(data));
  }

  /// Returns a cached survey by code, or null.
  static Map<String, dynamic>? getCachedSurvey(String code) {
    final val = _surveysBox.get(code);
    if (val == null) return null;
    return Map<String, dynamic>.from(val);
  }

  /// Returns the last 3 cached surveys (for recently used section).
  static List<Map<String, dynamic>> getRecentSurveys() {
    return _surveysBox.values
        .take(3)
        .map((m) => Map<String, dynamic>.from(m))
        .toList()
        .reversed
        .toList();
  }

  // ─── Volunteer Profile ─────────────────────────────────────────────────────

  static Box get _profileBox => Hive.box(volunteerProfileBox);

  /// Saves the volunteer profile for offline access.
  static Future<void> saveProfile(Map<String, dynamic> data) async {
    await _profileBox.put('profile', data);
  }

  /// Returns the cached volunteer profile, or null.
  static Map<String, dynamic>? getProfile() {
    final val = _profileBox.get('profile');
    if (val == null) return null;
    return Map<String, dynamic>.from(val as Map);
  }

  /// Clears the cached volunteer profile (on logout).
  static Future<void> clearProfile() async {
    await _profileBox.clear();
  }

  // ─── Synced Response IDs ────────────────────────────────────────────────────

  static Box<String> get _syncedBox => Hive.box<String>(syncedResponseIdsBox);

  /// Marks a response ID as synced.
  static Future<void> markSynced(String id) async {
    await _syncedBox.add(id);
  }

  /// Returns all synced response IDs.
  static List<String> getSyncedIds() => _syncedBox.values.toList();
}
