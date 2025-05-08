import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../presentation/models/warehouse.dart';
import '../presentation/models/user.dart';

class ApiService {
final String baseUrl = 'my_api';

  final bool devMode = true;

  Future<List<Warehouse>> fetchWarehouses() async {
    if (devMode) {
      return [
        Warehouse(
          id: '1',
          name: 'Mock Warehouse 1',
          imageUrl: 'https://via.placeholder.com/300x200',
          description: 'Mock description for testing',
          dimensions: {'length': 120, 'width': 80, 'height': 90},
          price: 299.99,
        ),
        Warehouse(
          id: '2',
          name: 'Mock Warehouse 2',
          imageUrl: 'https://via.placeholder.com/300x200',
          description: 'Another mock description',
          dimensions: {'length': 150, 'width': 100, 'height': 75},
          price: 499.99,
        ),
      ];
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/furniture'));
      print('Response: $response');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Warehouse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load warehouses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching warehouses: $e');
      throw Exception('Error fetching warehouses: $e');
    }
  }

  Future<Warehouse> fetchWarehouseDetails(String id) async {
    if (devMode) {
      return Warehouse(
        id: id,
        name: 'Mock Warehouse Detail',
        imageUrl: 'https://via.placeholder.com/600x400',
        description: 'Detailed mock description for testing',
        dimensions: {
          'length': 120,
          'width': 80,
          'height': 90,
          'weight': '15kg',
          'material': 'Wood'
        },
        price: 399.99,
      );
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/furniture/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Warehouse.fromJson(json);
      } else {
        throw Exception('Failed to load warehouse details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching warehouse details: $e');
    }
  }

  Future<User> registerUser(User user) async {
    if (devMode) {
      await Future.delayed(Duration(milliseconds: 500));
      return User(
        id: 'mock-user-id',
        fullName: user.fullName,
        email: user.email,
      );
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': user.fullName,
          'email': user.email,
          'password': user.password,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return User(
          id: responseData['id'] ?? 'unknown',
          fullName: responseData['fullName'] ?? user.fullName,
          email: responseData['email'] ?? user.email,
        );
      } else {
        final errorData = jsonDecode(response.body);
        if (errorData.containsKey('message')) {
          throw errorData['message'];
        } else {
          throw 'Registration error: ${response.statusCode}';
        }
      }
    } catch (e) {
      if (e.toString().contains('already registered')) {
        throw 'Email already registered. Please use another email or sign in.';
      }
      throw 'Registration error: ${e.toString()}';
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    if (devMode) {
      await Future.delayed(Duration(milliseconds: 500));
      return {
        'user': {
          'id': 'mock-user-id',
          'fullName': 'Test User',
          'email': email,
        },
        'token': 'mock-jwt-token-for-development'
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        String errorMessage = 'Login failed';
        try {
          final errorResponse = json.decode(response.body);
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (_) {}

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<User> getCurrentUser() async {
    if (devMode) {
      await Future.delayed(Duration(milliseconds: 500));
      return User(
        id: 'mock-user-id',
        fullName: 'Amir Syrimbetov',
        email: 'Tima7700@inbox.ru',
        role: 'Administrator',
      );
    }

    try {
      final String token = 'mock-jwt-token-for-development';
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return User.fromJson(json);
      } else {
        throw Exception('Failed to load current user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching current user: $e');
    }
  }

  Future<void> logout() async {
    if (devMode) {
      await Future.delayed(Duration(milliseconds: 500));
      return;
    }

    try {
      final String token = 'mock-jwt-token-for-development';
      final response = await http.post(
        Uri.parse('$baseUrl/users/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to logout: ${response.statusCode}');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}