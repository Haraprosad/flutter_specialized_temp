extension DateTimeExtension on DateTime {
  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  /// `dd MMM yyyy`  →  "05 Jan 2025"
  String get formatted {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${day.toString().padLeft(2, '0')} ${months[month - 1]} $year';
  }

  /// `HH:mm`  →  "09:05"
  String get timeFormatted =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// `dd MMM yyyy, HH:mm`  →  "05 Jan 2025, 09:05"
  String get dateTimeFormatted => '$formatted, $timeFormatted';

  /// ISO-8601 date string  →  "2025-01-05"
  String get isoDate =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  // ---------------------------------------------------------------------------
  // Relative labels
  // ---------------------------------------------------------------------------

  /// Returns a human-readable relative label ("just now", "2h ago", etc.)
  /// relative to [DateTime.now].
  String get relativeLabel {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatted;
  }

  // ---------------------------------------------------------------------------
  // Predicates
  // ---------------------------------------------------------------------------

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isPast => isBefore(DateTime.now());

  bool get isFuture => isAfter(DateTime.now());

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime addDays(int days) => add(Duration(days: days));

  DateTime subtractDays(int days) => subtract(Duration(days: days));
}
