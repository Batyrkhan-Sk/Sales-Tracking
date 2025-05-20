import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import '../../services/api_service.dart';
import '../../providers/app_providers.dart';
import '../models/auth_data.dart';
import 'offline_pin_login_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sign In',
          style: TextStyle(
            fontFamily: 'TTTravels',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 70),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email is required';
                      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password is required';
                      if (value.length < 8) return 'Password must be at least 8 characters';
                      if (!RegExp(r'^(?=.*[A-Z])(?=.*[0-9]).*$').hasMatch(value)) {
                        return 'Must contain uppercase and number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => debugPrint('Forgot password pressed'),
                      child: const Text('Forgot Password?', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.black,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text('Sign In', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text("Don't have an account? Sign Up"),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Provider.of<GuestModeProvider>(context, listen: false).setGuestMode(true);
                      Navigator.pushNamedAndRemoveUntil(context, '/explore', (route) => false);
                    },
                    child: const Text('Continue as Guest', style: TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OfflinePinLoginScreen()),
                      );
                    },
                    child: const Text('Login via PIN (Offline Mode)',
                        style: TextStyle(color: Colors.deepPurple)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        final loginResponse = await _apiService.loginUser(email, password);

        if (loginResponse['token'] == null) throw Exception('Invalid response from server');

        final token = loginResponse['token'];
        final user = loginResponse['user'];

        if (user == null || user['id'] == null || user['fullName'] == null || user['email'] == null) {
          throw Exception('User data is incomplete');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userId', user['id']);
        await prefs.setString('fullName', user['fullName']);
        await prefs.setString('email', user['email']);

        final authBox = Hive.box<AuthData>('auth');
        final existing = authBox.get('session');

        // Сохраняем с пустым PIN, если его ещё нет
        await authBox.put('session', AuthData(
          token: token,
          pin: existing?.pin ?? '',
          userId: user['id'],
          fullName: user['fullName'],
          email: user['email'],
        ));

        if (!mounted) return;

        Provider.of<GuestModeProvider>(context, listen: false).setGuestMode(false);

        final updated = authBox.get('session');

        if (updated != null && updated.pin.isNotEmpty) {
          Navigator.pushNamedAndRemoveUntil(context, '/explore', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/set-pin', (route) => false);
        }
      } catch (error) {
        if (!mounted) return;

        String errorMessage;
        if (error.toString().contains('401')) {
          errorMessage = 'Invalid email or password';
        } else if (error.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (error.toString().contains('timeout')) {
          errorMessage = 'Request timed out. Please try again.';
        } else {
          errorMessage = 'Login failed: ${error.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
