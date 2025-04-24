import 'package:flutter/material.dart';
import '../models/warehouse.dart';
import '../screens/warehouse_details_screen.dart';

class WarehouseCard extends StatelessWidget {
  final Warehouse warehouse;

  const WarehouseCard({super.key, required this.warehouse});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    warehouse.name,
                    style: const TextStyle(
                      fontFamily: 'TTTravels',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3D4A28),
                    ),
                  ),
                  if (warehouse.price != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '\$${warehouse.price!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WarehouseDetailsScreen(
                              warehouse: warehouse,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.black12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Проверяем, является ли imageUrl действительным URL
    bool isValidUrl = warehouse.imageUrl.startsWith('http') ||
        warehouse.imageUrl.startsWith('https');

    // Если это действительно URL, используем Image.network
    if (isValidUrl) {
      return Image.network(
        warehouse.imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
    // Если строка содержит "asset", используем Image.asset
    else if (warehouse.imageUrl.contains('asset')) {
      return Image.asset(
        warehouse.imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }
    // В противном случае показываем заполнитель
    else {
      return Container(
        width: 120,
        height: 120,
        color: Colors.grey[300],
        child: const Center(
          child: Text('No Image', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
  }
}