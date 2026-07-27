import 'package:geolocator/geolocator.dart';

/// Konum tabanlı mekan filtreleme ve sıralama.
class VenueDistanceUtils {
  VenueDistanceUtils._();

  static const defaultRadiusKm = 25.0;

  static double? distanceMeters({
    required double userLat,
    required double userLng,
    required double? venueLat,
    required double? venueLng,
  }) {
    if (userLat == 0 && userLng == 0) return null;
    if (venueLat == null || venueLng == null) return null;
    if (venueLat == 0 && venueLng == 0) return null;
    return Geolocator.distanceBetween(userLat, userLng, venueLat, venueLng);
  }

  static List<T> filterAndSortByDistance<T>({
    required List<T> venues,
    required double userLat,
    required double userLng,
    required double? Function(T item) readLat,
    required double? Function(T item) readLng,
    double radiusKm = defaultRadiusKm,
    int? limit,
  }) {
    if (userLat == 0 && userLng == 0) return limit != null ? venues.take(limit).toList() : venues;

    final radiusMeters = radiusKm * 1000;
    final scored = <({T venue, double distance})>[];

    for (final venue in venues) {
      final meters = distanceMeters(
        userLat: userLat,
        userLng: userLng,
        venueLat: readLat(venue),
        venueLng: readLng(venue),
      );
      if (meters == null) continue;
      if (meters <= radiusMeters) {
        scored.add((venue: venue, distance: meters));
      }
    }

    scored.sort((a, b) => a.distance.compareTo(b.distance));
    final sorted = scored.map((e) => e.venue).toList();
    if (limit != null && sorted.length > limit) {
      return sorted.sublist(0, limit);
    }
    return sorted;
  }
}
