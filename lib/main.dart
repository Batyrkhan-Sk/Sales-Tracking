import 'package:flutter/material.dart';
import 'presentation/screens/explore_screen.dart';
import 'presentation/screens/sign_in_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/account_screen.dart';
import 'presentation/screens/manage_roles_screen.dart';
import 'presentation/screens/warehouse_details_screen.dart';
import 'presentation/models/warehouse.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/explore',
      routes: {
        '/account': (context) => const AccountScreen(),
        '/explore': (context) => const ExploreScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/manage-roles': (context) => const ManageRolesScreen(),
        '/warehouse-details': (context) {
          final Warehouse warehouse = ModalRoute.of(context)!.settings.arguments as Warehouse;
          return WarehouseDetailsScreen(warehouse: warehouse);
        },
      },
    );
  }
}