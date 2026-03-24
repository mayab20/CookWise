import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:frontend/screens/home/home_viewmodel.dart';
import 'package:frontend/screens/user/user_viewmodel.dart';
import '../../widgets/recipe_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVM = context.read<HomeViewModel>();
      final userVM = context.read<UserViewModel>();
      homeVM.loadRecipes();
      if (userVM.user?.id != null) {
        homeVM.loadFavorites(userVM.user!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, homeVM, child) {
        if (homeVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeVM.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${homeVM.errorMessage}'),
                ElevatedButton(
                  onPressed: () => homeVM.loadRecipes(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Sticky header with greeting and search
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Organize. Cook wiser!",
                    style: TextStyle(
                      fontFamily: 'Pacifico',
                      fontSize: 36,
                      color: AppColors.mainColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "What would you like to cook today?",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  Center(
                    child: SizedBox(
                      width: 400,
                      child: TextField(
                        onChanged: (value) => homeVM.searchRecipes(value),
                        decoration: InputDecoration(
                          hintText: "Search recipes, ingredients...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: homeVM.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => homeVM.clearSearch(),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: homeVM.searchQuery.isNotEmpty
                    ? _buildSearchResults(homeVM)
                    : _buildRecipeSections(homeVM),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults(HomeViewModel homeVM) {
    if (homeVM.recipes.isEmpty) {
      return const Center(
        child: Text(
          'No recipes found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    return RecipeSection(
      title: 'Search Results (${homeVM.recipes.length})',
      recipes: homeVM.recipes,
    );
  }

  Widget _buildRecipeSections(HomeViewModel homeVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecipeSection(
          title: "Recommended for you",
          recipes: homeVM.recommendedRecipes,
        ),
        const SizedBox(height: 40),

        RecipeSection(
          title: "Quick & Easy (Under 30 min)",
          recipes: homeVM.quickRecipes,
        ),
        const SizedBox(height: 40),

        RecipeSection(
          title: "Breakfast",
          recipes: homeVM.getRecipesByCategory("Breakfast"),
        ),
        const SizedBox(height: 40),

        RecipeSection(
          title: "Lunch",
          recipes: homeVM.getRecipesByCategory("Lunch"),
        ),
        const SizedBox(height: 40),

        RecipeSection(
          title: "Dinner",
          recipes: homeVM.getRecipesByCategory("Dinner"),
        ),
        const SizedBox(height: 40),

        RecipeSection(
          title: "Desserts",
          recipes: homeVM.getRecipesByCategory("Dessert"),
        ),
      ],
    );
  }
}
