import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Пример списка товаров в корзине
  List<Map<String, dynamic>> cartItems = [
    {
      'name': 'Cotton armchair',
      'price': 259.99,
      'imageUrl': 'assets/images/armchair.png',
      'quantity': 1,
    },
    {
      'name': 'Wood table',
      'price': 349,
      'imageUrl': 'assets/images/table.png',
      'quantity': 2,
    },
    {
      'name': 'Home decor set',
      'price': 129,
      'imageUrl': 'assets/images/cabinet.png',
      'quantity': 1,
    },
  ];

  // Функция для вычисления итоговой суммы
  double getTotalPrice() {
    return cartItems.fold(
      0.0,
          (total, item) =>
      total + (item['price'] as num).toDouble() * (item['quantity'] as int),
    );
  }

  // Увеличение количества товара
  void increaseQuantity(int index) {
    setState(() {
      cartItems[index]['quantity']++;
    });
  }

  // Уменьшение количества товара
  void decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
      } else {
        cartItems.removeAt(index); // Удаляем товар, если количество становится 0
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/cart';
    final currentIndex = BottomNavigationHelper.getCurrentIndex(currentRoute);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Cart',
          style: TextStyle(
            fontFamily: 'TTTravels',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D4A28),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: cartItems.isEmpty
          ? const Center(
        child: Text(
          'Your cart is empty',
          style: TextStyle(
            fontFamily: 'TTTravels',
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final price = (item['price'] as num).toDouble();
                final quantity = item['quantity'] as int;
                final totalItemPrice = price * quantity;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 100,
                            height: 100,
                            child: Image.asset(
                              item['imageUrl'],
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Text('Image Error',
                                        style: TextStyle(
                                            color: Colors.grey)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
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
                              const SizedBox(height: 8),
                              Text(
                                '\$${totalItemPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'TTTravels',
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline),
                                    onPressed: () =>
                                        decreaseQuantity(index),
                                  ),
                                  Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      fontFamily: 'TTTravels',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.add_circle_outline),
                                    onPressed: () =>
                                        increaseQuantity(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontFamily: 'TTTravels',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3D4A28),
                      ),
                    ),
                    Text(
                      '\$${getTotalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'TTTravels',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3D4A28),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Order placed successfully!')),
                      );
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
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationHelper.buildBottomNavigation(
        context,
        currentIndex,
            (index) => BottomNavigationHelper.handleNavigation(context, index),
      ),
    );
  }
}