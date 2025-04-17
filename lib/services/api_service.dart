// lib/services/api_service.dart
import 'dart:convert';
import "package:http/http.dart" as http;
import '../presentation/models/warehouse.dart';
import '../presentation/models/user.dart';

class ApiService {
  final String baseUrl = 'http://192.168.0.14:5000/api';

  Future<List<Warehouse>> fetchWarehouses() async {
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
  // Метод для регистрации пользователя
  Future<User> registerUser(User user) async {
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
        // Успешная регистрация
        return jsonDecode(response.body);
      } else {
        // Обработка ошибок от сервера
        final errorData = jsonDecode(response.body);
        if (errorData.containsKey('message')) {
          throw errorData['message'];
        } else {
          throw 'Ошибка регистрации: ${response.statusCode}';
        }
      }
    } catch (e) {
      if (e.toString().contains('already registered')) {
        throw 'Email уже зарегистрирован. Пожалуйста, используйте другой email или войдите в систему.';
      }
      throw 'Ошибка регистрации: ${e.toString()}';
    }
  }

  // Метод для входа пользователя
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
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
}