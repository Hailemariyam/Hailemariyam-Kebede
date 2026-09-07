/// Display helpers shared across features.
class Formatters {
  Formatters._();

  /// `1250.5` -> `1,250.50`
  static String money(double amount) {
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    final negative = intPart.startsWith('-');
    final digits = negative ? intPart.substring(1) : intPart;
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '${negative ? '-' : ''}${buffer.toString()}.${parts[1]}';
  }

  /// `251911234567` -> `+251 91 123 4567` (best effort; falls back to raw).
  static String phone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return raw;
    final country = digits.substring(0, digits.length - 9);
    final rest = digits.substring(digits.length - 9);
    return '+$country ${rest.substring(0, 2)} '
        '${rest.substring(2, 5)} ${rest.substring(5)}';
  }

  /// First letters of the first and last name parts.
  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
