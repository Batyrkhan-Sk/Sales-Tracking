import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/warehouse.dart';
import '../widgets/warehouse_card.dart';
import '../../services/api_service.dart';
import '../../providers/app_providers.dart';
import '../../providers/guest_mode_banner.dart';
import '../../services/connectivity_service.dart';
import '../../services/auth_service.dart'; // ✅ добавлено
import '../widgets/bottom_navigation_helper.dart';
import '../widgets/sync_button.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GuestModeProvider>(context, listen: false).resetBanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGuestMode = Provider.of<GuestModeProvider>(context).isGuestMode;
    final isOnline = Provider.of<ConnectivityService>(context).isOnline;

    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    final Color primaryColor = const Color(0xFF3D4A28);
    final Color titleColor = isDarkMode ? Colors.white : primaryColor;
    final Color warningColor = isDarkMode ? Colors.redAccent : Colors.red;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/signin');
          },
        ),
        title: Text(
          'Explore more',
          style: TextStyle(
            fontFamily: 'TTTravels',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        actions: [
          if (isGuestMode)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              child: Text(
                'Sign In',
                style: TextStyle(
                  fontFamily: 'TTTravels',
                  color: titleColor,
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.logout, color: titleColor),
              onPressed: () async {
                await AuthService.logout(context); // ✅ Используем логаут из Hive
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const GuestModeBanner(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SyncButton(
                    onSync: () {
                      setState(() {
                        _warehousesFuture = _apiService.fetchWarehouses();
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Warehouse>>(
                  future: _warehousesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: isDarkMode ? Colors.white : primaryColor,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return _buildErrorWidget(
                        'Failed to load warehouses',
                            () {
                          setState(() {
                            _warehousesFuture = _apiService.fetchWarehouses();
                          });
                        },
                        warningColor,
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No warehouses found',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      );
                    }

                    final warehouses = snapshot.data!;

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Warehouses',
                              style: TextStyle(
                                fontFamily: 'TTTravels',
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: titleColor,
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
                  },
                ),
              ),
            ],
          ),

          // Мини-баннер при оффлайне
          if (!isOnline)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.wifi_off, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Offline Mode — No Internet',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: isDarkMode ? Colors.white : primaryColor,
            unselectedItemColor: isDarkMode ? Colors.white70 : Colors.grey,
          ),
        ),
        child: BottomNavigationHelper.buildBottomNavigation(
          context,
          BottomNavigationHelper.getCurrentIndex('/explore'),
              (index) => BottomNavigationHelper.handleNavigation(context, index),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry, Color errorColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(
              fontFamily: 'TTTravels',
              fontSize: 16,
              color: errorColor,
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
