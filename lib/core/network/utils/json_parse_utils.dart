/// Reusable type-safe JSON converters for handling inconsistent backend
/// responses — null where you expect a value, string where you expect int,
/// int where you expect bool, etc.
///
/// Use these in Freezed model `@JsonKey(fromJson: ...)` annotations:
///
/// ```dart
/// @freezed
/// class MyModel with _$MyModel {
///   const factory MyModel({
///     @Default('') @JsonKey(fromJson: JsonParseUtils.toStringOrEmpty)
///     String name,
///     @Default(0) @JsonKey(fromJson: JsonParseUtils.toInt)
///     int count,
///     @Default(false) @JsonKey(fromJson: JsonParseUtils.toBool)
///     bool active,
///   }) = _MyModel;
/// }
/// ```
class JsonParseUtils {
  /// Safely converts any value to int.
  /// Handles: null → 0, String → tryParse, double → toInt, int → as-is.
  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static int? toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  /// Safely converts any value to double.
  static double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0.0;
    return 0.0;
  }

  static double? toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  /// Safely converts any value to bool.
  /// Handles: null → false, int (0/1), String ("true"/"false"/"yes"/"no"/"1"/"0").
  static bool toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }

  /// Safely converts any value to String. Returns empty string for null.
  static String toStringOrEmpty(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String? toStringOrNull(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  /// Parses DateTime from ISO string or Unix timestamp (seconds/milliseconds).
  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value > 10000000000 ? value : value * 1000,
      );
    }
    return null;
  }

  /// Generic enum parser with fallback.
  /// Usage: `JsonParseUtils.toEnum(value, Status.values, Status.unknown)`
  static T toEnum<T>(dynamic value, List<T> values, T fallback) {
    if (value == null) return fallback;
    final valueStr = value.toString().toLowerCase().trim();
    return values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == valueStr,
      orElse: () => fallback,
    );
  }

  /// Safely parses list of strings from a mixed-type JSON array.
  static List<String> toStringList(dynamic value) {
    if (value == null || value is! List) return [];
    return value
        .where((item) => item != null)
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<int> toIntList(dynamic value) {
    if (value == null || value is! List) return [];
    return value.where((item) => item != null).map(toInt).toList();
  }

  /// Generic list parser for complex objects.
  /// Usage: `JsonParseUtils.toList(value, Address.fromJson)`
  static List<T> toList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value == null || value is! List) return [];
    return value
        .whereType<Map<String, dynamic>>()
        .map((json) {
          try {
            return fromJson(json);
          } catch (_) {
            return null;
          }
        })
        .whereType<T>()
        .toList();
  }

  /// Safely parses a nested object.
  /// Usage: `JsonParseUtils.toObject(value, Settings.fromJson)`
  static T? toObject<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value == null || value is! Map<String, dynamic>) return null;
    try {
      return fromJson(value);
    } catch (_) {
      return null;
    }
  }

  static bool isNotEmpty(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }

  static void validateRequired(
    Map<String, dynamic> json,
    List<String> fields,
  ) {
    for (final field in fields) {
      if (!json.containsKey(field) || !isNotEmpty(json[field])) {
        throw FormatException('Required field "$field" is missing or empty');
      }
    }
  }
}
