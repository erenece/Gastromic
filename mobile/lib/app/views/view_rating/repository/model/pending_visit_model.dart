import 'package:cloud_firestore/cloud_firestore.dart';

class PendingVisitModel {
  final String venueId;
  final String venueName;
  final String category;
  final String location;
  final String imageUrl;
  final double rating;
  final double latitude;
  final double longitude;

  const PendingVisitModel({
    required this.venueId,
    required this.venueName,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  factory PendingVisitModel.fromMap(String id, Map<String, dynamic> map) {
    return PendingVisitModel(
      venueId: id,
      venueName: map['venueName'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'venueName': venueName,
      'category': category,
      'location': location,
      'imageUrl': imageUrl,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
