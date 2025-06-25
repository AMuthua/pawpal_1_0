// lib/theme/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'themeMode';

  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  ThemeService() {
    loadThemeMode();
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedTheme = prefs.getString(_themeModeKey);

    if (storedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (storedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system; // Fallback to system if not found or invalid
    }
    notifyListeners(); // Notify listeners after loading
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return; // No change needed

    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString().split('.').last); // Store 'light', 'dark', or 'system'
    notifyListeners(); // Notify all listening widgets
  }
}