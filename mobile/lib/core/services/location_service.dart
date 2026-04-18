// lib/core/services/location_service.dart
// Handles GPS permission requests and location fetching.

import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  LocationService._();

  /// Checks permission and returns current GPS position.
  /// Falls back to last known position if high-accuracy times out.
  /// Returns null only if permission is denied or location services are off.
  static Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] Location services disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationService] Location permission denied by user');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Location permission permanently denied — open app settings');
        return null;
      }

      debugPrint('[LocationService] Requesting high-accuracy GPS fix...');
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
        debugPrint('[LocationService] Got fix: ${pos.latitude}, ${pos.longitude} (±${pos.accuracy.toStringAsFixed(0)}m)');
        return pos;
      } on TimeoutException catch (_) {
        debugPrint('[LocationService] High-accuracy timed out — falling back to last known position');
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          debugPrint('[LocationService] Using last known: ${last.latitude}, ${last.longitude}');
        } else {
          debugPrint('[LocationService] No last known position available');
        }
        return last;
      }
    } catch (e) {
      debugPrint('[LocationService] Unexpected error: $e');
      return null;
    }
  }

  /// Returns distance in km between two lat/lng points.
  static double distanceKm(
    double lat1, double lng1, double lat2, double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }
}
