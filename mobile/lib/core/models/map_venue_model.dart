import 'package:gastromic/core/utils/opening_hours_display.dart';
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
  final bool? isOpenNow;
  final String workingHours;
  final List<String> openingHoursWeek;
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
    this.isOpenNow,
    this.workingHours = '',
    this.openingHoursWeek = const [],
    this.types = '',
    this.priceLevel = 2,
  });

  String get categoryLine => '$category • $district';

  bool get isCurrentlyOpen => OpeningHoursDisplay.isOpenAt(
        DateTime.now(),
        openingHoursWeek: openingHoursWeek,
        workingHoursFallback: workingHours,
        storedIsOpenNow: isOpenNow,
      );

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
      isOpenNow: map['isOpenNow'] as bool?,
      workingHours: map['workingHours']?.toString() ?? '',
      openingHoursWeek: _stringList(map['openingHoursWeek']),
      types: map['types']?.toString() ?? '',
      priceLevel: ((map['priceLevel'] ?? 2) as num).toInt(),
    );
  }

  MapVenueModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? rating,
    String? category,
    String? district,
    double? latitude,
    double? longitude,
    double? price,
    double? busyness,
    bool? isOpenNow,
    String? workingHours,
    List<String>? openingHoursWeek,
    String? types,
    int? priceLevel,
  }) {
    return MapVenueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      price: price ?? this.price,
      busyness: busyness ?? this.busyness,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      workingHours: workingHours ?? this.workingHours,
      openingHoursWeek: openingHoursWeek ?? this.openingHoursWeek,
      types: types ?? this.types,
      priceLevel: priceLevel ?? this.priceLevel,
    );
  }

  VenueFilterData toFilterData() => VenueFilterData(
        name: name,
        category: category,
        types: types,
        price: price,
        priceLevel: priceLevel,
      );

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
}
