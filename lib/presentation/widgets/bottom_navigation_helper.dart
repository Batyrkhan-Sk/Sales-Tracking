import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';

class BottomNavigationHelper {
  static Widget buildBottomNavigation(BuildContext context, int currentIndex, Function(int) onTap) {
    final isGuestMode = Provider.of<GuestModeProvider>(context).isGuestMode;

    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.qr_code),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.edit_note),
        label: '',
      ),
    ];

    if (!isGuestMode) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.menu),
        label: '',
      ));
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF3D4A28),
      unselectedItemColor: Colors.black54,
      currentIndex: currentIndex < items.length ? currentIndex : 0,
      onTap: onTap,
      items: items,
    );
  }

  static void handleNavigation(BuildContext context, int index) {
    final isGuestMode = Provider.of<GuestModeProvider>(context, listen: false).isGuestMode;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/explore');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/qr-code');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/logs');
        break;
      case 3:
        if (!isGuestMode) {
          Navigator.pushReplacementNamed(context, '/account');
        }
        break;
    }
  }

  static int getCurrentIndex(String currentRoute) {
    switch (currentRoute) {
      case '/explore':
        return 0;
      case '/qr-code':
        return 1;
      case '/logs':
        return 2;
      case '/account':
        return 3;
      default:
        return 0;
    }
  }
}