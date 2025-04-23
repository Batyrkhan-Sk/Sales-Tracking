class Warehouse {
  final String id;
  final String name;
  final String imageUrl;
  final String? description;
  final Map<String, dynamic>? dimensions;
  final double? price;

  Warehouse({
    required this.id,
    required this.name,
    required this.imageUrl,

    this.description,
    this.dimensions,
    this.price,
  });

  // Create warehouse from JSON
  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['_id'], // MongoDB использует _id
      name: json['name'],
      imageUrl: json['imageUrl'], // Обратите внимание: не image_url, а imageUrl
      description: json['description'],
      dimensions: json['dimensions'],
      price: json['price'] != null ? json['price'].toDouble() : null,
    );
  }

  // Convert warehouse to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'dimensions': dimensions,
      'price': price,
    };
  }
}
=======
  });
}

