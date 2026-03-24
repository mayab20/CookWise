import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/item.dart';

class ItemService {
  final ApiService api;
  ItemService(this.api);

  Future<List<Item>> getItems() async {
    final response = await http.get(
      Uri.parse('${api.baseUrl}/items'),
      headers: api.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch items');
    }
  }

  Future<Item> addItem(Item item) async {
    final response = await http.post(
      Uri.parse('${api.baseUrl}/items'),
      headers: api.headers,
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 201) {
      return Item.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add item: ${response.body}');
    }
  }

  Future<void> deleteItem(String itemId) async {
    final response = await http.delete(
      Uri.parse('${api.baseUrl}/items/$itemId'),
      headers: api.headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete item: ${response.body}');
    }
  }

  Future<Item> updateItem(
    String itemId,
    String name,
    String category,
    List<String> units,
  ) async {
    final response = await http.put(
      Uri.parse('${api.baseUrl}/items/$itemId'),
      headers: api.headers,
      body: jsonEncode({'name': name, 'category': category, 'units': units}),
    );

    if (response.statusCode == 200) {
      return Item.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update item: ${response.body}');
    }
  }
}
