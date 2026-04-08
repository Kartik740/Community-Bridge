// lib/providers/auth_provider.dart
// Manages Firebase Auth state, volunteer profile, and routing logic.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/services/firebase_service.dart';
import '../core/services/hive_service.dart';
import '../core/services/notification_service.dart';
import '../models/volunteer_model.dart';
import '../models/volunteer_request_model.dart';

enum AuthStatus {
  loading,
  unauthenticated,
  pendingApproval,
  rejected,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;

  AuthStatus _status = AuthStatus.loading;
  VolunteerModel? _volunteer;
  VolunteerRequestModel? _request;
  String? _error;

  AuthStatus get status => _status;
  VolunteerModel? get volunteer => _volunteer;
  VolunteerRequestModel? get request => _request;
  String? get error => _error;
  User? get firebaseUser => _auth.currentUser;

  AuthProvider() {
    _init();
  }

  // ─── Initialisation ────────────────────────────────────────────────────────

  Future<void> _init() async {
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        _volunteer = null;
        notifyListeners();
        return;
      }
      await _resolveStatus(user.uid);
    });
  }

  /// Determines routing status based on Firestore documents.
  Future<void> _resolveStatus(String uid) async {
    _status = AuthStatus.loading;
    notifyListeners();

    // Check if approved volunteer document exists
    final volData = await FirebaseService.getVolunteer(uid);
    if (volData != null) {
      _volunteer = VolunteerModel.fromJson(volData);
      HiveService.saveProfile(_volunteer!.toJson());
      _status = AuthStatus.authenticated;
      // Save FCM token
      await NotificationService.saveToken(uid);
      notifyListeners();
      return;
    }

    // Check volunteer request for status
    final reqData = await FirebaseService.getVolunteerRequest(uid);
    if (reqData != null) {
      _request = VolunteerRequestModel.fromJson(reqData);
      if (_request!.status == 'approved') {
        // Edge case: request approved but volunteer doc not yet created
        _status = AuthStatus.pendingApproval;
      } else if (_request!.status == 'rejected') {
        _status = AuthStatus.rejected;
      } else {
        _status = AuthStatus.pendingApproval;
      }
      notifyListeners();
      return;
    }

    // No documents found — unauthenticated
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Login ─────────────────────────────────────────────────────────────────

  /// Signs in with email and password.
  Future<bool> login(String email, String password) async {
    _error = null;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // _init listener will call _resolveStatus automatically
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authErrorMessage(e.code);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Login failed. Check your connection.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ─── Register ──────────────────────────────────────────────────────────────

  /// Creates Firebase Auth account and submits a volunteer request.
  Future<bool> register(VolunteerRequestModel requestData, String password) async {
    _error = null;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: requestData.email.trim(),
        password: password.trim(),
      );

      final uid = cred.user!.uid;

      // Create volunteer request document (NOT the volunteer doc — that happens on approval)
      await FirebaseService.volunteerRequests
          .doc(uid)
          .set(requestData.copyWithId(uid).toFirestore());

      _request = requestData.copyWithId(uid);
      _status = AuthStatus.pendingApproval;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authErrorMessage(e.code);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _auth.signOut();
    await HiveService.clearProfile();
    _volunteer = null;
    _request = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Re-apply to different NGO ─────────────────────────────────────────────

  /// Updates the volunteer request to point to a different NGO.
  Future<bool> reapply(String newOrgId, String newOrgName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      await FirebaseService.volunteerRequests.doc(uid).set({
        ..._request!.toFirestore(),
        'orgId': newOrgId,
        'orgName': newOrgName,
        'status': 'pending',
        'rejectionReason': null,
        'appliedAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
      });

      _request = VolunteerRequestModel.fromJson({
        ..._request!.toJson(),
        'orgId': newOrgId,
        'orgName': newOrgName,
        'status': 'pending',
        'rejectionReason': null,
      });
      _status = AuthStatus.pendingApproval;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AuthProvider] reapply error: $e');
      return false;
    }
  }

  // ─── Profile Update ────────────────────────────────────────────────────────

  /// Refreshes the in-memory volunteer profile from Firestore.
  Future<void> refreshProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final data = await FirebaseService.getVolunteer(uid);
    if (data != null) {
      _volunteer = VolunteerModel.fromJson(data);
      HiveService.saveProfile(_volunteer!.toJson());
      notifyListeners();
    }
  }

  /// Updates the volunteer's availability.
  Future<void> setAvailability(bool available) async {
    if (_volunteer == null) return;
    final ok = await FirebaseService.updateVolunteer(
      _volunteer!.id,
      {'availability': available},
    );
    if (ok) {
      _volunteer = _volunteer!.copyWith(availability: available);
      notifyListeners();
    }
  }

  /// Updates the volunteer's GPS location.
  Future<void> updateLocation(double lat, double lng) async {
    if (_volunteer == null) return;
    await FirebaseService.updateVolunteer(_volunteer!.id, {
      'location': {'lat': lat, 'lng': lng},
    });
    _volunteer = _volunteer!.copyWith(lat: lat, lng: lng);
    notifyListeners();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}

extension on VolunteerRequestModel {
  VolunteerRequestModel copyWithId(String uid) {
    return VolunteerRequestModel(
      id: uid,
      volunteerId: uid,
      name: name,
      age: age,
      city: city,
      email: email,
      phone: phone,
      skills: skills,
      availabilityTime: availabilityTime,
      motivation: motivation,
      orgId: orgId,
      orgName: orgName,
      status: status,
      rejectionReason: rejectionReason,
    );
  }
}
