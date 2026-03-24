import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/recipe.dart';

class RecipeService{
  final ApiService api;
  RecipeService(this.api);

  Future<List<Recipe>> getRecipes() async {
    final response = await http.get(
      Uri.parse('${api.baseUrl}/recipes'),
      headers: api.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch recipes');
    }
  }

  Future<Recipe> addRecipe(Recipe recipe) async {
    final response = await http.post(
      Uri.parse('${api.baseUrl}/recipes'),
      headers: api.headers,
      body: jsonEncode(recipe.toJson()),
    );

    if (response.statusCode == 201) {
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add recipe: ${response.body}');
    }
  }

  Future<Recipe> updateRecipe(Recipe recipe) async {
    final response = await http.put(
      Uri.parse('${api.baseUrl}/recipes/${recipe.id}'),
      headers: api.headers,
      body: jsonEncode(recipe.toJson()),
    );

    if (response.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update recipe: ${response.body}');
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    final response = await http.delete(
      Uri.parse('${api.baseUrl}/recipes/$recipeId'),
      headers: api.headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete recipe: ${response.body}');
    }
  }

  // FAVORITES
  Future<List<Recipe>> getFavoriteRecipes(String userId) async {
    final response = await http.get(
      Uri.parse('${api.baseUrl}/favorites/$userId'),
      headers: api.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch favorite recipes: ${response.body}');
    }
  }

  Future<void> addToFavorites(String userId, String recipeId) async {
    final response = await http.post(
      Uri.parse('${api.baseUrl}/favorites'),
      headers: api.authHeaders,
      body: jsonEncode({'userId': userId, 'recipeId': recipeId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add to favorites: ${response.body}');
    }
  }

  Future<void> removeFromFavorites(String userId, String recipeId) async {
    final response = await http.delete(
      Uri.parse('${api.baseUrl}/favorites/$userId/$recipeId'),
      headers: api.authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from favorites: ${response.body}');
    }
  }

  // TODAY'S RECIPES
  Future<List<Recipe>> getTodaysRecipes(String userId) async {
    final response = await http.get(
      Uri.parse('${api.baseUrl}/todays-recipes/$userId'),
      headers: api.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch today\'s recipes: ${response.body}');
    }
  }

  Future<void> addToTodaysRecipes(String userId, String recipeId) async {
    final response = await http.post(
      Uri.parse('${api.baseUrl}/todays-recipes'),
      headers: api.authHeaders,
      body: jsonEncode({'userId': userId, 'recipeId': recipeId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add to today\'s recipes: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getMissingIngredients(
    String userId,
  ) async {
    final response = await http.get(
      Uri.parse('${api.baseUrl}/todays-recipes/$userId/missing-ingredients'),
      headers: api.authHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch missing ingredients: ${response.body}');
    }
  }

  Future<void> removeFromTodaysRecipes(String userId, String recipeId) async {
    final response = await http.delete(
      Uri.parse('${api.baseUrl}/todays-recipes/$userId/$recipeId'),
      headers: api.authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to remove from today\'s recipes: ${response.body}',
      );
    }
  }
}
