import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Cart logic
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    product['imageUrl'],
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Image Error', style: TextStyle(color: Colors.grey)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Product name
              Text(
                product['name'],
                style: const TextStyle(
                  fontFamily: 'TTTravels',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D4A28),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                product['description'] ?? 'No description',
                style: TextStyle(
                  fontFamily: 'TTTravels',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              // Dimensions
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Height: ${product['height'] ?? 'N/A'}',
                        style: TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Width: ${product['width'] ?? 'N/A'}',
                        style: TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Depth: ${product['depth'] ?? 'N/A'}',
                        style: TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Price: \$${product['price'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'TTTravels',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3D4A28),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Sell logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D4A28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Sell Now',
                    style: TextStyle(
                      fontFamily: 'TTTravels',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}