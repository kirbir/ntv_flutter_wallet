import 'package:flutter/material.dart';

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final LinearGradient pageGradient;

  CustomThemeExtension({
    required this.pageGradient,
  });

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    LinearGradient? pageGradient,
  }) {
    return CustomThemeExtension(
      pageGradient: pageGradient ?? this.pageGradient,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(
    ThemeExtension<CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return this;
  }
}