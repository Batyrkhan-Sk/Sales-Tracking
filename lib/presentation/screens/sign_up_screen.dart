import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Create Account',
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
                  const SizedBox(height: 20),
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontFamily: 'TTTravels',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    child: TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter full name',
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      ),
                      style: const TextStyle(fontFamily: 'TTTravels', fontSize: 14),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontFamily: 'TTTravels',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter email',
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      ),
                      style: const TextStyle(fontFamily: 'TTTravels', fontSize: 14),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontFamily: 'TTTravels',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'TTTravels', fontSize: 14),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must contain at least 8 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Password must contain at least 8 characters.',
                    style: TextStyle(
                      fontFamily: 'TTTravels',
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.black,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontFamily: 'TTTravels',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final fullName = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      debugPrint('Signing up with: $fullName, $email, $password');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
    }
  }
}