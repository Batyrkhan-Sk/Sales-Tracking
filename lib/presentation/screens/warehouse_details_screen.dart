import 'package:flutter/material.dart';
import '../models/warehouse.dart';

class WarehouseDetailsScreen extends StatefulWidget {
  final Warehouse warehouse;

  const WarehouseDetailsScreen({super.key, required this.warehouse});

  @override
  State<WarehouseDetailsScreen> createState() => _WarehouseDetailsScreenState();
}

class _WarehouseDetailsScreenState extends State<WarehouseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                widget.warehouse.name,
                style: const TextStyle(
                  fontFamily: 'TTTravels',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D4A28),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Color(0xFF3D4A28),
                labelStyle: const TextStyle(
                  fontFamily: 'TTTravels',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'TTTravels',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                indicator: BoxDecoration(
                  color: Color(0xFF3D4A28),
                  borderRadius: BorderRadius.circular(20),
                ),
                tabs: [
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Text('All'),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Text('Chair'),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Text('Table'),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Text('Decor'),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            buildProductList(),
            buildProductList(category: 'Chair'),
            buildProductList(category: 'Table'),
            buildProductList(category: 'Decor'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3D4A28),
        unselectedItemColor: Colors.black54,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/explore');
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

  Widget buildProductList({String? category}) {
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Cotton armchair',
        'price': 259.99,
        'imageUrl': widget.warehouse.imageUrl,
        'category': 'Chair',
      },
    ];


    final filteredProducts = category != null
        ? products.where((product) => product['category'] == category).toList()
        : products;

    final List<Map<String, dynamic>> displayItems = [
      ...filteredProducts,
      {'isEmpty': true},
      {'isEmpty': true},
      {'isEmpty': true},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final item = displayItems[index];
        if (item.containsKey('isEmpty') && item['isEmpty'] == true) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 20,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 16,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontFamily: 'TTTravels',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3D4A28),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${item['price'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'TTTravels',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      item['imageUrl'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}