import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:gastromic/core/models/venue_model.dart';

class HomeService {
  HomeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final Geocoding _geocoding = Geocoding();

  Future<({double lat, double lng})?> fetchCurrentPosition() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition();
      return (lat: position.latitude, lng: position.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<String> fetchLocationName() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Konum izni verilmedi');
    }

    final position = await Geolocator.getCurrentPosition();
    final placemarks = await _geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) return 'Konum bulunamadı';

    final place = placemarks.first;
    final district = place.subAdministrativeArea ?? '';
    final city = place.administrativeArea ?? '';

    if (district.isEmpty && city.isEmpty) return 'Konum bulunamadı';
    if (district.isEmpty) return city;
    if (city.isEmpty) return district;
    return '$district, $city';
  }

  Future<String> _resolveCity() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return 'İstanbul';
      }
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return 'İstanbul';
      return placemarks.first.administrativeArea ?? 'İstanbul';
    } catch (_) {
      return 'İstanbul';
    }
  }

  Future<List<VenueModel>> _fetchVenuesForCity(String city, {required int limit}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _firestore
          .collection('venues')
          .where('city', isEqualTo: city)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();
    } catch (_) {
      snapshot = await _firestore
          .collection('venues')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();
    }

    if (snapshot.docs.isEmpty && city != 'İstanbul') {
      try {
        snapshot = await _firestore
            .collection('venues')
            .where('city', isEqualTo: 'İstanbul')
            .orderBy('rating', descending: true)
            .limit(limit)
            .get();
      } catch (_) {
        snapshot = await _firestore
            .collection('venues')
            .orderBy('rating', descending: true)
            .limit(limit)
            .get();
      }
    }

    return snapshot.docs
        .map((doc) => VenueModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<VenueModel>> fetchNearbyVenues() async {
    final city = await _resolveCity();
    final venues = await _fetchVenuesForCity(city, limit: 10);
    return venues;
  }

  Future<List<VenueModel>> fetchFavoriteVenues() async {
    final snapshot = await _firestore
        .collection('venues')
        .orderBy('rating', descending: true)
        .limit(6)
        .get();

    return snapshot.docs
        .map((doc) => VenueModel.fromMap(doc.id, doc.data()))
        .toList();
  }
}
