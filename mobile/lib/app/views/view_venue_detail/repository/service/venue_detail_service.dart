import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'package:gastromic/app/views/view_venue_detail/repository/model/venue_detail_model.dart';
import 'package:gastromic/core/services/location_service.dart';
import 'package:gastromic/core/services/opening_hours_service.dart';
import 'package:gastromic/core/services/recommendation_service.dart';
import 'package:gastromic/core/services/user_preferences_service.dart';
import 'package:gastromic/core/utils/review_date_formatter.dart';

class VenueDetailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RecommendationService _recommendationService = RecommendationService();
  final OpeningHoursService _openingHoursService = OpeningHoursService();
  final UserPreferencesService _preferencesService = UserPreferencesService();

  Future<VenueDetailModel> fetchVenueDetail(String venueId) async {
    final doc = await _firestore.collection('venues').doc(venueId).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Mekan bulunamadı');
    }

    final data = doc.data()!;
    final reviewsSnapshot = await _firestore
        .collection('venues')
        .doc(venueId)
        .collection('reviews')
        .orderBy('rating', descending: true)
        .limit(10)
        .get();

    final reviews = reviewsSnapshot.docs.map((reviewDoc) {
      final review = reviewDoc.data();
      return ReviewModel(
        id: reviewDoc.id,
        userName: review['userName'] ?? 'Kullanıcı',
        rating: (review['rating'] ?? 0).toDouble(),
        comment: review['comment'] ?? '',
        date: ReviewDateFormatter.format(
          date: review['date'],
          createdAt: review['createdAt'],
        ),
      );
    }).toList();

    var aiSummary = '';
    var fitsPreferences = true;
    var preferenceChecks = <String, dynamic>{};
    final prefs = await _preferencesService.loadPreferences();
    final userAllergens = prefs.allergens;
    final userConditions = prefs.conditions;
    final userDailyMode = prefs.mode;

    try {
      final summaryResult = await _recommendationService.fetchVenueSummary(
        venueId: venueId,
        city: data['city'] as String?,
        venueName: data['name'] as String?,
        venueCategory: data['category'] as String?,
        venueTypes: data['types'] as String?,
        venueDistrict: data['district'] as String?,
        reviewSnippets: reviews
            .take(3)
            .map((r) => r.comment)
            .where((c) => c.isNotEmpty)
            .toList(),
      );
      aiSummary = summaryResult.aiSummary;
      fitsPreferences = summaryResult.fitsPreferences;
      preferenceChecks = summaryResult.checks;
    } catch (_) {
      aiSummary = 'Kişiselleştirilmiş AI özeti şu an oluşturulamadı.';
    }

    final distance = await _distanceLabel(
      _readLatitude(data),
      _readLongitude(data),
    );

    final types = (data['types'] as String? ?? '').split(',');
    final features = types
        .map((t) => t.trim().replaceAll('_', ' '))
        .where((t) => t.isNotEmpty)
        .take(4)
        .toList();

    var workingHours = data['workingHours'] as String? ?? '';
    var isOpenNow = data['isOpenNow'] as bool?;
    var openingHoursWeek = _stringList(data['openingHoursWeek']);

    if (OpeningHoursService.needsRefresh(
      workingHours: workingHours,
      openingHoursWeek: openingHoursWeek,
    )) {
      final fresh = await _openingHoursService.fetchOpeningHours(venueId);
      if (fresh != null) {
        workingHours = fresh.workingHours;
        isOpenNow = fresh.isOpenNow;
        openingHoursWeek = fresh.openingHoursWeek;
      }
    }

    if (workingHours.trim().isEmpty) {
      workingHours = 'Bilgi mevcut değil';
    }

    return VenueDetailModel(
      id: venueId,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: ((data['reviewCount'] ?? 0) as num).toInt(),
      category: data['category'] ?? '',
      distance: distance,
      aiSummary: aiSummary,
      description: data['address'] ?? '',
      fitsPreferences: fitsPreferences,
      preferenceChecks: preferenceChecks,
      userAllergens: userAllergens,
      userConditions: userConditions,
      userDailyMode: userDailyMode,
      features: features.isEmpty ? ['Restoran'] : features,
      dishes: const [],
      reviews: reviews,
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      workingHours: workingHours,
      isOpenNow: isOpenNow,
      openingHoursWeek: openingHoursWeek,
      latitude: _readLatitude(data),
      longitude: _readLongitude(data),
      priceLevel: ((data['priceLevel'] ?? 2) as num).toInt(),
      location: '${data['district'] ?? ''}, ${data['city'] ?? ''}'.trim(),
    );
  }

  double _readCoordinate(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is GeoPoint) {
      // GeoPoint latitude/longitude handled by caller via key — unused here.
      return 0;
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  double _readLatitude(Map<String, dynamic> data) {
    final value = data['latitude'];
    if (value is GeoPoint) return value.latitude;
    return _readCoordinate(value);
  }

  double _readLongitude(Map<String, dynamic> data) {
    final value = data['longitude'];
    if (value is GeoPoint) return value.longitude;
    return _readCoordinate(value);
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  Future<String> _distanceLabel(double lat, double lng) async {
    if (lat == 0 && lng == 0) return '';
    final pos = await LocationService.instance.getCurrentPosition();
    if (pos == null) return '';
    try {
      final meters = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        lat,
        lng,
      );
      if (meters >= 1000) {
        return '${(meters / 1000).toStringAsFixed(1)} km';
      }
      return '${meters.round()} m';
    } catch (_) {
      return '';
    }
  }
}
