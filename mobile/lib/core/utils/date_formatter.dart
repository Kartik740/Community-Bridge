// lib/core/utils/date_formatter.dart
// Utility class to format dates into human-readable strings.

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _short = DateFormat('d MMM yyyy');
  static final DateFormat _long = DateFormat('d MMMM yyyy, hh:mm a');
  static final DateFormat _time = DateFormat('hh:mm a');

  /// Returns "3 Apr 2026"
  static String shortDate(DateTime? dt) {
    if (dt == null) return '—';
    return _short.format(dt);
  }

  /// Returns "3 April 2026, 10:30 AM"
  static String longDate(DateTime? dt) {
    if (dt == null) return '—';
    return _long.format(dt);
  }

  /// Returns "10:30 AM"
  static String timeOnly(DateTime? dt) {
    if (dt == null) return '—';
    return _time.format(dt);
  }

  /// Returns relative label like "2 hours ago", "Just now"
  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _short.format(dt);
  }
}
