import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import 'package:gastromic/app/views/view_rating/repository/model/pending_visit_model.dart';
import 'package:gastromic/app/views/view_rating/repository/model/user_review_history_model.dart';
import 'package:gastromic/core/services/location_service.dart';
import 'package:gastromic/core/utils/review_date_formatter.dart';

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

  Future<List<UserReviewHistoryModel>> fetchReviewHistory() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('reviewHistory')
        .get();

    final history = snapshot.docs.map((doc) {
      final data = doc.data();
      final createdAt = data['createdAt'];
      return UserReviewHistoryModel(
        venueId: doc.id,
        venueName: data['venueName']?.toString() ?? 'Mekan',
        rating: (data['rating'] ?? 0).toDouble(),
        comment: data['comment']?.toString() ?? '',
        date: ReviewDateFormatter.format(
          date: data['date'],
          createdAt: createdAt,
        ),
        createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      );
    }).toList();

    history.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return history;
  }

  Future<void> submitReview({
    required String venueId,
    required String venueName,
    required double rating,
    required String comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Oturum bulunamadı');

    final batch = _firestore.batch();
    final venueReviewRef = _firestore
        .collection('venues')
        .doc(venueId)
        .collection('reviews')
        .doc(user.uid);
    final historyRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reviewHistory')
        .doc(venueId);
    final pendingRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('pendingVisits')
        .doc(venueId);

    final reviewPayload = {
      'userId': user.uid,
      'userName': user.displayName ?? 'Kullanıcı',
      'venueName': venueName,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };

    batch.set(venueReviewRef, reviewPayload);
    batch.set(historyRef, reviewPayload);
    batch.delete(pendingRef);
    await batch.commit();
  }
}
