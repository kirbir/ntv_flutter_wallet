import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        // E L E V A T E D - B U T T O N
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color.fromARGB(255, 90, 86, 62),
            foregroundColor: Colors.white,
            shadowColor: const Color.fromARGB(255, 51, 49, 36),
            elevation: 5,
          ),
        ),
        // C A R D S
        cardTheme: CardTheme(
          surfaceTintColor: Colors.transparent,
          color: Colors.transparent,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: const Color.fromARGB(255, 0, 130, 89),

        ),
        primarySwatch: Colors.grey,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimary,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: AppColors.gray500),
          labelStyle: TextStyle(color: AppColors.textPrimary),
        ),
        brightness: Brightness.dark,
        canvasColor: AppColors.surfaceDark,
        colorScheme: const ColorScheme.dark(
          secondary: Color.fromARGB(255, 122, 101, 28),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.warning,
          unselectedItemColor: AppColors.gray500,
          selectedIconTheme: IconThemeData(
            color: AppColors.warning,
            size: 28,
          ),
          unselectedIconTheme: IconThemeData(
            color: AppColors.gray500,
            size: 24,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.grey,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.grey),
          labelStyle: TextStyle(color: Colors.white),
        ),
        canvasColor: Colors.white,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          secondary: Colors.grey,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.gray600,
          selectedIconTheme: IconThemeData(
            color: AppColors.primaryBlue,
            size: 28,
          ),
          unselectedIconTheme: IconThemeData(
            color: AppColors.gray600,
            size: 24,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      );
}
