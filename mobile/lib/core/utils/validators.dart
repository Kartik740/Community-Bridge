// lib/core/utils/validators.dart
// Form validation functions used across all screens.

class Validators {
  Validators._();

  /// Validates full name — required, min 3 chars.
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  /// Validates age — required, 18–70.
  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final n = int.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 18) return 'You must be at least 18 years old';
    if (n > 70) return 'Age must be 70 or below';
    return null;
  }

  /// Validates city — required.
  static String? city(String? value) {
    if (value == null || value.trim().isEmpty) return 'City is required';
    return null;
  }

  /// Validates email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  /// Validates phone — 10 digits.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 10) return 'Enter a 10-digit phone number';
    return null;
  }

  /// Validates password — min 8 chars.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  /// Validates confirm password matches original.
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  /// Validates required field is not empty.
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  /// Validates survey code — must be non-empty.
  static String? surveyCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Survey code is required';
    return null;
  }
}
