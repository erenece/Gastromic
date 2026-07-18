class MapVenueModel {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final String category;
  final String district;
  final double latitude;
  final double longitude;
  final double price;
  final double busyness;
  final bool isOpenNow;

  const MapVenueModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.category,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.busyness,
    required this.isOpenNow,
  });

  String get categoryLine => '$category • $district';
}
