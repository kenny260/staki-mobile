/// Reusable input validators for auth and profile forms.
/// Used by the auth screens (email/password) so validation is consistent.
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? phoneRw(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return 'Enter a valid Rwandan number';
    return null;
  }

  // --- Phone helpers used by A05/A06 (Binthia) ---

  /// Strips non-digits, a leading 250 and a leading 0 -> 9 national digits.
  static String normalizeRwandaPhone(String raw) {
    var d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('250')) d = d.substring(3);
    if (d.startsWith('0')) d = d.substring(1);
    return d;
  }

  /// Rwandan mobile numbers are 9 digits starting with 7 (MTN 78x, Airtel 73x).
  static bool isValidRwandaPhone(String raw) {
    final d = normalizeRwandaPhone(raw);
    return d.length == 9 && d.startsWith('7');
  }

  /// "+250 784 002 213"
  static String displayRwandaPhone(String raw) {
    final d = normalizeRwandaPhone(raw);
    if (d.length != 9) return '+250 $d';
    return '+250 ${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6)}';
  }
}
