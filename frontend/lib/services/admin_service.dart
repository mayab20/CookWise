import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/admin_stats.dart';
import 'package:frontend/models/recipe.dart';

class AdminService {
  final ApiService api;
  AdminService(this.api);

  Future<AdminStats> getAdminStats() async {
    final response = await http.get(
      Uri.parse('${api.baseUrl}/admin/stats'),
      headers: api.headers,
    );

    if (response.statusCode == 200) {
      return AdminStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<Recipe>> getAdminRecipes() async {
    final response = await http.get(
      Uri.parse('${api.baseUrl}/admin/recipes'),
      headers: api.headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch admin recipes: ${response.body}');
    }
  }

  Future<void> deleteAdminRecipe(String recipeId) async {
    final response = await http.delete(
      Uri.parse('${api.baseUrl}/admin/recipes/$recipeId'),
      headers: api.headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete recipe: ${response.body}');
    }
  }
}
