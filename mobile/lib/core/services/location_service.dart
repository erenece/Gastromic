import 'package:geolocator/geolocator.dart';

/// Tekil konum servisi — izin ve konum önbelleği, eşzamanlı requestPermission engeli.
class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  Position? _cached;
  DateTime? _cachedAt;
  Future<bool>? _permissionInFlight;

  static const _cacheTtl = Duration(minutes: 2);

  Future<({double lat, double lng})?> getCoordinates({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final position = await getCurrentPosition(timeout: timeout);
    if (position == null) return null;
    return (lat: position.latitude, lng: position.longitude);
  }

  Future<Position?> getCurrentPosition({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final now = DateTime.now();
    if (_cached != null &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _cacheTtl) {
      return _cached;
    }

    if (!await _ensurePermission()) return _cached;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          timeLimit: timeout,
        ),
      );
      _cached = position;
      _cachedAt = now;
      return position;
    } catch (_) {
      return _cached;
    }
  }

  Future<bool> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    if (permission == LocationPermission.denied) {
      _permissionInFlight ??= _requestPermissionOnce();
      return _permissionInFlight!;
    }
    return false;
  }

  Future<bool> _requestPermissionOnce() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } finally {
      _permissionInFlight = null;
    }
  }
}
