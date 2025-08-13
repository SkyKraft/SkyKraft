import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  
  final _isDarkMode = false.obs;
  final _themeMode = ThemeMode.system.obs;
  
  bool get isDarkMode => _isDarkMode.value;
  ThemeMode get themeMode => _themeMode.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString('theme_mode') ?? 'system';
      final savedIsDark = prefs.getBool('is_dark_mode') ?? false;
      
      _isDarkMode.value = savedIsDark;
      
      switch (savedThemeMode) {
        case 'light':
          _themeMode.value = ThemeMode.light;
          break;
        case 'dark':
          _themeMode.value = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode.value = ThemeMode.system;
          break;
      }
    } catch (e) {
      // Fallback to system theme if there's an error
      _themeMode.value = ThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      switch (mode) {
        case ThemeMode.light:
          _themeMode.value = ThemeMode.light;
          _isDarkMode.value = false;
          await prefs.setString('theme_mode', 'light');
          await prefs.setBool('is_dark_mode', false);
          break;
        case ThemeMode.dark:
          _themeMode.value = ThemeMode.dark;
          _isDarkMode.value = true;
          await prefs.setString('theme_mode', 'dark');
          await prefs.setBool('is_dark_mode', true);
          break;
        case ThemeMode.system:
          _themeMode.value = ThemeMode.system;
          // Get system brightness
          final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
          _isDarkMode.value = brightness == Brightness.dark;
          await prefs.setString('theme_mode', 'system');
          await prefs.setBool('is_dark_mode', _isDarkMode.value);
          break;
      }
      
      Get.changeThemeMode(_themeMode.value);
    } catch (e) {
      debugPrint('Error setting theme mode: $e');
    }
  }
  
  void toggleTheme() {
    if (_themeMode.value == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (_themeMode.value == ThemeMode.dark) {
      setThemeMode(ThemeMode.system);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
  
  String getThemeModeString() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  IconData getThemeModeIcon() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
