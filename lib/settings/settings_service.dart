import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  // Add methods to save and load avatar data
  Future<void> saveAvatarData(Map<String, dynamic> avatarData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatarData', jsonEncode(avatarData));
  }

  Future<Map<String, dynamic>> loadAvatarData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? avatarDataString = prefs.getString('avatarData');
    if (avatarDataString != null) {
      return jsonDecode(avatarDataString) as Map<String, dynamic>;
    }
    return {}; // Return empty map if no data saved
  }
}
