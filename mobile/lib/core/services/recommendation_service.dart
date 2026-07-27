import 'package:dio/dio.dart';
import 'package:flavor/flavor.dart';

import 'package:gastromic/core/models/user_preferences_snapshot.dart';
import 'package:gastromic/core/services/user_preferences_service.dart';

class RecommendationService {
  RecommendationService({
    Dio? dio,
    UserPreferencesService? preferencesService,
  })  : _dio = dio ?? Dio(),
        _preferencesService = preferencesService ?? UserPreferencesService();

  final Dio _dio;
  final UserPreferencesService _preferencesService;

  String get _baseUrl => Flavor.instance.getString(Keys.apiUrl) ?? 'http://10.0.2.2:8000';

  List<String> _normalizeAllergens(List<String> values) {
    return values
        .map((v) => v.trim().toLowerCase())
        .where((v) => v.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _buildRequestBody(UserPreferencesSnapshot prefs, {String? city}) {
    return {
      'budget_per_person': prefs.budget.round(),
      'city': city ?? 'İstanbul',
      'allergens': _normalizeAllergens(prefs.allergens),
      'sensitivities': _normalizeAllergens(prefs.conditions),
      'daily_mode': prefs.dailyModeSlug,
      'smoking_area': prefs.smokingArea,
      'alcohol_served': prefs.alcoholService,
    };
  }

  Future<String> fetchVenueSummary({required String venueId, String? city}) async {
    final prefs = await _preferencesService.loadPreferences();

    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/recommend/summary',
      data: {
        'venue_id': venueId,
        ..._buildRequestBody(prefs, city: city),
      },
      options: Options(
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    final data = response.data;
    return data?['ai_summary'] as String? ?? '';
  }

  Future<Map<String, dynamic>> fetchRecommendations({String? city}) async {
    final prefs = await _preferencesService.loadPreferences();

    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/recommend',
      data: _buildRequestBody(prefs, city: city),
      options: Options(
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    return response.data ?? {};
  }
}
