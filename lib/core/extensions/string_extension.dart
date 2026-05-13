extension StringExtension on String {
  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  bool get isValidEmail =>
      RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(trim());

  /// Accepts E.164 and common national formats (8–15 digits, optional leading +).
  bool get isValidPhone =>
      RegExp(r'^\+?[0-9]{8,15}$').hasMatch(replaceAll(RegExp(r'[\s\-()]'), ''));

  bool get isValidUrl =>
      RegExp(r'^https?://[^\s/$.?#].[^\s]*$').hasMatch(trim());

  /// At least 8 characters, one uppercase, one lowercase, one digit.
  bool get isStrongPassword =>
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(this);

  bool get isNotEmpty => trim().isNotEmpty;

  // ---------------------------------------------------------------------------
  // Transformation
  // ---------------------------------------------------------------------------

  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ').map((w) => w.capitalised).join(' ');

  /// Returns `null` if the string is blank, otherwise returns the trimmed value.
  String? get nullIfBlank => trim().isEmpty ? null : trim();

  String truncate(int maxLength, {String ellipsis = '…'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';

  /// Masks all but the last [visibleCount] characters (e.g. for passwords).
  String mask({int visibleCount = 4, String maskChar = '•'}) {
    if (length <= visibleCount) return this;
    return maskChar * (length - visibleCount) +
        substring(length - visibleCount);
  }
}

extension NullableStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  String orEmpty() => this ?? '';
}
