import 'package:flutter/material.dart';
import 'package:frontend/screens/shoppingList/shopping_list_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/user/user_viewmodel.dart';
import 'package:frontend/models/shopping_list.dart';
import 'package:frontend/core/theme/colors.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileCard(context),
            const SizedBox(height: 24),
            _buildExpirationAlerts(context),
            const SizedBox(height: 24),
            _buildTodaysRecipes(context),
            const SizedBox(height: 24),
            _buildFavoriteRecipes(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, vm, child) {
        final user = vm.user;
        if (user == null) {
          return const Center(child: Text('No user data'));
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.mainColor,
                    child: Text(
                      (user.name?.isNotEmpty == true)
                          ? user.name![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? 'No name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user.email ?? 'No email',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              _buildSettingItem(
                icon: Icons.person,
                title: 'Edit Profile',
                subtitle: 'Update your profile information',
                onTap: () => _showEditProfileDialog(context),
              ),
              const Divider(),
              _buildSettingItem(
                icon: Icons.security,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () => _showPasswordDialog(context),
              ),
              const Divider(),
              _buildSettingItem(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                onTap: () => _logout(context, vm),
                isDestructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpirationAlerts(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, vm, child) {
        return FutureBuilder(
          future: vm.pantryService.getPantryItems(vm.user?.id ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox();
            }

            final pantryItems = snapshot.data ?? [];
            final now = DateTime.now();

            final expiringItems = pantryItems.where((item) {
              if (item.expirationDate == null) return false;
              final daysUntilExpiry = item.expirationDate!
                  .difference(now)
                  .inDays;
              return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
            }).toList();

            final expiredItems = pantryItems.where((item) {
              if (item.expirationDate == null) return false;
              return item.expirationDate!.isBefore(now);
            }).toList();

            if (expiringItems.isEmpty && expiredItems.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'All items are fresh!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Expiration Alerts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (expiredItems.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Expired Items (${expiredItems.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...expiredItems
                              .take(3)
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '• ${item.itemName} (expired ${_getDaysAgo(item.expirationDate!)} ago)',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                          if (expiredItems.length > 3)
                            Text(
                              '... and ${expiredItems.length - 3} more',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (expiringItems.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Expiring Soon (${expiringItems.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...expiringItems
                              .take(3)
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '• ${item.itemName} (expires in ${item.expirationDate!.difference(now).inDays} days)',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                          if (expiringItems.length > 3)
                            Text(
                              '... and ${expiringItems.length - 3} more',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getDaysAgo(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    return days == 1 ? '1 day' : '$days days';
  }

  Widget _buildTodaysRecipes(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, vm, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.today, color: AppColors.mainColor, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Today\'s Recipes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder(
                future: vm.recipeService.getTodaysRecipes(vm.user?.id ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final todaysRecipes = snapshot.data ?? [];

                  if (todaysRecipes.isEmpty) {
                    return const Text(
                      'No recipes planned for today. Add some recipes to get cooking!',
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: todaysRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = todaysRecipes[index];
                            return Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      recipe.imageUrl ??
                                          'https://source.unsplash.com/80x60/?food',
                                      width: 80,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 80,
                                              height: 60,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.restaurant,
                                                size: 20,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Text(
                                      recipe.title,
                                      style: const TextStyle(fontSize: 10),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMissingIngredients(vm),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMissingIngredients(UserViewModel vm) {
    return FutureBuilder(
      future: vm.recipeService.getMissingIngredients(vm.user?.id ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox();
        }

        final missingIngredients = snapshot.data as List<Map<String, dynamic>>;

        if (missingIngredients.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'You have all ingredients for today\'s recipes!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Missing Ingredients:',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...missingIngredients
                  .take(3)
                  .map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${ingredient['needed']} ${ingredient['unit']} ${ingredient['itemName']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              if (missingIngredients.length > 3)
                Text(
                  '... and ${missingIngredients.length - 3} more',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              const SizedBox(height: 12),
              const Text(
                'Add missing ingredients to shopping list?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () =>
                    _addMissingToShoppingList(context, vm, missingIngredients),
                icon: const Icon(Icons.add_shopping_cart, size: 16),
                label: const Text('Add to Shopping List'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoriteRecipes(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, vm, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Favorite Recipes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder(
                future: vm.recipeService.getFavoriteRecipes(vm.user?.id ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final favoriteRecipes = snapshot.data ?? [];

                  if (favoriteRecipes.isEmpty) {
                    return const Text(
                      'No favorite recipes yet. Start exploring recipes and add them to your favorites!',
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  return SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: favoriteRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = favoriteRecipes[index];
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  recipe.imageUrl ??
                                      'https://source.unsplash.com/80x60/?food',
                                  width: 80,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 60,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.restaurant,
                                        size: 20,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  recipe.title,
                                  style: const TextStyle(fontSize: 10),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.mainColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.mainColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text('Profile editing coming soon...'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: AppColors.mainColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text('Password change coming soon...'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addMissingToShoppingList(
    BuildContext context,
    UserViewModel uvm,
    List<Map<String, dynamic>> missingIngredients,
  ) async {
    final svm = context.read<ShoppingListViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    if (uvm.user?.id == null) return;

    try {
      for (final ingredient in missingIngredients) {
        await svm.shoppingListService.addShoppingListItem(
          ShoppingListItem(
            id: '',
            userId: uvm.user!.id!,
            itemId: ingredient['itemId'],
            quantity: ingredient['needed'].toDouble(),
            unit: ingredient['unit'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Added ${missingIngredients.length} ingredients to shopping list!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error adding ingredients: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _logout(BuildContext context, UserViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              vm.logout();
              Navigator.pushReplacementNamed(context, '/auth');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
