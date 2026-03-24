import 'package:flutter/material.dart';
import 'package:frontend/models/recipe.dart';
import 'recipe_card.dart';

class RecipeSection extends StatelessWidget {
  final String title;
  final List<Recipe> recipes;

  const RecipeSection({
    super.key,
    required this.title,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal scroller
        SizedBox(
          height: 280,
          child: recipes.isEmpty
              ? Center(
                  child: Text(
                    'No recipes available',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return RecipeCard(recipe: recipe);
                  },
                ),
        ),
      ],
    );
  }
}
