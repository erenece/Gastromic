import 'package:gastromic/core/models/dish_model.dart';

class VenueDetailModel {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String category;
  final String distance;
  final String aiSummary;
  final String description;
  final List<String> features;
  final List<DishModel> dishes;
  final List<ReviewModel> reviews;
  final String address;
  final String phone;
  final String workingHours;
  final double latitude;
  final double longitude;
  final int priceLevel;
  final String location;

  const VenueDetailModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.distance,
    required this.aiSummary,
    required this.description,
    required this.features,
    required this.dishes,
    required this.reviews,
    required this.address,
    required this.phone,
    required this.workingHours,
    required this.latitude,
    required this.longitude,
    required this.priceLevel,
    required this.location,
  });
}

class ReviewModel {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final String date;

  const ReviewModel({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
