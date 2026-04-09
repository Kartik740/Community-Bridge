// lib/core/utils/connectivity_helper.dart
// Provides a simple helper to check and listen to network connectivity.

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  ConnectivityHelper._();

  static final Connectivity _connectivity = Connectivity();

  /// Returns true if device currently has any network connectivity.
  static Future<bool> isOnline() async {
    final dynamic result = await _connectivity.checkConnectivity();
    if (result is List) {
      return !result.contains(ConnectivityResult.none);
    }
    return result != ConnectivityResult.none;
  }

  /// Stream that emits true on connection, false on disconnection.
  static Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) {
        final dynamic res = results;
        if (res is List) {
          return !res.contains(ConnectivityResult.none);
        }
        return res != ConnectivityResult.none;
      },
    );
  }
}
