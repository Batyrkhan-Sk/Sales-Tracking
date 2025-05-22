import 'package:flutter/material.dart';
import '../models/warehouse.dart';
import '../screens/warehouse_details_screen.dart';

class WarehouseCard extends StatelessWidget {
  final Warehouse warehouse;

  const WarehouseCard({super.key, required this.warehouse});

  @override
  Widget build(BuildContext context) {
    final address = '${warehouse.city}, ${warehouse.country}';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Левая часть: Текст
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    warehouse.name,
                    style: const TextStyle(
                      fontFamily: 'TTTravels',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3D4A28),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Capacity: ${warehouse.capacity}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    'Stock: ${warehouse.currentStock}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WarehouseDetailsScreen(warehouse: warehouse),
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
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Правая часть: изображение/заглушка
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.warehouse, size: 40, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}