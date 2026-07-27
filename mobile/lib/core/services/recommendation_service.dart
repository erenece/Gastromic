import 'package:dio/dio.dart';
import 'package:flavor/flavor.dart';
import 'package:intl/intl.dart';

import 'package:gastromic/core/models/user_preferences_snapshot.dart';
import 'package:gastromic/core/services/location_service.dart';
import 'package:gastromic/core/services/user_preferences_service.dart';

class VenueSummaryResult {
  const VenueSummaryResult({
    required this.aiSummary,
    this.fitsPreferences = true,
    this.checks = const {},
  });

  final String aiSummary;
  final bool fitsPreferences;
  final Map<String, dynamic> checks;
}

class RecommendationService {
  RecommendationService({
    Dio? dio,
    UserPreferencesService? preferencesService,
  })  : _dio = dio ?? Dio(),
        _preferencesService = preferencesService ?? UserPreferencesService();

  final Dio _dio;
  final UserPreferencesService _preferencesService;

  String get _baseUrl =>
      Flavor.instance.getString(Keys.apiUrl) ?? 'http://10.0.2.2:8000';

  List<String> _normalizeAllergens(List<String> values) {
    return values
        .map((v) => v.trim().toLowerCase())
        .where((v) => v.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>> _buildRequestBody(
    UserPreferencesSnapshot prefs, {
    String? city,
    double? lat,
    double? lng,
  }) async {
    final now = DateTime.now();
    final day = DateFormat('EEEE', 'en_US').format(now);

    return {
      'budget_per_person': prefs.budget.round(),
      'city': city ?? 'İstanbul',
      'allergens': _normalizeAllergens(prefs.allergens),
      'sensitivities': _normalizeAllergens(prefs.conditions),
      'daily_mode': prefs.dailyModeSlug,
      'smoking_area': prefs.smokingArea,
      'alcohol_served': prefs.alcoholService,
      'visit_day': day,
      'visit_hour': now.hour,
      if (lat != null && lng != null) 'location': {'lat': lat, 'lng': lng},
    };
  }

  Future<VenueSummaryResult> fetchVenueSummary({
    required String venueId,
    String? city,
    String? venueName,
    String? venueCategory,
    String? venueTypes,
    String? venueDistrict,
    List<String>? reviewSnippets,
  }) async {
    final prefs = await _preferencesService.loadPreferences();

    double? lat;
    double? lng;
    final coords = await LocationService.instance.getCoordinates();
    if (coords != null) {
      lat = coords.lat;
      lng = coords.lng;
    }

    final body = await _buildRequestBody(prefs, city: city, lat: lat, lng: lng);

    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/recommend/summary',
      data: {
        'venue_id': venueId,
        if (venueName != null) 'venue_name': venueName,
        if (venueCategory != null) 'venue_category': venueCategory,
        if (venueTypes != null) 'venue_types': venueTypes,
        if (venueDistrict != null) 'venue_district': venueDistrict,
        if (reviewSnippets != null && reviewSnippets.isNotEmpty)
          'review_snippets': reviewSnippets,
        ...body,
      },
      options: Options(
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    final data = response.data ?? {};
    return VenueSummaryResult(
      aiSummary: data['ai_summary'] as String? ?? '',
      fitsPreferences: data['fits_preferences'] as bool? ?? true,
      checks: Map<String, dynamic>.from(
        data['checks'] as Map? ?? const {},
      ),
    );
  }

  Future<Map<String, dynamic>> fetchRecommendations({String? city}) async {
    final prefs = await _preferencesService.loadPreferences();
    final body = await _buildRequestBody(prefs, city: city);

    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/recommend',
      data: body,
      options: Options(
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    return response.data ?? {};
  }
}
