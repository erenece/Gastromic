class VenueModel {
  final String id;
  final String name;
  final double rating;
  final String imageUrl;
  final String category;

  const VenueModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.imageUrl,
    required this.category,
  });

  factory VenueModel.fromMap(String id, Map<String, dynamic> map) {
    return VenueModel(
      id: id,
      name: map['name'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}
