import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

class GuestModeProvider extends ChangeNotifier {
  bool _isGuestMode = true;
  bool get isGuestMode => _isGuestMode;


  bool _showGuestBanner = true;
  bool get showGuestBanner => _showGuestBanner && _isGuestMode;

  GuestModeProvider() {
    _initializeGuestMode();
  }

  Future<void> _initializeGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      _isGuestMode = token == null || token.isEmpty;
      notifyListeners();
    } catch (e) {
      _isGuestMode = true;
      notifyListeners();
    }
  }

  void setGuestMode(bool value) {
    _isGuestMode = value;
    if (value) {
      _showGuestBanner = true;
    }
    notifyListeners();
  }

  void dismissBanner() {
    _showGuestBanner = false;
    notifyListeners();
  }


  void resetBanner() {
    _showGuestBanner = true;
    notifyListeners();
  }
}