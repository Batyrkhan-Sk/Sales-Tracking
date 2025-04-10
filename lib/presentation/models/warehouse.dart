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
}