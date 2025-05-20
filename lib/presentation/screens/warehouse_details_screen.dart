import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/warehouse.dart';
import '../../services/api_service.dart';
import '../widgets/bottom_navigation_helper.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';

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
  List<Map<String, dynamic>> filteredProducts = []; // Для отфильтрованных результатов поиска
  bool isLoading = true;
  List<Map<String, dynamic>> cartItems = [];
  bool isSearchMode = false; // Флаг для режима поиска
  final TextEditingController _searchController = TextEditingController();
  bool _isLoggedIn = false; // Флаг авторизации

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkAuthStatus();
    _searchController.addListener(_filterProducts);
  }

  // Проверка статуса авторизации
  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _apiService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
    if (_isLoggedIn) {
      await _loadWarehouseDetails();
    }
  }

  Future<void> _loadWarehouseDetails() async {
    if (!_isLoggedIn) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Здесь можно использовать fetchWarehouseDetails для реальных данных
      // final warehouseDetails = await _apiService.fetchWarehouseDetails(widget.warehouse.id);

      setState(() {
        products = [
          {
            'name': 'Cotton armchair',
            'price': 259.99,
            'imageUrl': 'assets/images/armchair.png',
            'category': 'Chair',
          },
          {
            'name': 'Wood table',
            'price': 349.99,
            'imageUrl': 'assets/images/table.png',
            'category': 'Table',
          },
          {
            'name': 'Home decor set',
            'price': 129.99,
            'imageUrl': 'assets/images/cabinet.png',
            'category': 'Decor',
          },
          {
            'name': 'Modern lamp',
            'price': 84.50,
            'imageUrl': 'assets/images/lamp.png',
            'category': 'Decor',
          },
          {
            'name': 'Comfort sofa',
            'price': 599.99,
            'imageUrl': 'assets/images/sofa.png',
            'category': 'Chair',
          },
        ];
        filteredProducts = products; // Изначально отображаем все продукты
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

  // Функция для фильтрации продуктов по поисковому запросу
  void _filterProducts() {
    if (!_isLoggedIn) return;

    setState(() {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) {
          return product['name'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Функция для добавления товара в корзину (доступна только для авторизованных)
  void addToCart(Map<String, dynamic> product) {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to cart!')),
      );
      return;
    }

    setState(() {
      final index = cartItems.indexWhere((item) => item['name'] == product['name']);
      if (index == -1) {
        cartItems.add({...product, 'quantity': 1});
      } else {
        cartItems[index]['quantity']++;
      }
    });
  }

  // Открытие всплывающей корзины (доступна только для авторизованных)
  void showCartDialog() {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access denied, please sign in')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cart',
                  style: TextStyle(
                    fontFamily: 'TTTravels',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3D4A28),
                  ),
                ),
                const SizedBox(height: 16),
                cartItems.isEmpty
                    ? const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontFamily: 'TTTravels',
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                )
                    : Column(
                  children: cartItems.map((item) {
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text('Error', style: TextStyle(color: Colors.grey)),
                              ),
                            );
                          },
                        ),
                      ),
                      title: Text(
                        item['name'],
                        style: const TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 14,
                          color: Color(0xFF3D4A28),
                        ),
                      ),
                      subtitle: Text(
                        '\$${item['price'].toStringAsFixed(2)} x ${item['quantity']}',
                        style: const TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            if (item['quantity'] > 1) {
                              item['quantity']--;
                            } else {
                              cartItems.remove(item);
                            }
                          });
                          if (cartItems.isEmpty) Navigator.pop(context);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                if (cartItems.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3D4A28),
                        ),
                      ),
                      Text(
                        '\$${cartItems.fold(0.0, (total, item) => total + (item['price'] as double) * (item['quantity'] as int)).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3D4A28),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (cartItems.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/cart');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D4A28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          fontFamily: 'TTTravels',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'TTTravels',
                      fontSize: 14,
                      color: Color(0xFF3D4A28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              title: isSearchMode
                  ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontFamily: 'TTTravels',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'TTTravels',
                  fontSize: 16,
                  color: Color(0xFF3D4A28),
                ),
              )
                  : Text(
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
                  icon: Icon(isSearchMode ? Icons.close : Icons.search),
                  onPressed: () {
                    if (!_isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in to search products!')),
                      );
                      return;
                    }
                    setState(() {
                      if (isSearchMode) {
                        isSearchMode = false;
                        _searchController.clear();
                        filteredProducts = products;
                      } else {
                        isSearchMode = true;
                      }
                    });
                  },
                ),
                if (!isSearchMode)
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      if (!_isLoggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Access denied, please sign in')),
                        );
                        return;
                      }
                      showCartDialog();
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
        body: _isLoggedIn
            ? TabBarView(
          controller: _tabController,
          children: [
            buildProductList(),
            buildProductList(category: 'Chair'),
            buildProductList(category: 'Table'),
            buildProductList(category: 'Decor'),
          ],
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please log in to view products and use the cart.',
                style: TextStyle(
                  fontFamily: 'TTTravels',
                  fontSize: 18,
                  color: Color(0xFF3D4A28),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Здесь можно добавить навигацию на экран логина
                  // Например: Navigator.pushNamed(context, '/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login feature not implemented yet. Please use an authenticated session.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D4A28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontFamily: 'TTTravels',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
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

    // Фильтруем продукты по категории и поисковому запросу
    final categoryFilteredProducts = category != null
        ? filteredProducts.where((product) => product['category'] == category).toList()
        : filteredProducts;

    final List<Map<String, dynamic>> displayItems = [
      ...categoryFilteredProducts,
      if (categoryFilteredProducts.length < 3) {'isEmpty': true},
      if (categoryFilteredProducts.length < 2) {'isEmpty': true},
      if (categoryFilteredProducts.isEmpty) {'isEmpty': true},
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
                    width: 150,
                    height: 200,
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
          return GestureDetector(
            onTap: () {
              if (!_isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log in to view product details!')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(product: item),
                ),
              );
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(
                              fontFamily: 'TTTravels',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3D4A28),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${item['price'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'TTTravels',
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 150,
                        height: 200,
                        child: _buildProductImage(item['imageUrl']),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      color: const Color(0xFF3D4A28),
                      onPressed: () {
                        addToCart(item);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Container(
        width: 150,
        height: 200,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Text('Image Error', style: TextStyle(color: Colors.grey)),
                ),
              );
            },
          ),
        ),
      );
    } else if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return Container(
        width: 150,
        height: 200,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
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
          ),
        ),
      );
    } else {
      return Container(
        width: 150,
        height: 200,
        color: Colors.grey[300],
        child: const Center(
          child: Text('No Image', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
  }
}