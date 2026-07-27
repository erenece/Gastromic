import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:gastromic/core/models/map_venue_model.dart';
import 'package:gastromic/core/models/user_preferences_snapshot.dart';
import 'package:gastromic/core/services/user_preferences_service.dart';

class OperationService {
  OperationService({
    FirebaseFirestore? firestore,
    UserPreferencesService? preferencesService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _preferencesService = preferencesService ?? UserPreferencesService();

  final FirebaseFirestore _firestore;
  final Geocoding _geocoding = Geocoding();
  final UserPreferencesService _preferencesService;

  Future<Position> currentPosition() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Konum izni verilmedi');
    }
    return Geolocator.getCurrentPosition();
  }

  Future<String> _resolveCity() async {
    try {
      final pos = await currentPosition();
      final placemarks = await _geocoding.placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isEmpty) return 'İstanbul';
      return placemarks.first.administrativeArea ?? 'İstanbul';
    } catch (_) {
      return 'İstanbul';
    }
  }

  Future<UserPreferencesSnapshot> loadUserPreferences() {
    return _preferencesService.loadPreferences();
  }

  Future<List<MapVenueModel>> fetchVenues() async {
    final city = await _resolveCity();

    var snapshot = await _firestore
        .collection('venues')
        .where('city', isEqualTo: city)
        .limit(500)
        .get();

    if (snapshot.docs.isEmpty) {
      snapshot = await _firestore.collection('venues').limit(500).get();
    }

    return snapshot.docs
        .map((doc) => MapVenueModel.fromMap(doc.id, doc.data()))
        .toList();
  }
}
