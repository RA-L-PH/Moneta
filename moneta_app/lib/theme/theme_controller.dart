import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  ThemeController() {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = SettingsService.get<String>('theme_mode', defaultValue: 'light');
    final newMode = _themeModeFromString(saved);
    if (newMode != _mode) {
      _mode = newMode;
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _save();
    notifyListeners();
  }

  Future<void> set(ThemeMode mode) async {
    _mode = mode;
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    await SettingsService.set<String>('theme_mode', _mode.name);
  }

  static ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.light;
    }
  }
}
