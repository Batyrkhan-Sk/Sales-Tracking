import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logs Page',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9F4),
        fontFamily: 'TTTravels',
      ),
      home: const LogsScreen(),
    );
  }
}

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  final List<Map<String, String>> logs = const [
    {"date": "23/04/2025 14:30", "user": "Admin", "desc": "Edited chair product - Changed the color and material."},
    {"date": "17/04/2025 09:15", "user": "Admin", "desc": "Sold the item chair to customer #1245."},
    {"date": "15/04/2025 11:00", "user": "Admin", "desc": "Edited chair product - Updated product description."},
    {"date": "12/04/2025 13:20", "user": "Admin", "desc": "Edited chair product - Added new images to the gallery."},
    {"date": "10/04/2025 17:45", "user": "Admin", "desc": "Sold 3 chair products to customer #987."},
    {"date": "05/04/2025 08:50", "user": "Admin", "desc": "Added new chair product to the catalog."},
    {"date": "02/04/2025 10:05", "user": "Admin", "desc": "Updated stock information for all chairs."},
    {"date": "29/03/2025 15:40", "user": "Admin", "desc": "Sold a set of 2 chairs to customer #1345."},
    {"date": "25/03/2025 12:25", "user": "Admin", "desc": "Replaced faulty chair product and issued a refund to customer."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF3D4A28)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Logs',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3D4A28),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: const [
                          SizedBox(width: 24, child: Text("SL", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 16),
                          SizedBox(width: 100, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 16),
                          SizedBox(width: 50, child: Text("User", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        itemCount: logs.length,
                        separatorBuilder: (context, index) => const Divider(height: 20),
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 24, child: Text('${index + 1}')),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 100,
                                  child: Text(log['date'] ?? ''),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(width: 50, child: Text(log['user'] ?? '')),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    log['desc'] ?? '',
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3D4A28),
        unselectedItemColor: Colors.black54,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/explore');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/scan');
          } else if (index == 2) {
            // current screen
          } else if (index == 3) {
            Navigator.pushNamed(context, '/signin');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
        ],
      ),
    );
  }
}