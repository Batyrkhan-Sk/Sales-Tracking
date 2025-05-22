class Warehouse {
  final String id;
  final String name;
  final int capacity;
  final int currentStock;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final bool isActive;

  Warehouse({
    required this.id,
    required this.name,
    required this.capacity,
    required this.currentStock,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.isActive,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    final coordinates = location['coordinates'] ?? {};

    return Warehouse(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      capacity: json['capacity'] ?? 0,
      currentStock: json['currentStock'] ?? 0,
      address: location['address'] ?? '',
      city: location['city'] ?? '',
      country: location['country'] ?? '',
      latitude: (coordinates['lat'] ?? 0).toDouble(),
      longitude: (coordinates['lng'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'capacity': capacity,
      'currentStock': currentStock,
      'location': {
        'address': address,
        'city': city,
        'country': country,
        'coordinates': {
          'lat': latitude,
          'lng': longitude,
        },
      },
      'isActive': isActive,
    };
  }
}