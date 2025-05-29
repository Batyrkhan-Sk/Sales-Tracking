// api_service.dart — финальный вариант с Hive для авторизации

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../presentation/models/warehouse.dart';
import '../presentation/models/user.dart';
import '../presentation/models/auth_data.dart';
import 'connectivity_service.dart';

class ApiService {
  final String baseUrl = 'http://13.53.40.246:5000/api';
  final bool devMode = false;

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
      final connService = connectivityService ?? ConnectivityService();
      _instance = ApiService._internal(connectivityService: connService);
    }
    return _instance!;
  }

  ApiService._internal({required this.connectivityService}) {
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _warehouseBox = await Hive.openBox(_warehouseCacheBox);
    _userBox = await Hive.openBox(_userCacheBox);
    _queueBox = await Hive.openBox(_queueBoxName);
  }

  Future<void> _queueRequest(String method, Map<String, dynamic> data) async {
    await _queueBox.add({
      'method': method,
      'data': jsonEncode(data),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

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
    }
  }

  Future<void> syncData() async {
    if (!connectivityService.isOnline) {
      throw Exception('No internet connection to sync');
    }
    await _processQueue();
    await fetchWarehouses(forceRefresh: true);
    await getCurrentUser(forceRefresh: true);
    if (kDebugMode) debugPrint('Data synced');
  }

  Future<List<Warehouse>> fetchWarehouses({bool forceRefresh = false}) async {
    if (devMode) {
      return [
        Warehouse(
          id: '1',
          name: 'Mock Warehouse',
          capacity: 5000,
          currentStock: 1200,
          address: 'Abay 123',
          city: 'Almaty',
          country: 'Kazakhstan',
          latitude: 40.7128,
          longitude: -74.006,
          isActive: true,
        ),
      ];
    }

    final authBox = await Hive.openBox<AuthData>('auth');
    final auth = authBox.get('session');
    if (auth == null) throw Exception('Not logged in');

    if (!connectivityService.isOnline && !forceRefresh && _warehouseBox.isNotEmpty) {
      return _warehouseBox.values
          .map((e) => Warehouse.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/warehouses'),
      headers: {'Authorization': 'Bearer ${auth.token}'},
    );

    if (response.statusCode == 200) {
      debugPrint('[WAREHOUSES OK] ${response.body}');
      try {
        final List<dynamic> data = json.decode(response.body);
        final warehouses = data.map((e) => Warehouse.fromJson(e)).toList();

        await _warehouseBox.clear();
        for (var w in warehouses) {
          await _warehouseBox.add(w.toJson());
        }

        return warehouses;
      } catch (e) {
        throw Exception('JSON parse failed: $e');
      }
    } else {
      debugPrint('[WAREHOUSES ERROR] ${response.statusCode}: ${response.body}');
      throw Exception('Failed to load warehouses: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    if (devMode) {
      return {
        'user': {
          'id': 'mock-id',
          'fullName': 'Mock User',
          'email': email,
        },
        'token': 'mock-token',
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final user = User.fromJson(data['user']);
      final token = data['token'];

      final authBox = await Hive.openBox<AuthData>('auth');
      await authBox.put('session', AuthData(
        token: token,
        userId: user.id ?? '',
        fullName: user.fullName,
        email: user.email,
        pin: '',
      ));

      return data;
    } else {
      debugPrint('Login failed: ${response.statusCode} - ${response.body}');
      throw Exception('Login failed: ${response.statusCode} - ${response.body}');
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
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  Future<User> getCurrentUser({bool forceRefresh = false}) async {
    if (devMode) {
      return User(
        id: 'mock-id',
        fullName: 'Amir Syrymbetov',
        email: 'amir@mock.com',
        role: 'moderator',
      );
    }

    final authBox = await Hive.openBox<AuthData>('auth');
    final auth = authBox.get('session');
    if (auth == null) throw Exception('Not logged in');

    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: {'Authorization': 'Bearer ${auth.token}'},
    );

    debugPrint('[RAW BODY] ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final userJson = data['user']; // ⬅️ это важно!
      final user = User.fromJson(userJson);

      await _userBox.put('currentUser', user.toJson());
      return user;
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> logout() async {
    final authBox = await Hive.openBox<AuthData>('auth');
    await authBox.delete('session');
    await _userBox.delete('currentUser');
  }

  Future<bool> isLoggedIn() async {
    final authBox = await Hive.openBox<AuthData>('auth');
    final auth = authBox.get('session');
    return auth != null && auth.token.isNotEmpty;
  }
  Future<bool> updateProfile({String? fullName, String? password}) async {
    if (devMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }

    final authBox = await Hive.openBox<AuthData>('auth');
    final auth = authBox.get('session');
    if (auth == null) throw Exception('Not logged in');

    final Map<String, dynamic> body = {};
    if (fullName != null && fullName.trim().isNotEmpty) {
      body['fullName'] = fullName.trim();
    }
    if (password != null && password.trim().isNotEmpty) {
      body['password'] = password.trim();
    }

    if (body.isEmpty) {
      throw Exception('Nothing to update');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final updatedUser = User.fromJson(json.decode(response.body));
      await _userBox.put('currentUser', updatedUser.toJson());
      await authBox.put('session', auth.copyWith(fullName: updatedUser.fullName));
      return true;
    } else {
      throw Exception('Failed to update profile');
    }
  }
  Future<void> addFurnitureItem(Map<String, dynamic> furnitureItem) async {
    final authBox = await Hive.openBox<AuthData>('auth');
    final auth = authBox.get('session');
    if (auth == null) throw Exception('Not logged in');

    final response = await http.post(
      Uri.parse('$baseUrl/furniture'),
      headers: {
        'Authorization': 'Bearer ${auth.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(furnitureItem),
    );

    if (response.statusCode == 201) {
      debugPrint('[ADD FURNITURE] Successfully added item');
    } else {
      debugPrint('[ADD FURNITURE] Error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to add furniture: ${response.body}');
    }
  }
  Future<List<Map<String, dynamic>>> fetchFurnitureItems() async {
    final authBox = await Hive.openBox<AuthData>('auth');
    final auth = authBox.get('session');
    if (auth == null) throw Exception('Not logged in');

    final response = await http.get(
      Uri.parse('$baseUrl/furniture'),
      headers: {
        'Authorization': 'Bearer ${auth.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch furniture: ${response.statusCode} ${response.body}');
    }
  }
  Future<Map<String, dynamic>> scanFurniture(String code) async {
    if (devMode) {
      // Вернём мок-данные, если включён режим разработки
      await Future.delayed(Duration(milliseconds: 500));
      return {
        'id': 'mock-id',
        'name': 'Mock Furniture',
        'description': 'This is a mock furniture item from QR code.',
        'price': 199.99,
        'dimensions': {'length': 100, 'width': 50, 'height': 60},
      };
    }

    try {
      final response = await http.post(
        Uri.parse('http://$baseUrl:5000/api/furniture/scan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['furniture'] != null) {
          return data['furniture'];
        } else {
          throw Exception('Furniture not found or response invalid');
        }
      } else {
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при сканировании: $e');
      throw Exception('Ошибка при сканировании: $e');
    }
  }
  Future<void> createWarehouse({
    required String name,
    required String address,
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    required int capacity,
    required String managerId,
  }) async {
    final authBox = await Hive.openBox<AuthData>('auth');
    final auth = authBox.get('session');
    if (auth == null) throw Exception('Not logged in');

    final response = await http.post(
      Uri.parse('$baseUrl/warehouses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
      },
      body: jsonEncode({
        "name": name,
        "location": {
          "address": address,
          "city": city,
          "country": country,
          "coordinates": {
            "lat": latitude,
            "lng": longitude,
          }
        },
        "capacity": capacity,
        "managerId": managerId,
      }),
    );

    if (response.statusCode != 201) {
      debugPrint('[WAREHOUSE ERROR] ${response.body}');
      throw Exception('Failed to create warehouse');
    }

    debugPrint('[WAREHOUSE CREATED] ${response.body}');
  }
}

