import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/pantry.dart';

class PantryService{
  final ApiService api;
  PantryService(this.api);

  Future<List<PantryItem>> getPantryItems(String userId) async {
    final response = await http.get(
      Uri.parse('${api.baseUrl}/pantry/$userId'),
      headers: api.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print(api.authHeaders);
      return data.map((json) => PantryItem.fromJson(json)).toList();
    } 
    if (response.statusCode == 401) {
      // token expired or invalid
      throw Exception("AUTH_EXPIRED");
    }else {
      throw Exception(
        'Failed to fetch pantry items: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<PantryItem> addPantryItem(PantryItem item) async {
    final response = await http.post(
      Uri.parse('${api.baseUrl}/pantry'),
      headers: api.authHeaders,
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 201) {
      return PantryItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add pantry item: ${response.body}');
    }
  }

  Future<PantryItem> updatePantryItem(PantryItem item) async {
    final response = await http.put(
      Uri.parse('${api.baseUrl}/pantry/${item.id}'),
      headers: api.authHeaders,
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 200) {
      return PantryItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update pantry item: ${response.body}');
    }
  }

  Future<void> deletePantryItem(String itemId) async {
    final response = await http.delete(
      Uri.parse('${api.baseUrl}/pantry/$itemId'),
      headers: api.authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete pantry item: ${response.body}');
    }
  }

   
}