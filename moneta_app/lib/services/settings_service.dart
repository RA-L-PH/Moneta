import 'package:hive_flutter/hive_flutter.dart';

/// Persistent settings service using Hive for runtime configuration
class SettingsService {
  static const String _boxName = 'moneta_settings';
  static const String _nvidiaApiKey = 'nvidia_api_key';
  static const String _nvidiaModel = 'nvidia_model';
  static const String _nvidiaBaseUrl = 'nvidia_base_url';

  static Box<dynamic>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  static Box<dynamic> get _settingsBox {
    if (_box == null) throw Exception('SettingsService not initialized. Call init() first.');
    return _box!;
  }

  // ─── NVIDIA API Configuration ─────────────────────────────────────────────

  static String get nvidiaApiKey {
    final runtimeKey = _settingsBox.get(_nvidiaApiKey, defaultValue: '') as String;
    if (runtimeKey.isNotEmpty) return runtimeKey;
    // Fallback to compile-time define
    const compileKey = String.fromEnvironment('NVIDIA_API_KEY', defaultValue: '');
    return compileKey;
  }

  static set nvidiaApiKey(String value) {
    _settingsBox.put(_nvidiaApiKey, value);
  }

  static String get nvidiaModel {
    return _settingsBox.get(_nvidiaModel, defaultValue: 'thinkingmachines/inkling') as String;
  }

  static set nvidiaModel(String value) {
    _settingsBox.put(_nvidiaModel, value);
  }

  static String get nvidiaBaseUrl {
    return _settingsBox.get(_nvidiaBaseUrl, defaultValue: 'https://integrate.api.nvidia.com/v1') as String;
  }

  static set nvidiaBaseUrl(String value) {
    _settingsBox.put(_nvidiaBaseUrl, value);
  }

  static bool get isNvidiaConfigured => nvidiaApiKey.isNotEmpty;

  // ─── Generic Settings ──────────────────────────────────────────────────────

  static T get<T>(String key, {required T defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T;
  }

  static Future<void> set<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  static Future<void> clearAll() async {
    await _settingsBox.clear();
  }
}
