class DishModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  const DishModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory DishModel.fromMap(String id, Map<String, dynamic> map) {
    return DishModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'imageUrl': imageUrl};
  }
}
