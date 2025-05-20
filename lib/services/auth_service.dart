import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../presentation/models/auth_data.dart';

class AuthService {
  static Future<void> logout(BuildContext context) async {
    final box = await Hive.openBox<AuthData>('auth');
    await box.delete('session');

    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }
}
