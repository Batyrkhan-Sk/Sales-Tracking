import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/auth_data.dart'; // путь может отличаться

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  String? _error;

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.length != 4 || confirmPin.length != 4) {
      setState(() => _error = 'PIN must be 4 digits');
      return;
    }

    if (pin != confirmPin) {
      setState(() => _error = 'PINs do not match');
      return;
    }

    final box = Hive.box<AuthData>('auth');
    final auth = box.get('session');

    if (auth != null) {
      final updated = AuthData(
        token: auth.token,
        pin: pin, // ✅ вот что мы сохраняем
        userId: auth.userId,
        fullName: auth.fullName,
        email: auth.email,
      );

      await box.put('session', updated);

      // 🔍 ЛОГИ
      final saved = box.get('session');
      print('✅ PIN SAVED: ${saved?.pin}');

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/explore', (route) => false);
      }
    } else {
      setState(() => _error = 'No logged-in user found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Create a 4-digit PIN for offline login',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Enter PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePin,
              child: const Text('Save PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
