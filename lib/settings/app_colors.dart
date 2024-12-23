import 'package:flutter/material.dart';

class AppColors {
  // Primary dark backgrounds
  static const backgroundDark = Color(0xFF121212);
  static const surfaceDark = Color(0xFF1E1E1E);
  static const cardDark = Color(0xFF252525);
  
  // Blues
  static const primaryBlue = Color(0xFF1a237e);
  static const secondaryBlue = Color(0xFF0d47a1);
  static const tertiaryBlue = Color(0xFF01579b);
  
  // Grays
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFEEEEEE);
  static const gray300 = Color(0xFFE0E0E0);
  static const gray400 = Color(0xFFBDBDBD);
  static const gray500 = Color(0xFF9E9E9E);
  static const gray600 = Color(0xFF757575);
  static const gray700 = Color(0xFF616161);
  static const gray800 = Color(0xFF424242);
  static const gray900 = Color(0xFF212121);

  // Gradients
  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryBlue,
      secondaryBlue,
      tertiaryBlue,
    ],
  );

  // Text colors
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF);  // 70% white
  static const textHint = Color(0x80FFFFFF);       // 50% white

  // Status colors
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFFF5252);
  static const warning = Color(0xFFFFC107);
  static const info = Color(0xFF2196F3);
}