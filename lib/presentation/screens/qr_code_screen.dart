import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/api_service.dart';
import '../models/warehouse.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  final ApiService _apiService = ApiService();
  String? scannedCode;
  Map<String, dynamic>? scannedFurniture;
  int _selectedIndex = 1; // QR Scanner is the middle tab
  bool isLoading = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/explore');
        break;
      case 1:
      // Already on QR Scanner
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  void _handleBarcodeScan(BarcodeCapture capture) async {
    final String? code = capture.barcodes.first.rawValue;

    if (code != null && scannedCode != code) {
      setState(() {
        scannedCode = code;
        scannedFurniture = null;
        isLoading = true;
      });

      try {
        final result = await _apiService.scanFurniture(code);
        setState(() {
          scannedFurniture = result;
          isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Scanned: $code'), // TODO: Add localization
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'), // TODO: Add localization
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildFurnitureCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (scannedFurniture!['imageUrl'] != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  scannedFurniture!['imageUrl'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ListTile(
              title: Text(
                scannedFurniture!['name'] ?? 'No name', // TODO: Add localization
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                scannedFurniture!['description'] ?? 'No description', // TODO: Add localization
              ),
            ),
            if (scannedFurniture!['dimensions'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDimension(
                        'Length', // TODO: Add localization
                        scannedFurniture!['dimensions']['length']
                    ),
                    _buildDimension(
                        'Width', // TODO: Add localization
                        scannedFurniture!['dimensions']['width']
                    ),
                    _buildDimension(
                        'Height', // TODO: Add localization
                        scannedFurniture!['dimensions']['height']
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Price: \$${scannedFurniture!['price'] ?? '—'}', // TODO: Add localization
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to warehouse details
                  final warehouse = Warehouse.fromJson(scannedFurniture!);
                  Navigator.pushNamed(
                    context,
                    '/warehouse-details',
                    arguments: warehouse,
                  );
                },
                child: const Text('View Details'), // TODO: Add localization
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimension(String label, dynamic value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          '${value ?? '—'} cm',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'), // TODO: Add localization
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                scannedCode = null;
                scannedFurniture = null;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                MobileScanner(
                  controller: MobileScannerController(
                    detectionSpeed: DetectionSpeed.normal,
                  ),
                  onDetect: _handleBarcodeScan,
                ),
                // Scanning overlay
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  margin: const EdgeInsets.all(40),
                ),
                // Scanning instructions
                const Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Point camera at QR code', // TODO: Add localization
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Expanded(
              flex: 4,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (scannedFurniture != null)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildFurnitureCard(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore', // TODO: Add localization
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner', // TODO: Add localization
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile', // TODO: Add localization
          ),
        ],
      ),
    );
  }
}