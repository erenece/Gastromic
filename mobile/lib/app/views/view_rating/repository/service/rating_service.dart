import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import 'package:gastromic/app/views/view_rating/repository/model/pending_visit_model.dart';
import 'package:gastromic/core/services/location_service.dart';

class RatingService {
  RatingService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    LocationService? locationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _location = locationService ?? LocationService.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final LocationService _location;

  static const double matchRadiusMeters = 100;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Oturum bulunamadı');
    return uid;
  }

  Future<List<PendingVisitModel>> fetchPendingVisits() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('pendingVisits')
        .get();

    return snapshot.docs
        .map((doc) => PendingVisitModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<Position?> currentPosition() {
    return _location.getCurrentPosition();
  }

  bool isNearby(Position position, PendingVisitModel visit) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      visit.latitude,
      visit.longitude,
    );
    return distance <= matchRadiusMeters;
  }

  Future<void> submitReview({
    required String venueId,
    required double rating,
    required String comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Oturum bulunamadı');

    await _firestore
        .collection('venues')
        .doc(venueId)
        .collection('reviews')
        .doc(user.uid)
        .set({
          'userName': user.displayName ?? 'Kullanıcı',
          'rating': rating,
          'comment': comment,
          'createdAt': FieldValue.serverTimestamp(),
        });

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('pendingVisits')
        .doc(venueId)
        .delete();
  }
}
