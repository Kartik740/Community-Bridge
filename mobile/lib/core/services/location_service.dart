// lib/core/services/location_service.dart
// Handles GPS permission requests and location fetching.

import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  LocationService._();

  /// Checks permission and returns current GPS position.
  /// Returns null if permission denied or error occurs.
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
          debugPrint('[LocationService] Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Location permission permanently denied');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('[LocationService] Error getting position: $e');
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
