import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/recipe.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:frontend/screens/user/user_viewmodel.dart';

class RecipeDetailsDialog extends StatefulWidget {
  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const RecipeDetailsDialog({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<RecipeDetailsDialog> createState() => _RecipeDetailsDialogState();
}

class _RecipeDetailsDialogState extends State<RecipeDetailsDialog> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and favorite button
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.recipe.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    widget.onFavoriteToggle();
                  },
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.grey,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recipe image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.recipe.imageUrl ??
                    'https://source.unsplash.com/400x300/?food',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.restaurant,
                      size: 80,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Recipe info
            Row(
              children: [
                Icon(Icons.timer, color: AppColors.secondaryColor, size: 20),
                const SizedBox(width: 8),
                Text('${widget.recipe.readyInMinutes} minutes'),
                const SizedBox(width: 24),
                Icon(Icons.people, color: AppColors.secondaryColor, size: 20),
                const SizedBox(width: 8),
                Text('${widget.recipe.servings ?? 'N/A'} servings'),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            if (widget.recipe.description != null) ...[
              Text(
                widget.recipe.description!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final userVM = context.read<UserViewModel>();
                      final messenger = ScaffoldMessenger.of(context);
                      if (userVM.user?.id != null) {
                        try {
                          await userVM.recipeService.addToTodaysRecipes(
                            userVM.user!.id!,
                            widget.recipe.id,
                          );
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Added to today\'s recipes!'),
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                    icon: const Icon(Icons.today),
                    label: const Text('Cook Today'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ingredients and Steps
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Ingredients'),
                        Tab(text: 'Instructions'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Ingredients tab
                          widget.recipe.ingredients.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text(
                                    'No ingredients available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(top: 16),
                                  itemCount: widget.recipe.ingredients.length,
                                  itemBuilder: (context, index) {
                                    final ingredient =
                                        widget.recipe.ingredients[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        '• ${ingredient.amount} ${ingredient.unit} ${ingredient.item.name}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  },
                                ),
                          // Instructions tab
                          ListView.builder(
                            padding: const EdgeInsets.only(top: 16),
                            itemCount: widget.recipe.steps.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.mainColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.recipe.steps[index],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
