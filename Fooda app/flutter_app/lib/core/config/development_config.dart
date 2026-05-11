/// 應用配置類
/// 用於控制應用行為
class DevelopmentConfig {
  /// 是否為開發模式 - 正式版本設為 false
  static const bool isDevelopmentMode = true;
  
  /// 是否每次都顯示用戶引導（正式版本僅首次顯示）
  static const bool alwaysShowOnboarding = false;
  
  /// 是否顯示調試信息（正式版本關閉）
  static const bool showDebugInfo = false;
  
  /// 是否跳過啟動動畫
  static const bool skipSplashAnimation = false;
  
  /// 正式版本設置
  static const Map<String, dynamic> developmentSettings = {
    'show_onboarding_every_time': false,
    'enable_debug_logs': false,
    'bypass_auth_check': false,
    'use_mock_data': false,
  };
  
  /// 獲取開發設置
  static T getDevelopmentSetting<T>(String key, T defaultValue) {
    if (!isDevelopmentMode) return defaultValue;
    return developmentSettings[key] as T? ?? defaultValue;
  }
}