import 'package:flutter/material.dart';
import 'package:frontend/models/shopping_list.dart';
import 'package:frontend/services/shopping_list_service.dart';

class ShoppingListViewModel extends ChangeNotifier {
  List<ShoppingListItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ShoppingListItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ShoppingListService shoppingListService;

  ShoppingListViewModel({required this.shoppingListService});

  Future<void> fetchShoppingList(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await shoppingListService.getShoppingList(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(ShoppingListItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newItem = await shoppingListService.addShoppingListItem(item);
      _items.add(newItem);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCompleted(ShoppingListItem item) async {
    try {
      final updatedItem = await shoppingListService.updateShoppingListItem(
        item.id,
        {'isCompleted': !item.isCompleted}
      );
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await shoppingListService.deleteShoppingListItem(itemId);
      _items.removeWhere((i) => i.id == itemId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}