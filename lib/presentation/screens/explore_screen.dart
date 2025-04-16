// lib/presentation/screens/explore_screen.dart
import 'package:flutter/material.dart';
import '../models/warehouse.dart';
import '../widgets/warehouse_card.dart';
import '../../services/api_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Warehouse>> _warehousesFuture;

  @override
  void initState() {
    super.initState();
    _warehousesFuture = _apiService.fetchWarehouses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, '/signin');
            },
          ),
          title: const Text(    'Explore more', style: TextStyle(
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
      body: FutureBuilder<List<Warehouse>>(
          future: _warehousesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load warehouses'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _warehousesFuture = _apiService.fetchWarehouses();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No warehouses found'));
            }

            final warehouses = snapshot.data!;

            return SingleChildScrollView(
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
            );
          }
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3D4A28),  unselectedItemColor: Colors.black54,
        currentIndex: 0,  onTap: (index) {
          if (index == 0) {    } else if (index == 1) {
          } else if (index == 2) {    } else if (index == 3) {
            Navigator.pushNamed(context, '/signin');    }
        },  items: const [
          BottomNavigationBarItem(      icon: Icon(Icons.home),
            label: '',    ),
          BottomNavigationBarItem(      icon: Icon(Icons.qr_code),
            label: '',    ),
          BottomNavigationBarItem(      icon: Icon(Icons.edit_note),
            label: '',    ),
          BottomNavigationBarItem(      icon: Icon(Icons.menu),
            label: '',    ),
          ],
      ),
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'TTTravels',
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

}