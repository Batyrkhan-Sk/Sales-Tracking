import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/bottom_navigation_helper.dart';

class ProductScanScreen extends StatefulWidget {
  const ProductScanScreen({super.key});

  @override
  State<ProductScanScreen> createState() => _ProductScanScreenState();
}

class _ProductScanScreenState extends State<ProductScanScreen> {
  String? scannedCode;

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/qr-code';
    final currentIndex = BottomNavigationHelper.getCurrentIndex(currentRoute);

    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    final Color primaryColor = const Color(0xFF3D4A28);
    final Color appBarColor = isDarkMode
        ? theme.appBarTheme.backgroundColor ?? theme.primaryColor
        : const Color(0xFFF8F8F2);
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
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  Text(
                    'Scan product code',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Point your camera at a barcode or QR code to get product info.',
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: MobileScanner(
                controller: MobileScannerController(),
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final String? code = barcode.rawValue;
                    if (code != null && code != scannedCode) {
                      setState(() {
                        scannedCode = code;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Scanned: $code')),
                      );
                      break; // Останавливаем после первого успешного скана
                    }
                  }
                },
              ),
            ),

            // 👉 Отображение отсканированного кода
            if (scannedCode != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Scanned code: $scannedCode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: DoneButton(isDarkMode: isDarkMode),
            ),
            const SizedBox(height: 16),
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

  const DoneButton({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor =
    isDarkMode ? const Color(0xFF556B3E) : const Color(0xFF3D4A28);
    final Color textColor = Colors.white;

    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        minimumSize: const Size(double.infinity, 50),
        elevation: isDarkMode ? 2 : 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Done',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }
}
