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
            backgroundColor: const Color.fromARGB(255, 122, 53, 118),
            foregroundColor: Colors.white,
            shadowColor: const Color.fromARGB(255, 51, 49, 36),
            elevation: 5,
          ),
        ),
          outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
             side: const BorderSide(color: Color.fromARGB(255, 141, 52, 149), width: 2,style: BorderStyle.solid),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
             
            ),
            // backgroundColor: const Color.fromARGB(255, 122, 53, 118),
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),

            // shadowColor: const Color.fromARGB(255, 51, 49, 36),
            // elevation: 5,
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            borderSide: const BorderSide(color: AppColors.focused, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: const TextStyle(color: AppColors.textPrimary),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          floatingLabelStyle: const TextStyle(color: AppColors.focused),
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
        scaffoldBackgroundColor: Colors.transparent,

        // Card theme
        cardTheme: CardTheme(
          color: AppColors.cardLight,
          elevation: 2,
          shadowColor: AppColors.primaryBlue.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.primaryBlue.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),

        // AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryBlue,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.primaryBlue),
          titleTextStyle: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Input decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.primaryBlue.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.primaryBlue.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: const TextStyle(color: AppColors.gray700),
          hintStyle: const TextStyle(color: AppColors.gray500),
          floatingLabelStyle: const TextStyle(color: AppColors.primaryBlue),
        ),

        // Color scheme
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryBlue,
          secondary: AppColors.secondaryBlue,
          surface: AppColors.surfaceLight,
          background: AppColors.backgroundLight,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.gray900,
          onBackground: AppColors.gray900,
        ),

        // Text theme
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.gray900,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: AppColors.gray900,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: AppColors.gray800,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(color: AppColors.gray800),
          bodyMedium: TextStyle(color: AppColors.gray700),
          labelLarge: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Icon theme
        iconTheme: const IconThemeData(
          color: AppColors.primaryBlue,
          size: 24,
        ),

        // Bottom navigation
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.gray600,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        ),

        // Extensions
        extensions: [
          CustomThemeExtension(
            pageGradient: AppColors.lightThemeGradient,
          ),
        ],
      );
}
