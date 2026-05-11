import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主題提供者
/// 管理應用深色/淺色模式切換，並持久化用戶選擇
class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'app_theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // 如果使用系統模式，根據系統亮度判斷
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  /// 載入保存的主題模式
  Future<void> _loadThemeMode() async {
    if (_initialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeModeKey);
      
      if (savedMode != null) {
        switch (savedMode) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('載入主題模式失敗: $e');
    }
    
    _initialized = true;
  }

  /// 設定主題模式
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String modeString;
      switch (mode) {
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.system:
        default:
          modeString = 'system';
          break;
      }
      await prefs.setString(_themeModeKey, modeString);
    } catch (e) {
      debugPrint('保存主題模式失敗: $e');
    }
  }
  
  /// 切換深色/淺色模式（在 light 和 dark 之間切換，不包含 system）
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

