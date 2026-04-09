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
  // Guards against the authStateChanges listener clobbering a pending
  // in-progress login/register operation.
  bool _resolvingManually = false;

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
      // Skip if login/register is resolving status manually to avoid race.
      if (_resolvingManually) return;
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
    _resolvingManually = true;
    notifyListeners();

    String? resolvedUid;
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      resolvedUid = cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthProvider] Login FirebaseAuthException: ${e.code}');
      _error = _authErrorMessage(e.code);
      _status = AuthStatus.unauthenticated;
      _resolvingManually = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('[AuthProvider] Login raw error: $e');
      // firebase_auth v4.x has a Pigeon deserialization bug on some Android
      // emulators where the result codec fails AFTER the user is signed in.
      // _auth.currentUser is already populated in that case — recover from it.
      final currentUser = _auth.currentUser;
      if (currentUser != null && e.toString().contains('PigeonUserDetails')) {
        debugPrint('[AuthProvider] Pigeon bug detected, recovering with currentUser uid=${currentUser.uid}');
        resolvedUid = currentUser.uid;
      } else {
        _error = 'Login failed. Check your connection.';
        _status = AuthStatus.unauthenticated;
        _resolvingManually = false;
        notifyListeners();
        return false;
      }
    }

    // Resolve Firestore status for this user
    await _resolveStatus(resolvedUid!);
    _resolvingManually = false;

    // If no Firestore document was found, the auth account exists but the
    // application profile does not (orphaned account).
    if (_status == AuthStatus.unauthenticated) {
      _error = 'No volunteer profile found. Please complete registration first.';
      notifyListeners();
      return false;
    }

    return true;
  }

  // ─── Register ──────────────────────────────────────────────────────────────

  /// Creates Firebase Auth account and submits a volunteer request.
  Future<bool> register(VolunteerRequestModel requestData, String password) async {
    _error = null;
    _status = AuthStatus.loading;
    _resolvingManually = true;
    notifyListeners();

    String? createdUid;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: requestData.email.trim(),
        password: password.trim(),
      );
      createdUid = cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthProvider] FirebaseAuthException: ${e.code} — ${e.message}');
      _error = _authErrorMessage(e.code);
      _status = AuthStatus.unauthenticated;
      _resolvingManually = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('[AuthProvider] createUser raw error: $e');
      // firebase_auth v4.x Pigeon bug: user IS created but response codec
      // throws a type cast error.  _auth.currentUser is already set.
      final currentUser = _auth.currentUser;
      if (currentUser != null && e.toString().contains('PigeonUserDetails')) {
        debugPrint('[AuthProvider] Pigeon bug detected, recovering with currentUser uid=${currentUser.uid}');
        createdUid = currentUser.uid;
      } else {
        _error = 'Registration failed. Please try again.';
        _status = AuthStatus.unauthenticated;
        _resolvingManually = false;
        notifyListeners();
        return false;
      }
    }

    // Firebase Auth succeeded. Now write the volunteerRequest document.
    debugPrint('[AuthProvider] Firebase Auth OK, uid=$createdUid. Writing Firestore doc...');
    try {
      await FirebaseService.volunteerRequests
          .doc(createdUid)
          .set(requestData.copyWithId(createdUid!).toFirestore());
      debugPrint('[AuthProvider] volunteerRequest written successfully');
    } catch (e) {
      debugPrint('[AuthProvider] volunteerRequest Firestore write error: $e');
      // Navigate to pending screen anyway and retry in background
      _retryFirestoreWrite(createdUid!, requestData);
    }

    _request = requestData.copyWithId(createdUid!);
    _status = AuthStatus.pendingApproval;
    _resolvingManually = false;
    notifyListeners();
    return true;
  }

  /// Retries the Firestore volunteerRequest write after a failed registration.
  Future<void> _retryFirestoreWrite(String uid, VolunteerRequestModel requestData) async {
    // Wait a moment then retry
    await Future.delayed(const Duration(seconds: 2));
    try {
      debugPrint('[AuthProvider] Retrying volunteerRequest write for $uid...');
      await FirebaseService.volunteerRequests
          .doc(uid)
          .set(requestData.copyWithId(uid).toFirestore());
      debugPrint('[AuthProvider] Retry volunteerRequest write succeeded');
    } catch (e) {
      debugPrint('[AuthProvider] Retry volunteerRequest write also failed: $e');
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
