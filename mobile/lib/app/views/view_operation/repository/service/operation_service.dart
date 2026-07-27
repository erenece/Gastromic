import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'package:gastromic/core/models/map_venue_model.dart';
import 'package:gastromic/core/models/user_preferences_snapshot.dart';
import 'package:gastromic/core/services/location_service.dart';
import 'package:gastromic/core/services/user_preferences_service.dart';
import 'package:gastromic/core/utils/venue_distance_utils.dart';
import 'package:gastromic/core/utils/venue_firestore_fetch.dart';

class OperationService {
  OperationService({
    FirebaseFirestore? firestore,
    UserPreferencesService? preferencesService,
    LocationService? locationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _preferencesService = preferencesService ?? UserPreferencesService(),
        _location = locationService ?? LocationService.instance;

  final FirebaseFirestore _firestore;
  final UserPreferencesService _preferencesService;
  final LocationService _location;

  Future<Position> currentPosition() async {
    final position = await _location.getCurrentPosition();
    if (position == null) {
      throw Exception('Konum izni verilmedi');
    }
    return position;
  }

  Future<UserPreferencesSnapshot> loadUserPreferences() {
    return _preferencesService.loadPreferences();
  }

  Future<List<MapVenueModel>> fetchVenues({
    required double userLat,
    required double userLng,
  }) async {
    final docs = await VenueFirestoreFetch.fetchPool(
      _firestore,
      userLat: userLat,
      userLng: userLng,
    );

    var venues = docs
        .map((doc) => MapVenueModel.fromMap(doc.id, doc.data))
        .toList();

    if (userLat != 0 || userLng != 0) {
      venues = VenueDistanceUtils.filterAndSortByDistance(
        venues: venues,
        userLat: userLat,
        userLng: userLng,
        readLat: (v) => v.latitude,
        readLng: (v) => v.longitude,
      );
    }

    return venues;
  }
}
