import 'package:flutter/material.dart';
import 'package:frontend/screens/home/home_viewmodel.dart';
import 'package:frontend/screens/pantry/pantry_viewmodel.dart';
import 'package:frontend/services/item_service.dart';
import 'package:frontend/services/pantry_service.dart';
import 'package:frontend/services/recipe_service.dart';
import 'package:frontend/services/shopping_list_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/screens/user/user_viewmodel.dart';
import 'package:frontend/core/theme/colors.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/auth_page.dart';

void main() {
  final baseUrl = 'http://localhost:5000';
  runApp(
    MultiProvider(
      providers: [
  Provider<ApiService>(
    create: (_) => ApiService(baseUrl: baseUrl),
  ),

  Provider<ItemService>(
    create: (context) => ItemService(context.read<ApiService>()),
  ),

  Provider<RecipeService>(
    create: (context) => RecipeService(context.read<ApiService>()),
  ),

  Provider<PantryService>(
    create: (context) => PantryService(context.read<ApiService>()),
  ),

  Provider<ShoppingListService>(
    create: (context) => ShoppingListService(context.read<ApiService>()),
  ),

  ChangeNotifierProxyProvider3<
      ApiService,
      RecipeService,
      PantryService,
      UserViewModel>(
    create: (context) => UserViewModel(
      apiService: context.read<ApiService>(),
      recipeService: context.read<RecipeService>(),
      pantryService: context.read<PantryService>(),
    ),
    update: (_, api, recipeService, pantryService, vm) =>
        vm ??
        UserViewModel(
          apiService: api,
          recipeService: recipeService,
          pantryService: pantryService,
        ),
  ),

  ChangeNotifierProxyProvider2<ApiService, RecipeService, HomeViewModel>(
    create: (context) =>
        HomeViewModel(recipeService: context.read<RecipeService>()),
    update: (_, api, recipeService, vm) =>
        vm ?? HomeViewModel(recipeService: recipeService),
  ),

  ChangeNotifierProxyProvider3<
      ApiService,
      PantryService,
      UserViewModel,
      PantryViewModel>(
    create: (context) => PantryViewModel(
      pantryService: context.read<PantryService>(),
      userViewModel: context.read<UserViewModel>(),
    ),
    update: (_, api, pantryService, userVM, pantryVM) =>
        pantryVM ??
        PantryViewModel(
          pantryService: pantryService,
          userViewModel: userVM,
        ),
  ),
],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(AppColors.mainColor.toARGB32(), <int, Color>{
          50: AppColors.mainColor.withAlpha(25),
          100: AppColors.mainColor.withAlpha(51),
          200: AppColors.mainColor.withAlpha(76),
          300: AppColors.mainColor.withAlpha(102),
          400: AppColors.mainColor.withAlpha(127),
          500: AppColors.mainColor,
          600: AppColors.mainColor.withAlpha(178),
          700: AppColors.mainColor.withAlpha(204),
          800: AppColors.mainColor.withAlpha(229),
          900: AppColors.mainColor,
        }),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.mainColor,
          primary: AppColors.mainColor,
          secondary: AppColors.secondaryColor,
        ),
      ),
      home: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
          if (userViewModel.user != null) {
            return  const HomeScreen();
          } else {
            return const AuthPage();
          }
        },
      ),
      routes: {
        "/auth": (context) => const AuthPage(),
        "/home": (context) => const HomeScreen(),
      },
    );
  }
}
