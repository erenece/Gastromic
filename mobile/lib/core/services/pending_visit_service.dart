import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import 'package:gastromic/app/views/view_rating/repository/model/pending_visit_model.dart';
import 'package:gastromic/app/views/view_rating/repository/service/rating_service.dart';
import 'package:gastromic/core/services/location_service.dart';

class PendingVisitService {
  PendingVisitService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    RatingService? ratingService,
    LocationService? locationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _ratingService = ratingService ?? RatingService(),
        _location = locationService ?? LocationService.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final RatingService _ratingService;
  final LocationService _location;

  String? get _uid => _auth.currentUser?.uid;

  Future<void> createFromVenue({
    required String venueId,
    required String venueName,
    required String category,
    required String location,
    required String imageUrl,
    required double rating,
    required double latitude,
    required double longitude,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final visit = PendingVisitModel(
      venueId: venueId,
      venueName: venueName,
      category: category,
      location: location,
      imageUrl: imageUrl,
      rating: rating,
      latitude: latitude,
      longitude: longitude,
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('pendingVisits')
        .doc(venueId)
        .set(visit.toMap());
  }

  Future<List<PendingVisitModel>> fetchPendingVisits() {
    return _ratingService.fetchPendingVisits();
  }

  Future<PendingVisitModel?> findNearbyActiveVisit() async {
    try {
      final visits = await fetchPendingVisits();
      if (visits.isEmpty) return null;

      final position = await _location.getCurrentPosition();
      if (position == null) return null;

      for (final visit in visits) {
        if (_ratingService.isNearby(position, visit)) {
          return visit;
        }
      }
    } on Exception {
      return null;
    }
    return null;
  }

  Future<Position?> currentPosition() {
    return _location.getCurrentPosition();
  }
}
