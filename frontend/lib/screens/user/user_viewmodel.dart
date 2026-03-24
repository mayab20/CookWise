import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/services/pantry_service.dart';
import 'package:frontend/services/recipe_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/pantry.dart';
import 'package:frontend/models/recipe.dart';
import 'package:frontend/services/api_service.dart';

class UserViewModel extends ChangeNotifier {
  final ApiService apiService;
  final RecipeService recipeService;
  final PantryService pantryService;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  List<PantryItem> _pantryItems = [];
  List<Recipe> _recipes = [];

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PantryItem> get pantryItems => _pantryItems;
  List<Recipe> get recipes => _recipes;

  bool get isAdmin => _user?.role == 'admin';

  UserViewModel({required this.apiService, required this.recipeService, required this.pantryService}) {
    loadUserFromStorage();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_user != null) {
      await Future.wait([fetchPantryItems(), fetchRecipes()]);
    }
  }

  // ---------------- Load user and token from SharedPreferences ----------------
  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null) {
      apiService.setToken(token);

      final userJson = prefs.getString('user');
      print('Stored user JSON: $userJson');
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        print('Parsed user data: $userData');
        _user = User.fromJson(userData);
        print('Created user with ID: ${_user?.id}');
      }
      notifyListeners();
    }
  }

  // ---------------- Login ----------------
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call API
      _user = await apiService.login(email, password);
      print('Login response user: ${_user?.id}');
      print('Full user object: $_user');

      // ⚡ Set token in ApiService
      if (_user?.token != null) {
        apiService.setToken(_user!.token!);
      }

      // Save token and user to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (_user?.token != null) {
        await prefs.setString('jwt_token', _user!.token!);
      }
      await prefs.setString(
        'user',
        jsonEncode({
          '_id': _user!.id,
          'name': _user!.name,
          'email': _user!.email,
          'role': _user!.role,
        }),
      );

      // Load user data after successful login
      await _loadUserData();

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- Register ----------------
  Future<bool> register(User newUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await apiService.register(newUser);

      // ⚡ Set token in ApiService
      if (_user?.token != null) {
        apiService.setToken(_user!.token!);
      }

      // Save token and user to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (_user?.token != null) {
        await prefs.setString('jwt_token', _user!.token!);
      }
      await prefs.setString(
        'user',
        jsonEncode({
          '_id': _user!.id,
          'name': _user!.name,
          'email': _user!.email,
          'role': _user!.role,
        }),
      );

      // Load user data after successful registration
      await _loadUserData();

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- Update Profile ----------------
  Future<void> updateUser(User updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await apiService.updateUser(updatedUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_user!.toUpdateJson()));

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- Logout ----------------
  Future<void> logout() async {
    _user = null;
    _pantryItems = [];
    _recipes = [];
    apiService.clearToken();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user');
    print('Cleared stored user data');

    notifyListeners();
  }

  // ---------------- Pantry ----------------
  Future<void> fetchPantryItems() async {
    if (_user?.id == null) return;
    try {
      _pantryItems = await pantryService.getPantryItems(_user!.id!);
      notifyListeners();
    } catch (e) {
      if (e.toString().contains("401") ||
          e.toString().contains("Invalid token")) {
        await logout();
      } else {
        _errorMessage = e.toString();
      }
      notifyListeners();
    }
  }

  Future<void> deletePantryItem(String itemId) async {
    try {
      await pantryService.deletePantryItem(itemId);
      _pantryItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ---------------- Recipes ----------------
  Future<void> fetchRecipes() async {
    try {
      _recipes = await recipeService.getRecipes();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
