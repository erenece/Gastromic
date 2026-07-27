import 'package:dio/dio.dart';
import 'package:flavor/flavor.dart';

class OpeningHoursResult {
  const OpeningHoursResult({
    required this.workingHours,
    this.isOpenNow,
    this.openingHoursWeek = const [],
  });

  final String workingHours;
  final bool? isOpenNow;
  final List<String> openingHoursWeek;

  factory OpeningHoursResult.fromJson(Map<String, dynamic> json) {
    return OpeningHoursResult(
      workingHours: json['workingHours'] as String? ?? 'Bilgi mevcut değil',
      isOpenNow: json['isOpenNow'] as bool?,
      openingHoursWeek: _stringList(json['openingHoursWeek']),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
}

class OpeningHoursService {
  OpeningHoursService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  String get _baseUrl =>
      Flavor.instance.getString(Keys.apiUrl) ?? 'http://10.0.2.2:8000';

  Future<OpeningHoursResult?> fetchOpeningHours(String venueId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/venues/$venueId/opening-hours',
        options: Options(
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      final data = response.data;
      if (data == null || data.containsKey('error')) return null;
      return OpeningHoursResult.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  static bool needsRefresh({
    required String workingHours,
    required List<String> openingHoursWeek,
  }) {
    if (openingHoursWeek.isNotEmpty) return false;
    final trimmed = workingHours.trim();
    return trimmed.isEmpty ||
        trimmed == '10:00 - 23:00' ||
        trimmed == 'Bilgi mevcut değil';
  }
}
