import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/connectivity_service.dart';
import '../widgets/bottom_navigation_helper.dart';

class ProductScanScreen extends StatelessWidget {
  const ProductScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/qr-code';
    final currentIndex = BottomNavigationHelper.getCurrentIndex(currentRoute);
    final connectivity = Provider.of<ConnectivityService>(context);

    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    final Color primaryColor = const Color(0xFF3D4A28);
    final Color appBarColor = isDarkMode ? theme.appBarTheme.backgroundColor ?? theme.primaryColor : const Color(0xFFF8F8F2);
    final Color titleColor = isDarkMode ? Colors.white : primaryColor;
    final Color subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color iconColor = isDarkMode ? Colors.white : primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 1,
        title: Text(
          'Product Scan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'PRODUCT SCAN',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      connectivity.isOnline
                          ? 'Get detailed information about any product in just a few seconds by simply scanning its barcode. Fast and convenient!'
                          : 'QR code scanning is unavailable offline. Please connect to the internet.',
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Icon(
                      Icons.qr_code_2,
                      size: 220,
                      color: iconColor,
                    ),
                    const SizedBox(height: 48),
                    DoneButton(
                      isDarkMode: isDarkMode,
                      isOnline: connectivity.isOnline,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Offline indicator banner
            if (!connectivity.isOnline)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.red,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No Internet Connection',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
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
}

class DoneButton extends StatelessWidget {
  final bool isDarkMode;
  final bool isOnline;

  const DoneButton({
    super.key,
    required this.isDarkMode,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = isDarkMode
        ? const Color(0xFF556B3E)
        : const Color(0xFF3D4A28);

    final Color textColor = Colors.white;

    return ElevatedButton(
      onPressed: isOnline
          ? () {
        // Functionality for the Done button (e.g., trigger QR scan)
        // Add your QR scanning logic here (e.g., using a QR scanner package)
      }
          : null, // Disable button when offline
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor, // Set base color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        minimumSize: const Size(double.infinity, 50),
        elevation: isDarkMode ? 2 : 4,
        // Adjust foreground color and opacity for disabled state
        foregroundColor: isOnline ? textColor : Colors.grey,
        disabledBackgroundColor: Colors.grey[300], // Use disabledBackgroundColor for offline state
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Done',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isOnline ? textColor : Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward, color: isOnline ? textColor : Colors.black54),
        ],
      ),
    );
  }
}