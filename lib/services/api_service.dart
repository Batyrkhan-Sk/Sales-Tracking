import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../presentation/models/warehouse.dart';
import '../presentation/models/user.dart';
import 'connectivity_service.dart';

class ApiService {
  final String baseUrl = 'my_api';
  final bool devMode = true;

  static const String _warehouseCacheBox = 'warehouseCache';
  static const String _userCacheBox = 'userCache';
  static const String _queueBoxName = 'apiQueue';

  late Box _warehouseBox;
  late Box _userBox;
  late Box _queueBox;
  final ConnectivityService connectivityService;

  static ApiService? _instance;

  factory ApiService({ConnectivityService? connectivityService}) {
    if (_instance == null) {
      // If no connectivity service is provided, create a new instance
      final connService = connectivityService ?? ConnectivityService();
      _instance = ApiService._internal(connectivityService: connService);
    }
    return _instance!;
  }

  // Private constructor for singleton
  ApiService._internal({required this.connectivityService}) {
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _warehouseBox = await Hive.openBox(_warehouseCacheBox);

    _userBox = await Hive.openBox(_userCacheBox);
    _queueBox = await Hive.openBox(_queueBoxName);
  }

  // Queue an API request for later execution
  Future<void> _queueRequest(String method, Map<String, dynamic> data) async {
    await _queueBox.add({
      'method': method,
      'data': jsonEncode(data),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Process queued requests when online
  Future<void> _processQueue() async {
    if (_queueBox.isNotEmpty && connectivityService.isOnline) {
      for (var queued in _queueBox.values.toList()) {
        await _executeQueuedRequest(Map<String, dynamic>.from(queued));
      }
      await _queueBox.clear();
    }
  }

  Future<void> _executeQueuedRequest(Map<String, dynamic> queued) async {
    final method = queued['method'] as String;
    final data = jsonDecode(queued['data'] as String) as Map<String, dynamic>;
    switch (method) {
      case 'registerUser':
        final user = User.fromJson(data);
        await registerUser(user);
        break;
      case 'loginUser':
        final email = data['email'] as String;
        final password = data['password'] as String;
        await loginUser(email, password);
        break;
    // Add more methods as needed
    }
  }

  // Manual sync method for "Sync" or "Reload" button
  Future<void> syncData() async {
    if (!connectivityService.isOnline) {
      throw Exception('No internet connection to sync');
    }
    await _processQueue();
    await fetchWarehouses(forceRefresh: true);
    await getCurrentUser(forceRefresh: true);
    if (kDebugMode) {
      debugPrint('Data synced with MongoDB');
    }
  }

  Future<List<Warehouse>> fetchWarehouses({bool forceRefresh = false}) async {
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

    // Return cached data if offline and not forcing refresh
    if (!connectivityService.isOnline && !forceRefresh && _warehouseBox.isNotEmpty) {
      return _warehouseBox.values
          .map((json) => Warehouse.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    try {
      if (!connectivityService.isOnline) {
        await _queueRequest('fetchWarehouses', {});
        throw Exception('Offline: Data queued for sync');
      }


      final response = await http.get(Uri.parse('$baseUrl/furniture'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final warehouses = data.map((json) => Warehouse.fromJson(json as Map<String, dynamic>)).toList();
        // Cache the data
        await _warehouseBox.clear();
        for (var warehouse in warehouses) {
          await _warehouseBox.add(warehouse.toJson());
        }
        return warehouses;
      } else {
        throw Exception('Failed to load warehouses: ${response.statusCode}');
      }
    } catch (e) {
      if (!connectivityService.isOnline) throw Exception('Offline: Using cached data');
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
      if (!connectivityService.isOnline) {
        throw Exception('Offline: Cannot fetch warehouse details');
      }

      final response = await http.get(Uri.parse('$baseUrl/furniture/$id'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Warehouse.fromJson(json as Map<String, dynamic>);
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
      if (!connectivityService.isOnline) {
        await _queueRequest('registerUser', user.toJson());
        throw Exception('Offline: Registration queued for sync');
      }

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
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final newUser = User(
          id: responseData['id'] ?? 'unknown',
          fullName: responseData['fullName'] ?? user.fullName,
          email: responseData['email'] ?? user.email,
        );
        await _userBox.put('currentUser', newUser.toJson());
        return newUser;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw errorData['message'] ?? 'Registration error: ${response.statusCode}';
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
      if (!connectivityService.isOnline) {
        await _queueRequest('loginUser', {'email': email, 'password': password});
        throw Exception('Offline: Login queued for sync');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final user = User.fromJson(data['user'] as Map<String, dynamic>);
        await _userBox.put('currentUser', user.toJson());
        return data;
      } else {
        String errorMessage = 'Login failed';
        try {
          final errorResponse = json.decode(response.body) as Map<String, dynamic>;
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<User> getCurrentUser({bool forceRefresh = false}) async {
    if (devMode) {
      await Future.delayed(Duration(milliseconds: 500));
      return User(
        id: 'mock-user-id',
        fullName: 'Amir Syrimbetov',
        email: 'Tima7700@inbox.ru',
        role: 'Administrator',
      );
    }

    // Return cached user if offline and not forcing refresh
    if (!connectivityService.isOnline && !forceRefresh && _userBox.containsKey('currentUser')) {
      return User.fromJson(Map<String, dynamic>.from(_userBox.get('currentUser')));
    }

    try {
      if (!connectivityService.isOnline) {
        throw Exception('Offline: Using cached user data');
      }

      final String token = 'mock-jwt-token-for-development'; // Replace with actual token retrieval
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final user = User.fromJson(json);
        await _userBox.put('currentUser', user.toJson());
        return user;
      } else {
        throw Exception('Failed to load current user: ${response.statusCode}');
      }
    } catch (e) {
      if (!connectivityService.isOnline) throw Exception('Offline: Using cached user data');
      throw Exception('Error fetching current user: $e');
    }
  }

  Future<void> logout() async {
    if (devMode) {
      await Future.delayed(Duration(milliseconds: 500));
      return;
    }

    try {
      if (!connectivityService.isOnline) {
        throw Exception('Offline: Logout will be completed when online');
      }

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
      await _userBox.delete('currentUser');
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}