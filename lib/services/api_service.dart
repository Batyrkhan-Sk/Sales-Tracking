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
        Warehouse(id: '1', name: 'Mock A', imageUrl: '', description: '', dimensions: {}, price: 199.0),
        Warehouse(id: '2', name: 'Mock B', imageUrl: '', description: '', dimensions: {}, price: 299.0),
      ];
    }

    if (!connectivityService.isOnline && !forceRefresh && _warehouseBox.isNotEmpty) {
      return _warehouseBox.values.map((e) => Warehouse.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    final response = await http.get(Uri.parse('$baseUrl/furniture'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final warehouses = data.map((e) => Warehouse.fromJson(e)).toList();
      await _warehouseBox.clear();
      for (var w in warehouses) {
        await _warehouseBox.add(w.toJson());
      }
      return warehouses;
    } else {
      throw Exception('Failed to load warehouses');
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
      throw Exception('Login failed');
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
      return User(id: 'mock-id', fullName: 'Amir', email: 'amir@mock.com');
    }

    final authBox = await Hive.openBox<AuthData>('auth');
    final auth = authBox.get('session');
    if (auth == null) throw Exception('Not logged in');

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {'Authorization': 'Bearer ${auth.token}'},
    );

    if (response.statusCode == 200) {
      final user = User.fromJson(json.decode(response.body));
      await _userBox.put('currentUser', user.toJson());
      return user;
    } else {
      throw Exception('Failed to fetch user');
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
  Future<bool> updateProfile({required String fullName, String? password}) async {
    if (devMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }

    final authBox = await Hive.openBox<AuthData>('auth');
    final auth = authBox.get('session');
    if (auth == null) throw Exception('Not logged in');

    final response = await http.patch(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
      },
      body: jsonEncode({
        'fullName': fullName,
        'password': password ?? '',
      }),
    );

    if (response.statusCode == 200) {
      final updatedUser = User.fromJson(json.decode(response.body));
      await _userBox.put('currentUser', updatedUser.toJson());

      // Обновим сессию, если нужно
      await authBox.put(
        'session',
        auth.copyWith(fullName: updatedUser.fullName),
      );

      return true;
    } else {
      throw Exception('Failed to update profile');
    }
  }
}
