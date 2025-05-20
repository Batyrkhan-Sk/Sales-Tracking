import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/auth_data.dart';

class OfflinePinLoginScreen extends StatefulWidget {
  const OfflinePinLoginScreen({super.key});

  @override
  State<OfflinePinLoginScreen> createState() => _OfflinePinLoginScreenState();
}

class _OfflinePinLoginScreenState extends State<OfflinePinLoginScreen> {
  final _pinController = TextEditingController();
  String? _error;

  void _loginOffline() {
    final enteredPin = _pinController.text.trim();
    final box = Hive.box<AuthData>('auth');
    final auth = box.get('session');

    if (auth == null) {
      setState(() => _error = 'No offline session found.');
      return;
    }

    print('🔒 Saved PIN: ${auth.pin}');
    print('🔑 Entered PIN: $enteredPin');

    if (auth.pin.isEmpty) {
      setState(() => _error = 'PIN not set yet. Please log in online first.');
      return;
    }

    if (enteredPin != auth.pin) {
      setState(() => _error = 'Invalid PIN. Please try again.');
      return;
    }

    // Успешный оффлайн вход
    Navigator.pushNamedAndRemoveUntil(context, '/explore', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline PIN Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Enter your PIN to login offline:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'PIN',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loginOffline,
              child: const Text('Login Offline'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
