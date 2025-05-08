import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../widgets/bottom_navigation_helper.dart';

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
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    final Color titleColor = isDarkMode ? Colors.white : const Color(0xFF3D4A28);
    final Color containerColor = isDarkMode ? theme.cardColor : Colors.white;
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;

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
                    icon: Icon(Icons.arrow_back, color: titleColor),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/explore');
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Logs',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
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
                  color: containerColor,
                  borderRadius: BorderRadius.circular(22),
                  border: isDarkMode
                      ? Border.all(color: Colors.grey.shade800)
                      : null,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          SizedBox(width: 24, child: Text("SL",
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color))),
                          const SizedBox(width: 16),
                          SizedBox(width: 100, child: Text("Date",
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color))),
                          const SizedBox(width: 16),
                          SizedBox(width: 50, child: Text("User",
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color))),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text("Description",
                                style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: isDarkMode ? Colors.grey.shade700 : null),
                    Expanded(
                      child: ListView.separated(
                        itemCount: logs.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 20,
                          color: isDarkMode ? Colors.grey.shade700 : null,
                        ),
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 24, child: Text('${index + 1}',
                                    style: TextStyle(color: textColor))),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 100,
                                  child: Text(log['date'] ?? '',
                                      style: TextStyle(color: textColor)),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(width: 50, child: Text(log['user'] ?? '',
                                    style: TextStyle(color: textColor))),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    log['desc'] ?? '',
                                    style: TextStyle(color: textColor),
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
      bottomNavigationBar: BottomNavigationHelper.buildBottomNavigation(
        context,
        BottomNavigationHelper.getCurrentIndex('/logs'),
            (index) => BottomNavigationHelper.handleNavigation(context, index),
      ),
    );
  }
}