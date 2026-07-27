class GastromicMapMarker {
  final String id;
  final double latitude;
  final double longitude;
  final String title;

  const GastromicMapMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.title = '',
  });
}
