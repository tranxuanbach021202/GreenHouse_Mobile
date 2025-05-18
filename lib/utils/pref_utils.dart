import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  static const String _themeKey = 'app_theme';

  ThemeData getThemeData() {
    final themeString = SharedPreferences.getInstance().then((prefs) {
      return prefs.getString(_themeKey) ?? 'light';
    });
    if (themeString == 'dark') {
      return ThemeData.dark();
    } else {
      return ThemeData.light();
    }
  }

  Future<void> saveThemeData(ThemeData themeData) async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = themeData.brightness == Brightness.dark ? 'dark' : 'light';
    await prefs.setString(_themeKey, themeString);
  }
}
