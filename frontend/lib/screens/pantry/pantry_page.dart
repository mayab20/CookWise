import 'package:flutter/material.dart';
import 'package:frontend/services/pantry_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/pantry.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:frontend/screens/pantry/pantry_viewmodel.dart';
import 'package:frontend/screens/user/user_viewmodel.dart';
import 'package:frontend/widgets/searchable_item_dropdown.dart';
import 'package:frontend/services/item_service.dart';

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  PantryViewModel? _viewModel;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'vegetables',
    'fruits',
    'meat',
    'poultry',
    'seafood',
    'dairy',
    'eggs',
    'bakery',
    'grains',
    'pasta',
    'rice',
    'canned',
    'frozen',
    'snacks',
    'sweets',
    'spices',
    'seasoning',
    'oils',
    'condiments',
    'sauces',
    'beverages',
    'tea_coffee',
    'nuts_seeds',
    'legumes',
    'breakfast',
    'baking',
    'baby_food',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pantryService = context.read<PantryService>();
      final userViewModel = context.read<UserViewModel>();

      setState(() {
        _viewModel = PantryViewModel(
          pantryService: pantryService,
          userViewModel: userViewModel,
        );
      });
      _loadPantryItems();
    });
  }

  void _loadPantryItems() {
    final userViewModel = context.read<UserViewModel>();
    if (userViewModel.user?.id != null) {
      _viewModel?.fetchPantryItems(userViewModel.user!.id!);
    } else {
      if (_viewModel == null) {
        setState(() {
          _viewModel = PantryViewModel(
            pantryService: context.read<PantryService>(),
            userViewModel: userViewModel,
          );
        });
      }
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
            Row(
              children: [
                const Text(
                  'My Pantry',
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

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search pantry items...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

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
                                  onPressed: _loadPantryItems,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        final filteredItems = _getFilteredItems();

                        if (filteredItems.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.kitchen,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  '🍽️ Your Pantry Awaits! 🍽️',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mainColor,
                                    fontFamily: 'Pacifico',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Stock up smart, cook with heart!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add your first ingredient to start your culinary journey',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.9,
                              ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            return _buildPantryItemCard(filteredItems[index]);
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

  List<PantryItem> _getFilteredItems() {
    if (_viewModel == null) return [];
    return _viewModel!.pantryItems.where((item) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          item.itemName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' ||
          item.itemCategory.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _buildPantryItemCard(PantryItem item) {
    final isLowStock = item.quantity < 5;
    final now = DateTime.now();
    final isExpiringSoon =
        item.expirationDate != null &&
        item.expirationDate!.difference(now).inDays <= 3 &&
        item.expirationDate!.difference(now).inDays >= 0;
    final isExpired =
        item.expirationDate != null && item.expirationDate!.isBefore(now);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showItemDetailsDialog(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.fastfood, size: 40);
                            },
                          ),
                        )
                      : const Icon(Icons.fastfood, size: 40),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                item.itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              GestureDetector(
                onTap: () => _showEditQuantityDialog(item),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory,
                      size: 16,
                      color: isLowStock ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.quantity.toInt()} ${item.unit}',
                      style: TextStyle(
                        color: isLowStock ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),

              if (isExpired) const SizedBox(height: 4),
              if (isExpired)
                Row(
                  children: [
                    Icon(Icons.error, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      'Expired',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

              if (isExpiringSoon && !isExpired) const SizedBox(height: 4),
              if (isExpiringSoon && !isExpired)
                Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      'Expires in ${item.expirationDate!.difference(now).inDays} days',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: () => _updateQuantity(item, item.quantity - 1),
                      icon: const Icon(Icons.remove, size: 16),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: IconButton(
                      onPressed: () => _updateQuantity(item, item.quantity + 1),
                      icon: const Icon(Icons.add, size: 16),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.shade100,
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateQuantity(PantryItem item, double newQuantity) {
    if (newQuantity < 0) return;

    if (newQuantity == 0) {
      _viewModel?.deletePantryItem(item.id);
      return;
    }

    final updatedItem = PantryItem(
      id: item.id,
      userId: item.userId,
      itemId: item.itemId,
      quantity: newQuantity,
      unit: item.unit,
      expirationDate: item.expirationDate,
      imageUrl: item.imageUrl,
      nutrition: item.nutrition,
      createdAt: item.createdAt,
      updatedAt: DateTime.now(),
    );

    _viewModel?.updatePantryItem(updatedItem);
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<UserViewModel>(
        builder: (context, userViewModel, child) => AddItemToPantryDialog(
          onItemAdded: (pantryItem) async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await _viewModel?.addPantryItem(pantryItem);
              _loadPantryItems();
              messenger.showSnackBar(
                const SnackBar(content: Text('Item added successfully!')),
              );
            } catch (e) {
              messenger.showSnackBar(
                SnackBar(content: Text('Error adding item: $e')),
              );
            }
          },
          userViewModel: userViewModel,
        ),
      ),
    );
  }

  void _showEditQuantityDialog(PantryItem item) {
    final controller = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item.itemName} Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity (${item.unit})',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newQuantity = double.tryParse(controller.text);
              if (newQuantity != null && newQuantity >= 0) {
                _updateQuantity(item, newQuantity);
                Navigator.pop(context);
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showItemDetailsDialog(PantryItem item) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Details for ${item.itemName}')));
  }
}

class AddItemToPantryDialog extends StatefulWidget {
  final Function(PantryItem) onItemAdded;
  final UserViewModel userViewModel;

  const AddItemToPantryDialog({
    super.key,
    required this.onItemAdded,
    required this.userViewModel,
  });

  @override
  State<AddItemToPantryDialog> createState() => _AddItemToPantryDialogState();
}

class _AddItemToPantryDialogState extends State<AddItemToPantryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  List<Item> _availableItems = [];
  Item? _selectedItem;
  String? _selectedUnit;
  DateTime? _expirationDate;
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
                Row(
                  children: [
                    const Text(
                      'Add Item to Pantry',
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

                Row(
                  children: [
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
                const SizedBox(height: 16),

                const Text(
                  'Expiration Date (Optional)',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _expirationDate = date);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          _expirationDate != null
                              ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}'
                              : 'Select expiration date',
                          style: TextStyle(
                            color: _expirationDate != null
                                ? Colors.black
                                : Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        if (_expirationDate != null)
                          IconButton(
                            onPressed: () =>
                                setState(() => _expirationDate = null),
                            icon: const Icon(Icons.clear, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

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
                        child: const Text('Add to Pantry'),
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

    final pantryItem = PantryItem(
      id: '',
      userId: widget.userViewModel.user!.id!,
      itemId: _selectedItem!.id,
      quantity: double.parse(_quantityController.text),
      unit: _selectedUnit ?? 'pcs',
      expirationDate: _expirationDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.onItemAdded(pantryItem);
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
