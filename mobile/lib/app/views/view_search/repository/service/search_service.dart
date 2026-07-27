import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import 'package:gastromic/core/models/user_preferences_snapshot.dart';
import 'package:gastromic/core/models/venue_model.dart';
import 'package:gastromic/core/services/user_preferences_service.dart';
import 'package:gastromic/core/utils/venue_firestore_fetch.dart';

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
  static const int _minRecentLength = 3;

  List<VenueModel>? _venuePool;

  Future<UserPreferencesSnapshot> loadPreferences() {
    return _preferencesService.loadPreferences();
  }

  Future<void> warmVenuePool({double userLat = 0, double userLng = 0}) async {
    await _ensureVenuePool(userLat: userLat, userLng: userLng);
  }

  Future<List<VenueModel>> searchVenues(
    String query, {
    double userLat = 0,
    double userLng = 0,
  }) async {
    final normalized = _normalize(query);
    if (normalized.length < 2) return [];

    final pool = await _ensureVenuePool(userLat: userLat, userLng: userLng);
    final matches = pool.where((venue) => _matchesQuery(venue, normalized)).toList();

    matches.sort((a, b) {
      final scoreDiff = _relevanceScore(a, normalized).compareTo(
        _relevanceScore(b, normalized),
      );
      if (scoreDiff != 0) return scoreDiff;
      return b.rating.compareTo(a.rating);
    });

    return matches.take(30).toList();
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
    return List<String>.from(list)
        .where((query) => query.trim().length >= _minRecentLength)
        .toList();
  }

  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < _minRecentLength) return;

    final current = getRecentSearches();
    current.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    current.insert(0, trimmed);
    if (current.length > 10) current.removeRange(10, current.length);
    await _settingsBox.put(_recentKey, current);
  }

  Future<void> clearRecentSearches() async {
    await _settingsBox.delete(_recentKey);
  }

  Future<void> sanitizeRecentSearches() async {
    final cleaned = getRecentSearches();
    await _settingsBox.put(_recentKey, cleaned);
  }

  Future<List<VenueModel>> _ensureVenuePool({
    double userLat = 0,
    double userLng = 0,
  }) async {
    if (_venuePool != null) return _venuePool!;

    final docs = await VenueFirestoreFetch.fetchPool(
      _firestore,
      userLat: userLat,
      userLng: userLng,
    );
    _venuePool = docs
        .map((doc) => VenueModel.fromMap(doc.id, doc.data))
        .toList();
    return _venuePool!;
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll('ı', 'i').replaceAll('İ', 'i');

  static bool _matchesQuery(VenueModel venue, String query) {
    final name = _normalize(venue.name);
    final category = _normalize(venue.category);
    final subCategory = _normalize(venue.subCategory);
    final city = _normalize(venue.city);
    final types = _normalize(venue.types);

    if (name.contains(query)) return true;
    if (category.contains(query)) return true;
    if (subCategory.contains(query)) return true;
    if (city.contains(query)) return true;
    if (types.contains(query)) return true;

    return name.split(' ').any((word) => word.startsWith(query));
  }

  static int _relevanceScore(VenueModel venue, String query) {
    final name = _normalize(venue.name);
    if (name == query) return 0;
    if (name.startsWith(query)) return 1;
    if (name.split(' ').any((word) => word.startsWith(query))) return 2;
    if (name.contains(query)) return 3;
    if (_normalize(venue.category).contains(query)) return 4;
    return 5;
  }
}
