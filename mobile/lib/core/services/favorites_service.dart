import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gastromic/core/models/venue_model.dart';

class FavoritesService {
  FavoritesService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _favoritesRef {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('favorites');
  }

  Future<bool> isFavorite(String venueId) async {
    final ref = _favoritesRef;
    if (ref == null) return false;
    final doc = await ref.doc(venueId).get();
    return doc.exists;
  }

  Future<void> addFavorite(VenueModel venue) async {
    final ref = _favoritesRef;
    if (ref == null) throw Exception('Oturum bulunamadı');

    await ref.doc(venue.id).set({
      'venueId': venue.id,
      'venueName': venue.name,
      'category': venue.category,
      'imageUrl': venue.imageUrl,
      'rating': venue.rating,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addFavoriteFromDetail({
    required String venueId,
    required String name,
    required String category,
    required String imageUrl,
    required double rating,
  }) async {
    final ref = _favoritesRef;
    if (ref == null) throw Exception('Oturum bulunamadı');

    await ref.doc(venueId).set({
      'venueId': venueId,
      'venueName': name,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String venueId) async {
    final ref = _favoritesRef;
    if (ref == null) throw Exception('Oturum bulunamadı');
    await ref.doc(venueId).delete();
  }

  Future<List<VenueModel>> fetchFavorites() async {
    final ref = _favoritesRef;
    if (ref == null) return [];

    final snapshot = await ref.get();
    final venues = <VenueModel>[];

    final docs = snapshot.docs.toList()
      ..sort((a, b) {
        final aTime = a.data()['addedAt'];
        final bTime = b.data()['addedAt'];
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
    for (final doc in docs) {
      final data = doc.data();
      final venueId = data['venueId'] as String? ?? doc.id;
      final venueDoc = await _firestore.collection('venues').doc(venueId).get();
      if (venueDoc.exists && venueDoc.data() != null) {
        venues.add(VenueModel.fromMap(venueId, venueDoc.data()!));
      } else {
        venues.add(
          VenueModel(
            id: venueId,
            name: data['venueName'] ?? '',
            rating: (data['rating'] ?? 0).toDouble(),
            imageUrl: data['imageUrl'] ?? '',
            category: data['category'] ?? '',
          ),
        );
      }
    }

    return venues;
  }
}
