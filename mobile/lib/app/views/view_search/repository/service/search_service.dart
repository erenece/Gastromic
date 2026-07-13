import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import 'package:gastromic/core/models/venue_model.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _settingsBox = Hive.box('settings');

  static const String _recentKey = 'recent_searches';

  Future<List<VenueModel>> searchVenues(String query) async {
    final snapshot = await _firestore
        .collection('venues')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => VenueModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<VenueModel>> fetchFrequentVenues() async {
    final snapshot = await _firestore
        .collection('venues')
        .orderBy('rating', descending: true)
        .limit(4)
        .get();

    return snapshot.docs
        .map((doc) => VenueModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  List<String> getRecentSearches() {
    final list = _settingsBox.get(_recentKey, defaultValue: <String>[]);
    return List<String>.from(list);
  }

  Future<void> addRecentSearch(String query) async {
    final current = getRecentSearches();
    current.remove(query);
    current.insert(0, query);
    if (current.length > 10) current.removeLast();
    await _settingsBox.put(_recentKey, current);
  }

  Future<void> clearRecentSearches() async {
    await _settingsBox.delete(_recentKey);
  }
}
