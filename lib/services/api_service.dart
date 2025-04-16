// lib/services/api_service.dart
import 'dart:convert';
import "package:http/http.dart" as http;
import '../presentation/models/warehouse.dart';

class ApiService {
  final String baseUrl = 'https://your-api-endpoint.com/api';

  Future<List<Warehouse>> fetchWarehouses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/warehouses'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Warehouse(
          id: json['id'],
          name: json['name'],
          imageUrl: json['image_url'],
          description: json['description'],
        )).toList();
      } else {
        throw Exception('Failed to load warehouses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching warehouses: $e');
    }
  }

  Future<Warehouse> fetchWarehouseDetails(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/warehouses/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Warehouse(
          id: json['id'],
          name: json['name'],
          imageUrl: json['image_url'],
          description: json['description'],
        );
      } else {
        throw Exception('Failed to load warehouse details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching warehouse details: $e');
    }
  }
}