import 'package:flutter/material.dart';
import 'package:frontend/models/recipe.dart';
import 'package:frontend/services/recipe_service.dart';

class RecipesViewModel extends ChangeNotifier {
  final RecipeService recipeService;

  RecipesViewModel({required this.recipeService});

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRecipes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recipes = await recipeService.getRecipes();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newRecipe = await recipeService.addRecipe(recipe);
      _recipes.add(newRecipe);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedRecipe = await recipeService.updateRecipe(recipe);
      final index = _recipes.indexWhere((r) => r.id == updatedRecipe.id);
      if (index != -1) {
        _recipes[index] = updatedRecipe;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await recipeService.deleteRecipe(recipeId);
      _recipes.removeWhere((r) => r.id == recipeId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Recipe> searchByTitle(String query) {
    return _recipes
        .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Recipe> filterByCategory(String category) {
    return _recipes.where((r) => r.category == category).toList();
  }

  List<Recipe> filterByCuisine(String cuisine) {
    return _recipes.where((r) => r.cuisine == cuisine).toList();
  }
}
