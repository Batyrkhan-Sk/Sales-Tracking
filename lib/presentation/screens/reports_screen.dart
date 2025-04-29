import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

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
        title: const Text('Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ReportCard(
            name: 'Amir Syrymbetov',
            email: 'Tima7700@inbox.ru',
            segment: 'Admin',
            sales: 17,
            balance: 150.00,
          ),
          SizedBox(height: 16),
          ReportCard(
            name: 'Miras Beisekeev',
            email: 'Tima7700@inbox.ru',
            segment: 'Manager',
            sales: 34,
            balance: 1450.00,
          ),
          SizedBox(height: 16),
          ReportCard(
            name: 'Tamerlan Temirkhanov',
            email: 'Tima7700@inbox.ru',
            segment: 'Admin',
            sales: 10,
            balance: 120.00,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.note),
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

class ReportCard extends StatelessWidget {
  final String name;
  final String email;
  final String segment;
  final int sales;
  final double balance;

  const ReportCard({
    super.key,
    required this.name,
    required this.email,
    required this.segment,
    required this.sales,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Segment: $segment',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Number of sales: $sales',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Balance: \$${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}