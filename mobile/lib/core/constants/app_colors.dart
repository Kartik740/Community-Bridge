// lib/core/constants/app_colors.dart
// Defines the complete colour palette for CommunityBridge.
// All colours are referenced from this single source of truth.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color primaryDark = Color(0xFF1D4ED8);

  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFF0FDF4);

  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFFFBEB);

  static const Color orange = Color(0xFFEA580C);
  static const Color orangeLight = Color(0xFFFFF7ED);

  static const Color critical = Color(0xFFDC2626);
  static const Color criticalLight = Color(0xFFFEF2F2);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  static const Color offlineBanner = Color(0xFFDC2626);
  static const Color syncBanner = Color(0xFF2563EB);

  /// Returns urgency badge colour based on score 1–10.
  static Color urgencyColor(int score) {
    if (score <= 3) return success;
    if (score <= 6) return warning;
    if (score <= 8) return orange;
    return critical;
  }

  /// Returns urgency badge background colour based on score 1–10.
  static Color urgencyBgColor(int score) {
    if (score <= 3) return successLight;
    if (score <= 6) return warningLight;
    if (score <= 8) return orangeLight;
    return criticalLight;
  }
}
