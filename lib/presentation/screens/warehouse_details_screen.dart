import 'package:flutter/material.dart';
import '../models/warehouse.dart';
import '../../services/api_service.dart';

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
      // Получаем детальную информацию о складе из API
      // Предполагается, что у объекта warehouse есть id
      final warehouseDetails = await _apiService.fetchWarehouseDetails(widget.warehouse.id);

      // В идеале, ваш API должен возвращать продукты, связанные с этим складом
      // Здесь мы будем использовать данные, предоставленные в warehouses
      // В будущем здесь должен быть отдельный вызов API для получения продуктов

      // Временное решение для демонстрации
      setState(() {
        // Предполагается, что у модели Warehouse есть поле products или аналогичное
        // Если такого поля нет, этот код нужно будет адаптировать к вашей модели данных
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
            'imageUrl': warehouseDetails.imageUrl, // Используем то же изображение для демонстрации
            'category': 'Table',
          },
          {
            'name': 'Home decor set',
            'price': 129.99,
            'imageUrl': warehouseDetails.imageUrl, // Используем то же изображение для демонстрации
            'category': 'Decor',
          },
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Показать ошибку пользователю
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
                    // Функциональность поиска
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    // Функциональность корзины
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3D4A28),
        unselectedItemColor: Colors.black54,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/explore');
          } else if (index == 1) {
            // Действие для вкладки QR
          } else if (index == 2) {
            // Действие для вкладки Notes
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredProducts = category != null
        ? products.where((product) => product['category'] == category).toList()
        : products;

    // Добавляем пустые места, чтобы показать "Coming Soon"
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
    // Проверяем, является ли imageUrl действительным URL
    bool isValidUrl = imageUrl.startsWith('http') || imageUrl.startsWith('https');

    // Если это действительно URL, используем Image.network
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
    // Если строка содержит "asset", используем Image.asset
    else if (imageUrl.contains('asset')) {
      return Image.asset(
        imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
    // В противном случае показываем заполнитель
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