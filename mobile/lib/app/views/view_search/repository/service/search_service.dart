import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import 'package:gastromic/core/models/user_preferences_snapshot.dart';
import 'package:gastromic/core/models/venue_model.dart';
import 'package:gastromic/core/services/user_preferences_service.dart';

class SearchService {
  SearchService({
    FirebaseFirestore? firestore,
    UserPreferencesService? preferencesService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _preferencesService = preferencesService ?? UserPreferencesService();

  final FirebaseFirestore _firestore;
  final UserPreferencesService _preferencesService;
  final Box _settingsBox = Hive.box('settings');

  static const String _recentKey = 'recent_searches';

  Future<UserPreferencesSnapshot> loadPreferences() {
    return _preferencesService.loadPreferences();
  }

  Future<List<VenueModel>> searchVenues(
    String query, {
    UserPreferencesSnapshot? prefs,
  }) async {
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

  Future<List<VenueModel>> fetchFrequentVenues({
    UserPreferencesSnapshot? prefs,
  }) async {
    final snapshot = await _firestore
        .collection('venues')
        .orderBy('rating', descending: true)
        .limit(20)
        .get();

    final venues = snapshot.docs
        .map((doc) => VenueModel.fromMap(doc.id, doc.data()))
        .toList();

    return venues.take(4).toList();
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
