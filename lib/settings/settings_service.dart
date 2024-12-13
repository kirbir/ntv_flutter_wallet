import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsService {

  Future<ThemeMode> themeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    return ThemeMode.values[themeIndex];
  }


  Future<void> updateThemeMode(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', theme.index);
  }


}
