import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'custom_theme_extension.dart';

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

          color: Colors.blueGrey[900],
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),


        ),
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardDark,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gray700),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gray700),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.warning, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: const TextStyle(color: AppColors.textPrimary),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          floatingLabelStyle: const TextStyle(color: AppColors.warning),
          alignLabelWithHint: true,
          floatingLabelAlignment: FloatingLabelAlignment.center,
        ),
        brightness: Brightness.dark,
        canvasColor: AppColors.surfaceDark,
        colorScheme: const ColorScheme.dark(
          secondary: Color.fromARGB(255, 122, 101, 28),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: AppColors.textPrimary),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
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
        extensions: [
          CustomThemeExtension(
            pageGradient: AppColors.pageGradient,
          ),
        ],
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.gray900,
          elevation: 0,
        ),
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryBlue,
          secondary: AppColors.secondaryBlue,
          background: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.gray900,
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(color: AppColors.gray900),
          bodyLarge: TextStyle(color: AppColors.gray900),
          bodyMedium: TextStyle(color: AppColors.gray700),
        ),
        iconTheme: IconThemeData(
          color: AppColors.primaryBlue,
        ),
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
        ),
      );
}
