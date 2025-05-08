import 'package:flutter/material.dart';
import '../models/warehouse.dart';
import '../../services/api_service.dart';
import '../widgets/bottom_navigation_helper.dart';
import 'package:provider/provider.dart';

class WarehouseDetailsScreen extends StatefulWidget {
  final Warehouse warehouse;

  const WarehouseDetailsScreen({super.key, required this.warehouse});

  @override
  State<WarehouseDetailsScreen> createState() => _WarehouseDetailsScreenState();
}

class _WarehouseDetailsScreenState extends State<WarehouseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWarehouseDetails();
  }

  Future<void> _loadWarehouseDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final warehouseDetails = await _apiService.fetchWarehouseDetails(widget.warehouse.id);

      setState(() {
        products = [
          {
            'name': 'Cotton armchair',
            'price': 259.99,
            'imageUrl': warehouseDetails.imageUrl,
            'category': 'Chair',
          },
          {
            'name': 'Wood table',
            'price': 349.99,
            'imageUrl': warehouseDetails.imageUrl,
            'category': 'Table',
          },
          {
            'name': 'Home decor set',
            'price': 129.99,
            'imageUrl': warehouseDetails.imageUrl,
            'category': 'Decor',
          },
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading warehouse details: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/explore';
    final currentIndex = BottomNavigationHelper.getCurrentIndex(currentRoute);

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
                  Navigator.pushReplacementNamed(context, '/explore');
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
                    // Search functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    // Cart functionality
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF3D4A28),
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
                  color: const Color(0xFF3D4A28),
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
      bottomNavigationBar: BottomNavigationHelper.buildBottomNavigation(
        context,
        currentIndex,
            (index) => BottomNavigationHelper.handleNavigation(context, index),
      ),
    );
  }

  Widget buildProductList({String? category}) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredProducts = category != null
        ? products.where((product) => product['category'] == category).toList()
        : products;

    final List<Map<String, dynamic>> displayItems = [
      ...filteredProducts,
      if (filteredProducts.length < 3) {'isEmpty': true},
      if (filteredProducts.length < 2) {'isEmpty': true},
      if (filteredProducts.isEmpty) {'isEmpty': true},
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
                    child: _buildProductImage(item['imageUrl']),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildProductImage(String imageUrl) {
    bool isValidUrl = imageUrl.startsWith('http') || imageUrl.startsWith('https');

    if (isValidUrl) {
      return Image.network(
        imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
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
    else if (imageUrl.contains('asset')) {
      return Image.asset(
        imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
    else {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Center(
          child: Text('No Image', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
  }
}