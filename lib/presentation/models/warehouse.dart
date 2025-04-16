class Warehouse {
  final String id;
  final String name;
  final String imageUrl;
  final String? description;

  Warehouse({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
  });
  // Create warehouse from JSON
  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      description: json['description'],
    );
  }

  // Convert warehouse to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'description': description,
    };
  }
}