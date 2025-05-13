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
              // Логика корзины
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
              // Изображение товара
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
              // Название товара
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
              // Описание
              Text(
                product['description'] ?? 'Нет описания',
                style: TextStyle(
                  fontFamily: 'TTTravels',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              // Размеры
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Высота: ${product['height'] ?? 'N/A'}',
                        style: TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Ширина: ${product['width'] ?? 'N/A'}',
                        style: TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Глубина: ${product['depth'] ?? 'N/A'}',
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
                    'Цена: \$${product['price'].toStringAsFixed(2)}',
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
              // Кнопка
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Логика продажи
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D4A28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Продать сейчас',
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