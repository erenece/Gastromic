/// Google `weekdayDescriptions` listesinden bugünün çalışma saatini seçer
/// ve anlık açık/kapalı durumunu hesaplar.
class OpeningHoursDisplay {
  OpeningHoursDisplay._();

  static const _trWeekdays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  static final _timeRangePattern = RegExp(
    r'(\d{1,2}:\d{2})\s*[–\-]\s*(\d{1,2}:\d{2})',
  );

  static String forToday({
    required List<String> openingHoursWeek,
    required String workingHoursFallback,
    bool? isOpenNow,
  }) {
    final todayName = _trWeekdays[DateTime.now().weekday - 1];
    var line = _lineForDay(openingHoursWeek, todayName);

    if (line == null && workingHoursFallback.trim().isNotEmpty) {
      final fallback = workingHoursFallback.trim();
      if (fallback.toLowerCase().startsWith(todayName.toLowerCase())) {
        line = fallback.split(' · ').first.trim();
      } else if (!_looksLikePlaceholder(fallback)) {
        line = fallback;
      }
    }

    if (line == null || line.isEmpty) {
      return 'Bilgi mevcut değil';
    }

    final lower = line.toLowerCase();
    if (lower.contains('kapalı')) {
      return line;
    }

    if (isOpenNow != null &&
        !line.contains(' · Açık') &&
        !line.contains(' · Kapalı')) {
      final status = isOpenNow ? 'Açık' : 'Kapalı';
      return '$line · $status';
    }

    return line;
  }

  /// Bugünün saatlerine göre mekanın şu an açık olup olmadığını döndürür.
  /// Saat bilgisi yoksa [storedIsOpenNow] kullanılır; o da yoksa `false`.
  static bool isOpenAt(
    DateTime now, {
    required List<String> openingHoursWeek,
    required String workingHoursFallback,
    bool? storedIsOpenNow,
  }) {
    final todayName = _trWeekdays[now.weekday - 1];
    var line = _lineForDay(openingHoursWeek, todayName);

    if (line == null && workingHoursFallback.trim().isNotEmpty) {
      final fallback = workingHoursFallback.trim();
      if (fallback.toLowerCase().startsWith(todayName.toLowerCase())) {
        line = fallback.split(' · ').first.trim();
      }
    }

    if (line != null) {
      final parsed = _parseLineOpenStatus(line, now);
      if (parsed != null) return parsed;
    }

    final simple = _parseSimpleDailyHours(workingHoursFallback, now);
    if (simple != null) return simple;

    return storedIsOpenNow ?? false;
  }

  static bool? _parseSimpleDailyHours(String value, DateTime now) {
    final trimmed = value.trim().split(' · ').first.trim();
    if (trimmed.isEmpty || trimmed == 'Bilgi mevcut değil') return null;
    if (trimmed.toLowerCase().contains('kapalı')) return false;

    final match = _timeRangePattern.firstMatch(trimmed);
    if (match == null) return null;

    final start = _parseMinutes(match.group(1)!);
    final end = _parseMinutes(match.group(2)!);
    if (start == null || end == null) return null;

    final nowMinutes = now.hour * 60 + now.minute;
    return _isWithinRange(nowMinutes, start, end);
  }

  static bool? _parseLineOpenStatus(String line, DateTime now) {
    final lower = line.toLowerCase();
    if (lower.contains('kapalı')) return false;
    if (lower.contains('24 saat')) return true;

    final colonIdx = line.indexOf(':');
    if (colonIdx == -1) return null;

    var hoursPart = line.substring(colonIdx + 1).trim();
    hoursPart = hoursPart.split(' · ').first.trim();
    if (hoursPart.isEmpty) return null;

    final nowMinutes = now.hour * 60 + now.minute;
    var matchedAnyRange = false;

    for (final segment in hoursPart.split(',')) {
      final match = _timeRangePattern.firstMatch(segment.trim());
      if (match == null) continue;

      matchedAnyRange = true;
      final start = _parseMinutes(match.group(1)!);
      final end = _parseMinutes(match.group(2)!);
      if (start == null || end == null) continue;
      if (_isWithinRange(nowMinutes, start, end)) return true;
    }

    return matchedAnyRange ? false : null;
  }

  static bool _isWithinRange(int now, int start, int end) {
    if (start == end) return true;
    if (end > start) {
      return now >= start && now < end;
    }
    return now >= start || now < end;
  }

  static int? _parseMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return hour * 60 + minute;
  }

  static String? _lineForDay(List<String> week, String dayName) {
    for (final raw in week) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.toLowerCase().startsWith(dayName.toLowerCase())) {
        return line;
      }
    }
    return null;
  }

  static bool _looksLikePlaceholder(String value) {
    return value == '10:00 - 23:00' || value == 'Bilgi mevcut değil';
  }
}
