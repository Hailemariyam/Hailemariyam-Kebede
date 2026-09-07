import '../constants/app_strings.dart';

/// Pure, synchronous input validation. Returns `null` when valid, otherwise a
/// user-facing message. Kept framework-free so it is trivially unit-testable
/// and reusable from both the BLoC and the widget layer.
class Validators {
  Validators._();

  static const int pinLength = 4;

  static String? pin(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return AppStrings.pinRequired;
    if (!RegExp(r'^\d+$').hasMatch(v)) return AppStrings.pinDigitsOnly;
    if (v.length != pinLength) return AppStrings.pinLength;
    return null;
  }

  static bool isPinComplete(String value) =>
      value.length == pinLength && RegExp(r'^\d{4}$').hasMatch(value);
}
