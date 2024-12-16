import 'package:flutter/material.dart';

class AppColors {
  static const Color textBlack = Colors.black;
  static const Color textGrey = Colors.grey;
  static const Color white = Colors.white;
  static const Color lightGreyDarkMode = Color(0xFF303030);
  static const Color darkPink = Color(0xFFE91E63);
  static const Color grey2 = Color(0xFFBDBDBD);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    cardTheme: const CardTheme(
      surfaceTintColor: Colors.transparent,
      color: Color.fromARGB(255, 21, 25, 27),
      elevation: 4,
      shadowColor:  Color.fromARGB(255, 113, 188, 218)
    ),
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.textBlack,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: AppColors.textGrey),
          labelStyle: TextStyle(color: AppColors.white),
        ),
        brightness: Brightness.dark,
        canvasColor: AppColors.lightGreyDarkMode,
        colorScheme: ColorScheme.dark(
          secondary: AppColors.darkPink,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      );

  static ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.grey2,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: AppColors.textGrey),
          labelStyle: TextStyle(color: AppColors.white),
        ),
        canvasColor: AppColors.white,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          secondary: AppColors.grey2,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      );
}