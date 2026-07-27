import 'package:gastromic/core/utils/venue_preference_filter.dart';

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
  final String types;
  final int priceLevel;

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
    this.types = '',
    this.priceLevel = 2,
  });

  String get categoryLine => '$category • $district';

  factory MapVenueModel.fromMap(String id, Map<String, dynamic> map) {
    return MapVenueModel(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      district: map['district'] ?? map['city'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      price: (map['price'] ?? 0).toDouble(),
      busyness: (map['busyness'] ?? 0.5).toDouble(),
      isOpenNow: map['isOpenNow'] ?? true,
      types: map['types']?.toString() ?? '',
      priceLevel: ((map['priceLevel'] ?? 2) as num).toInt(),
    );
  }

  VenueFilterData toFilterData() => VenueFilterData(
        name: name,
        category: category,
        types: types,
        price: price,
        priceLevel: priceLevel,
      );
}
