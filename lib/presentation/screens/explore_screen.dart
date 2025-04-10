import 'package:flutter/material.dart';
import '../models/warehouse.dart';
import '../widgets/warehouse_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Warehouse> warehouses = [
      Warehouse(
        id: '1',
        name: 'Warehouse 1: Luxury Home Set',
        imageUrl: 'assets/images/armchair.png',
      ),
      Warehouse(
        id: '2',
        name: 'Warehouse 2: Modern Office Collection',
        imageUrl: 'assets/images/sofa.png',
      ),
      Warehouse(
        id: '3',
        name: 'Warehouse 3: Cozy Living Essentials',
        imageUrl: 'assets/images/cabinet.png',
      ),
      Warehouse(
        id: '4',
        name: 'Warehouse 4: Kitchen Appliances',
        imageUrl: 'assets/images/kitchen.png',
      ),
      Warehouse(
        id: '5',
        name: 'Warehouse 5: Outdoor Furniture',
        imageUrl: 'assets/images/outdoor.png',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/signin');
          },
        ),
        title: const Text(
          'Explore more',
          style: TextStyle(
            fontFamily: 'TTTravels',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D4A28),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin',
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Warehouses',
                style: TextStyle(
                  fontFamily: 'TTTravels',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3D4A28),
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: warehouses.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: WarehouseCard(warehouse: warehouses[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3D4A28),
        unselectedItemColor: Colors.black54,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
          } else if (index == 1) {
          } else if (index == 2) {
          } else if (index == 3) {
            Navigator.pushNamed(context, '/signin');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '',
          ),
        ],
      ),
    );
  }
}