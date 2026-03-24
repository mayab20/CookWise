import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/shopping_list.dart';

class ShoppingListService {
  final ApiService api;
  ShoppingListService(this.api);

  Future<List<ShoppingListItem>> getShoppingList(String userId) async {
    final response = await http.get(
      Uri.parse('${api.baseUrl}/shopping-list/$userId'),
      headers: api.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => ShoppingListItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch shopping list: ${response.body}');
    }
  }

  Future<ShoppingListItem> addShoppingListItem(ShoppingListItem item) async {
    final response = await http.post(
      Uri.parse('${api.baseUrl}/shopping-list'),
      headers: api.authHeaders,
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 201) {
      return ShoppingListItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add shopping list item: ${response.body}');
    }
  }

  Future<ShoppingListItem> updateShoppingListItem(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    final response = await http.put(
      Uri.parse('${api.baseUrl}/shopping-list/$itemId'),
      headers: api.authHeaders,
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return ShoppingListItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update shopping list item: ${response.body}');
    }
  }

  Future<void> deleteShoppingListItem(String itemId) async {
    final response = await http.delete(
      Uri.parse('${api.baseUrl}/shopping-list/$itemId'),
      headers: api.authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete shopping list item: ${response.body}');
    }
  }
}
