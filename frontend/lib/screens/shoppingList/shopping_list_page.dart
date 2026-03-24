import 'package:flutter/material.dart';
import 'package:frontend/services/item_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/shopping_list.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:frontend/screens/shoppingList/shopping_list_viewmodel.dart';
import 'package:frontend/screens/user/user_viewmodel.dart';
import 'package:frontend/widgets/searchable_item_dropdown.dart';
import 'package:frontend/services/shopping_list_service.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  ShoppingListViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shoppingListService = context.read<ShoppingListService>();
      setState(() {
        _viewModel = ShoppingListViewModel(
          shoppingListService: shoppingListService,
        );
      });
      _loadShoppingList();
    });
  }

  void _loadShoppingList() {
    final userViewModel = context.read<UserViewModel>();
    if (userViewModel.user?.id != null) {
      _viewModel?.fetchShoppingList(userViewModel.user!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Shopping List',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Shopping List Items
            Expanded(
              child: _viewModel == null
                  ? const Center(child: CircularProgressIndicator())
                  : AnimatedBuilder(
                      animation: _viewModel!,
                      builder: (context, child) {
                        if (_viewModel!.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (_viewModel!.errorMessage != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error,
                                  size: 64,
                                  color: Colors.red.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(_viewModel!.errorMessage!),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadShoppingList,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (_viewModel!.items.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  '🛒 Ready to Shop! 🛒',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mainColor,
                                    fontFamily: 'Pacifico',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Add items to your shopping list',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: _viewModel!.items.length,
                          itemBuilder: (context, index) {
                            return _buildShoppingListItem(
                              _viewModel!.items[index],
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingListItem(ShoppingListItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (value) => _viewModel?.toggleCompleted(item),
          activeColor: AppColors.mainColor,
        ),
        title: Text(
          item.itemName,
          style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            color: item.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Text('${item.quantity.toInt()} ${item.unit}'),
        trailing: IconButton(
          onPressed: () => _viewModel?.deleteItem(item.id),
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<UserViewModel>(
        builder: (context, userViewModel, child) => AddItemToShoppingListDialog(
          onItemAdded: (item) async {
            final messenger = ScaffoldMessenger.of(context);
            await _viewModel?.addItem(item);
            messenger.showSnackBar(
              const SnackBar(content: Text('Item added to shopping list!')),
            );
          },
          userViewModel: userViewModel,
        ),
      ),
    );
  }
}

class AddItemToShoppingListDialog extends StatefulWidget {
  final Function(ShoppingListItem) onItemAdded;
  final UserViewModel userViewModel;

  const AddItemToShoppingListDialog({
    super.key,
    required this.onItemAdded,
    required this.userViewModel,
  });

  @override
  State<AddItemToShoppingListDialog> createState() =>
      _AddItemToShoppingListDialogState();
}

class _AddItemToShoppingListDialogState
    extends State<AddItemToShoppingListDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  List<Item> _availableItems = [];
  Item? _selectedItem;
  String? _selectedUnit;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableItems();
  }

  Future<void> _loadAvailableItems() async {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final itemService = context.read<ItemService>();
      _availableItems = await itemService.getItems();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error loading items: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Text(
                      'Add to Shopping List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Item Selection
                const Text(
                  'Select Item',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SearchableItemDropdown(
                        items: _availableItems,
                        selectedItem: _selectedItem,
                        onChanged: (value) {
                          setState(() {
                            _selectedItem = value;
                            _selectedUnit = value?.units.isNotEmpty == true
                                ? value!.units.first
                                : null;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Please select an item';
                          return null;
                        },
                        hintText: 'Search or select an item',
                      ),
                const SizedBox(height: 16),

                // Quantity and Unit Row
                Row(
                  children: [
                    // Quantity
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintText: 'Enter quantity',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter quantity';
                              }
                              if (double.tryParse(value) == null ||
                                  double.parse(value) <= 0) {
                                return 'Please enter a valid quantity';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Unit
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unit',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintText: 'Select unit',
                            ),
                            items:
                                _selectedItem?.units.map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList() ??
                                [],
                            onChanged: (value) {
                              setState(() => _selectedUnit = value);
                            },
                            validator: (value) {
                              if (value == null) return 'Please select a unit';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add to List'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.userViewModel.user?.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    final item = ShoppingListItem(
      id: '',
      userId: widget.userViewModel.user!.id!,
      itemId: _selectedItem!.id,
      quantity: double.parse(_quantityController.text),
      unit: _selectedUnit ?? 'pcs',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.onItemAdded(item);
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}
