import 'package:gastromic/core/utils/venue_preference_filter.dart';

class VenueModel {
  final String id;
  final String name;
  final double rating;
  final String imageUrl;
  final String category;
  final String subCategory;
  final int reviewCount;
  final double? latitude;
  final double? longitude;
  final String city;
  final double price;
  final int priceLevel;
  final String types;

  const VenueModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.imageUrl,
    required this.category,
    this.subCategory = '',
    this.reviewCount = 0,
    this.latitude,
    this.longitude,
    this.city = '',
    this.price = 0,
    this.priceLevel = 2,
    this.types = '',
  });

  String get categoryLine =>
      subCategory.isEmpty ? category : '$category • $subCategory';

  factory VenueModel.fromMap(String id, Map<String, dynamic> map) {
    return VenueModel(
      id: id,
      name: map['name'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      subCategory: map['subCategory'] ?? '',
      reviewCount: ((map['reviewCount'] ?? 0) as num).toInt(),
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      city: map['city'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      priceLevel: ((map['priceLevel'] ?? 2) as num).toInt(),
      types: map['types']?.toString() ?? '',
    );
  }

  VenueFilterData toFilterData() => VenueFilterData(
        name: name,
        category: category,
        types: types,
        price: price,
        priceLevel: priceLevel,
      );

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'imageUrl': imageUrl,
      'category': category,
      'subCategory': subCategory,
      'reviewCount': reviewCount,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'city': city,
      'price': price,
      'priceLevel': priceLevel,
      'types': types,
    };
  }
}
