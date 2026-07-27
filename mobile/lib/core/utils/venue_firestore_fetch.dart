import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

/// Firestore'dan mekan havuzu — önce kullanıcının şehri, yoksa geniş limit.
class VenueFirestoreFetch {
  VenueFirestoreFetch._();

  static const fallbackLimit = 3500;

  static Future<List<({String id, Map<String, dynamic> data})>> fetchPool(
    FirebaseFirestore firestore, {
    double userLat = 0,
    double userLng = 0,
  }) async {
    final city = await _cityFromCoordinates(userLat, userLng);
    if (city != null) {
      final citySnap = await firestore
          .collection('venues')
          .where('city', isEqualTo: city)
          .get();
      if (citySnap.docs.isNotEmpty) {
        return citySnap.docs
            .map((d) => (id: d.id, data: d.data()))
            .toList();
      }
    }

    final snap = await firestore.collection('venues').limit(fallbackLimit).get();
    return snap.docs.map((d) => (id: d.id, data: d.data())).toList();
  }

  static Future<String?> _cityFromCoordinates(double lat, double lng) async {
    if (lat == 0 && lng == 0) return null;
    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final place = placemarks.first;
      for (final candidate in [
        place.administrativeArea,
        place.locality,
        place.subAdministrativeArea,
      ]) {
        final value = candidate?.trim();
        if (value != null && value.isNotEmpty) return value;
      }
    } catch (_) {}
    return null;
  }
}
