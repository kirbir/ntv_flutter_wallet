import 'package:flutter/material.dart';

class PageTheme {
  final EdgeInsets padding;
  const PageTheme({
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  });
}

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final LinearGradient pageGradient;
  final Color? listTileBackground;
  final Color? listTileIconColor;
  final Color? listTileTitleColor;
  final Color? listTileTrailingColor;
  final BorderRadius? listTileBorderRadius;
  final EdgeInsets? listTileMargin;
  final PageTheme pageTheme;

  CustomThemeExtension({
    required this.pageGradient,
    this.listTileBackground,
    this.listTileIconColor,
    this.listTileTitleColor,
    this.listTileTrailingColor,
    this.listTileBorderRadius = const BorderRadius.all(Radius.circular(12)),
    this.listTileMargin = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    this.pageTheme = const PageTheme(),
  });

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    LinearGradient? pageGradient,
    Color? listTileBackground,
    Color? listTileIconColor,
    Color? listTileTitleColor,
    Color? listTileTrailingColor,
    BorderRadius? listTileBorderRadius,
    EdgeInsets? listTileMargin,
  }) {
    return CustomThemeExtension(
      pageGradient: pageGradient ?? this.pageGradient,
      listTileBackground: listTileBackground ?? this.listTileBackground,
      listTileIconColor: listTileIconColor ?? this.listTileIconColor,
      listTileTitleColor: listTileTitleColor ?? this.listTileTitleColor,
      listTileTrailingColor: listTileTrailingColor ?? this.listTileTrailingColor,
      listTileBorderRadius: listTileBorderRadius ?? this.listTileBorderRadius,
      listTileMargin: listTileMargin ?? this.listTileMargin,
      pageTheme: this.pageTheme,
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
    return CustomThemeExtension(
      pageGradient: pageGradient,
      listTileBackground: Color.lerp(listTileBackground, other.listTileBackground, t),
      listTileIconColor: Color.lerp(listTileIconColor, other.listTileIconColor, t),
      listTileTitleColor: Color.lerp(listTileTitleColor, other.listTileTitleColor, t),
      listTileTrailingColor: Color.lerp(listTileTrailingColor, other.listTileTrailingColor, t),
      listTileBorderRadius: BorderRadius.lerp(listTileBorderRadius, other.listTileBorderRadius, t),
      listTileMargin: EdgeInsets.lerp(listTileMargin, other.listTileMargin, t),
      pageTheme: this.pageTheme,
    );
  }

  static CustomThemeExtension dark = CustomThemeExtension(
    pageGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1A1A1A),
        Color(0xFF2D1F3D),
      ],
    ),
    listTileBackground: const Color(0xFF2D2D2D),
    listTileIconColor: const Color(0xFF9E9E9E),
    listTileTitleColor: Colors.white,
    listTileTrailingColor: const Color(0xFF757575),
    listTileBorderRadius: const BorderRadius.all(Radius.circular(12)),
    listTileMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  );

  static CustomThemeExtension light = CustomThemeExtension(
    pageGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF5F5F5),
        Color(0xFFE1D9E8),
      ],
    ),
    listTileBackground: Colors.white,
    listTileIconColor: const Color(0xFF757575),
    listTileTitleColor: const Color(0xFF212121),
    listTileTrailingColor: const Color(0xFFBDBDBD),
    listTileBorderRadius: const BorderRadius.all(Radius.circular(12)),
    listTileMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  );
}