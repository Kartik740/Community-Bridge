// lib/core/services/firebase_service.dart
// Centralised Firestore helpers used across providers.
// Wraps all calls in try/catch with meaningful error messages.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseService._();

  static final _db = FirebaseFirestore.instance;

  // ─── Collections ──────────────────────────────────────────────────────────

  static CollectionReference get organisations => _db.collection('organisations');
  static CollectionReference get surveys => _db.collection('surveys');
  static CollectionReference get responses => _db.collection('responses');
  static CollectionReference get volunteers => _db.collection('volunteers');
  static CollectionReference get volunteerRequests => _db.collection('volunteerRequests');
  static CollectionReference get tasks => _db.collection('tasks');

  // ─── Survey Helpers ────────────────────────────────────────────────────────

  /// Fetches a survey by its unique surveyCode.
  /// Returns null if not found or on error.
  static Future<Map<String, dynamic>?> getSurveyByCode(String code) async {
    try {
      final q = await surveys
          .where('surveyCode', isEqualTo: code.toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      if (q.docs.isEmpty) return null;
      return {'id': q.docs.first.id, ...q.docs.first.data() as Map<String, dynamic>};
    } catch (e) {
      debugPrint('[FirebaseService] getSurveyByCode error: $e');
      return null;
    }
  }

  // ─── Volunteer Helpers ─────────────────────────────────────────────────────

  /// Returns the volunteer document for the given UID, or null.
  static Future<Map<String, dynamic>?> getVolunteer(String uid) async {
    try {
      final doc = await volunteers.doc(uid).get();
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    } catch (e) {
      debugPrint('[FirebaseService] getVolunteer error: $e');
      return null;
    }
  }

  /// Returns the volunteer request document for the given UID, or null.
  static Future<Map<String, dynamic>?> getVolunteerRequest(String uid) async {
    try {
      final doc = await volunteerRequests.doc(uid).get();
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    } catch (e) {
      debugPrint('[FirebaseService] getVolunteerRequest error: $e');
      return null;
    }
  }

  /// Streams the volunteer request document in real time for status changes.
  static Stream<DocumentSnapshot> streamVolunteerRequest(String uid) {
    return volunteerRequests.doc(uid).snapshots();
  }

  // ─── Organisations ──────────────────────────────────────────────────────────

  /// Fetches all NGOs for the selection list in register step 3.
  /// Throws on error so callers can show a meaningful message.
  static Future<List<Map<String, dynamic>>> getAllOrganisations() async {
    final snap = await organisations.get();
    return snap.docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList();
  }

  // ─── Response Helpers ──────────────────────────────────────────────────────

  /// Writes a response directly to Firestore.
  static Future<String?> submitResponse(Map<String, dynamic> data) async {
    try {
      final ref = await responses.add({
        ...data,
        'syncedAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      debugPrint('[FirebaseService] submitResponse error: $e');
      return null;
    }
  }

  // ─── Task Helpers ──────────────────────────────────────────────────────────

  /// Returns a real-time stream of tasks assigned to the given volunteer.
  static Stream<QuerySnapshot> streamTasks(String volunteerId) {
    return tasks
        .where('assignedVolunteerId', isEqualTo: volunteerId)
        // Sort locally in TaskProvider to avoid requiring a composite index
        .snapshots();
  }

  /// Updates a task's status field.
  static Future<bool> updateTaskStatus(String taskId, String status) async {
    try {
      await tasks.doc(taskId).update({
        'status': status,
        if (status == 'completed') 'completedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('[FirebaseService] updateTaskStatus error: $e');
      return false;
    }
  }

  // ─── Volunteer Profile ─────────────────────────────────────────────────────

  /// Updates specific fields on a volunteer document.
  static Future<bool> updateVolunteer(
      String uid, Map<String, dynamic> data) async {
    try {
      await volunteers.doc(uid).update(data);
      return true;
    } catch (e) {
      debugPrint('[FirebaseService] updateVolunteer error: $e');
      return false;
    }
  }
}
