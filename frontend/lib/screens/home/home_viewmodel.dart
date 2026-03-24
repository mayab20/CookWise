import 'package:flutter/material.dart';
import 'package:frontend/models/recipe.dart';
import 'package:frontend/services/recipe_service.dart';

class HomeViewModel extends ChangeNotifier {
  final RecipeService recipeService;
  HomeViewModel({required this.recipeService});
  
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  List<String> _favoriteRecipeIds = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  
  List<Recipe> get recipes => _searchQuery.isEmpty ? _recipes : _filteredRecipes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  List<String> get favoriteRecipeIds => _favoriteRecipeIds;
  

  List<Recipe> getRecipesByCategory(String category) {
    return _recipes.where((recipe) => recipe.category == category).toList();
  }
  

  List<Recipe> get quickRecipes {
    return _recipes.where((recipe) => recipe.readyInMinutes <= 30).toList();
  }
  

  List<Recipe> get recommendedRecipes {
    return _recipes.take(6).toList();
  }
  
  void searchRecipes(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredRecipes = [];
    } else {
      _filteredRecipes = _recipes.where((recipe) => 
        recipe.title.toLowerCase().contains(query.toLowerCase()) ||
        recipe.ingredients.any((ingredient) => 
          ingredient.item.name.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    }
    notifyListeners();
  }
  
  void clearSearch() {
    _searchQuery = '';
    _filteredRecipes = [];
    notifyListeners();
  }
  
  bool isFavorite(String recipeId) {
    return _favoriteRecipeIds.contains(recipeId);
  }
  
  Future<void> toggleFavorite(String userId, String recipeId) async {
    try {
      if (_favoriteRecipeIds.contains(recipeId)) {
        await recipeService.removeFromFavorites(userId, recipeId);
        _favoriteRecipeIds.remove(recipeId);
      } else {
        await recipeService.addToFavorites(userId, recipeId);
        _favoriteRecipeIds.add(recipeId);
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadFavorites(String userId) async {
    try {
      final favoriteRecipes = await recipeService.getFavoriteRecipes(userId);
      _favoriteRecipeIds = favoriteRecipes.map((recipe) => recipe.id).toList();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadRecipes() async {
    _setLoading(true);
    _setError(null);
    try {
      _recipes = await recipeService.getRecipes();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}