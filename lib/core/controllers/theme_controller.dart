import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for managing app theme (light/dark mode)
class ThemeController extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  SharedPreferences? _prefs;

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Initialize the theme controller and load saved theme preference
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadThemeMode();
  }

  /// Load theme mode from shared preferences
  void _loadThemeMode() {
    if (_prefs == null) return;
    final savedTheme = _prefs!.getString(_themeKey);
    _isDarkMode = savedTheme == 'dark';
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemeMode();
    notifyListeners();
  }

  /// Set theme mode explicitly
  Future<void> setThemeMode(bool isDark) async {
    if (_isDarkMode == isDark) return;
    _isDarkMode = isDark;
    await _saveThemeMode();
    notifyListeners();
  }

  /// Save theme mode to shared preferences
  Future<void> _saveThemeMode() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    await _prefs!.setString(_themeKey, _isDarkMode ? 'dark' : 'light');
  }

  /// Get current brightness
  Brightness get brightness => _isDarkMode ? Brightness.dark : Brightness.light;
}
