import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'package:gastromic/app/views/view_venue_detail/repository/model/venue_detail_model.dart';
import 'package:gastromic/core/services/recommendation_service.dart';

class VenueDetailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RecommendationService _recommendationService = RecommendationService();

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
        date: review['date'] ?? review['createdAt']?.toString() ?? '',
      );
    }).toList();

    var aiSummary = data['aiSummary'] as String? ?? '';
    if (aiSummary.isEmpty) {
      try {
        aiSummary = await _recommendationService.fetchVenueSummary(
          venueId: venueId,
          city: data['city'] as String?,
        );
      } catch (_) {
        aiSummary = 'Kişiselleştirilmiş AI özeti şu an oluşturulamadı.';
      }
    }

    final distance = await _distanceLabel(
      (data['latitude'] ?? 0).toDouble(),
      (data['longitude'] ?? 0).toDouble(),
    );

    final types = (data['types'] as String? ?? '').split(',');
    final features = types
        .map((t) => t.trim().replaceAll('_', ' '))
        .where((t) => t.isNotEmpty)
        .take(4)
        .toList();

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
      features: features.isEmpty ? ['Restoran'] : features,
      dishes: const [],
      reviews: reviews,
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      workingHours: data['workingHours'] ?? '10:00 - 23:00',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      priceLevel: ((data['priceLevel'] ?? 2) as num).toInt(),
      location: '${data['district'] ?? ''}, ${data['city'] ?? ''}'.trim(),
    );
  }

  Future<String> _distanceLabel(double lat, double lng) async {
    if (lat == 0 && lng == 0) return '';
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return '';
      }
      final pos = await Geolocator.getCurrentPosition();
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
