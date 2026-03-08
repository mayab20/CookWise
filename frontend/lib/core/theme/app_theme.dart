import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    brightness: Brightness.light,
    scaffoldBackgroundColor:AppColors.warmCream,

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.mainColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: AppColors.secondaryColor,
      ),
    ),

    iconTheme: const IconThemeData(
      color: AppColors.grey,
      size: 24,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.mainColor,
      titleTextStyle: TextStyle(
        fontFamily: 'Pacifico',
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: AppColors.warmCream,
      ),
    ),

    cardColor: AppColors.white,
    primaryColor: AppColors.grey,
  );
}
