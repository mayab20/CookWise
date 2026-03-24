import 'package:flutter/material.dart';
import 'package:frontend/models/pantry.dart';
import 'package:frontend/screens/user/user_viewmodel.dart';
import '../../services/pantry_service.dart';

class PantryViewModel extends ChangeNotifier {
  List<PantryItem> _pantryItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PantryItem> get pantryItems => _pantryItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final PantryService pantryService; 
  final UserViewModel userViewModel;

  PantryViewModel({required this.pantryService, required this.userViewModel});

  Future<void> fetchPantryItems(String userId) async {
    print('fetchPantryItems called for userId: $userId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pantryItems = await pantryService.getPantryItems(userId);
      print('Fetched ${_pantryItems.length} pantry items');
    } catch (e) {
      print('Error fetching pantry items: $e');

      if (e.toString().contains("AUTH_EXPIRED")) {
        // logout user
        await userViewModel.logout();
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPantryItem(PantryItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newItem = await pantryService.addPantryItem(item);
      _pantryItems.add(newItem);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePantryItem(PantryItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedItem = await pantryService.updatePantryItem(item);
      final index = _pantryItems.indexWhere((i) => i.id == updatedItem.id);
      if (index != -1) {
        _pantryItems[index] = updatedItem;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePantryItem(String itemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await pantryService.deletePantryItem(itemId);
      _pantryItems.removeWhere((i) => i.id == itemId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<PantryItem> get expiringItems {
    final now = DateTime.now();
    return _pantryItems.where((item) {
      if (item.expirationDate == null) return false;
      final daysUntilExpiry = item.expirationDate!.difference(now).inDays;
      return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
    }).toList();
  }

  List<PantryItem> get expiredItems {
    final now = DateTime.now();
    return _pantryItems.where((item) {
      if (item.expirationDate == null) return false;
      return item.expirationDate!.isBefore(now);
    }).toList();
  }

  int get expiringItemsCount => expiringItems.length;
  int get expiredItemsCount => expiredItems.length;
}
