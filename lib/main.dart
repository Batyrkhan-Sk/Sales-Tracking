import 'package:flutter/material.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/sign_in_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: '/signin',
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/signin': (context) => const SignInScreen(),
      },
    );
  }
}