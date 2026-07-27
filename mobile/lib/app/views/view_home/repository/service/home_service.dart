import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

import 'package:gastromic/core/models/user_preferences_snapshot.dart';
import 'package:gastromic/core/models/venue_model.dart';
import 'package:gastromic/core/services/favorites_service.dart';
import 'package:gastromic/core/services/location_service.dart';
import 'package:gastromic/core/services/user_preferences_service.dart';
import 'package:gastromic/core/utils/venue_distance_utils.dart';
import 'package:gastromic/core/utils/venue_firestore_fetch.dart';

class HomeService {
  HomeService({
    FirebaseFirestore? firestore,
    UserPreferencesService? preferencesService,
    FavoritesService? favoritesService,
    LocationService? locationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _preferencesService = preferencesService ?? UserPreferencesService(),
        _favoritesService = favoritesService ?? FavoritesService(),
        _location = locationService ?? LocationService.instance;

  final FirebaseFirestore _firestore;
  final Geocoding _geocoding = Geocoding();
  final UserPreferencesService _preferencesService;
  final FavoritesService _favoritesService;
  final LocationService _location;

  static const _nearbyResultLimit = 10;

  Future<List<VenueModel>> _fetchVenuePool({
    double userLat = 0,
    double userLng = 0,
  }) async {
    final docs = await VenueFirestoreFetch.fetchPool(
      _firestore,
      userLat: userLat,
      userLng: userLng,
    );

    final venues = docs
        .map((doc) => VenueModel.fromMap(doc.id, doc.data))
        .toList();
    venues.sort((a, b) => b.rating.compareTo(a.rating));
    return venues;
  }

  Future<UserPreferencesSnapshot> loadPreferences() {
    return _preferencesService.loadPreferences();
  }

  Future<({double lat, double lng})?> fetchCurrentPosition() async {
    return _location.getCoordinates();
  }

  Future<String> fetchLocationName({required double lat, required double lng}) async {
    if (lat == 0 && lng == 0) return 'Konum alınamadı';

    final placemarks = await _geocoding.placemarkFromCoordinates(lat, lng);
    if (placemarks.isEmpty) return 'Konum bulunamadı';

    final place = placemarks.first;
    final district = place.subAdministrativeArea ?? '';
    final city = place.administrativeArea ?? '';

    if (district.isEmpty && city.isEmpty) return 'Konum bulunamadı';
    if (district.isEmpty) return city;
    if (city.isEmpty) return district;
    return '$district, $city';
  }

  Future<List<VenueModel>> fetchNearbyVenues({
    double? userLat,
    double? userLng,
    UserPreferencesSnapshot? prefs,
  }) async {
    final lat = userLat ?? 0;
    final lng = userLng ?? 0;

    var pool = await _fetchVenuePool(userLat: lat, userLng: lng);

    if (lat != 0 || lng != 0) {
      pool = VenueDistanceUtils.filterAndSortByDistance(
        venues: pool,
        userLat: lat,
        userLng: lng,
        readLat: (v) => v.latitude,
        readLng: (v) => v.longitude,
      );
    }

    return pool.take(_nearbyResultLimit).toList();
  }

  Future<List<VenueModel>> fetchFavoriteVenues({
    UserPreferencesSnapshot? prefs,
  }) async {
    return _favoritesService.fetchFavorites();
  }
}
