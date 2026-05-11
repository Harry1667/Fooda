import 'package:flutter/foundation.dart';
import 'dart:io';

/// 環境自適應配置
/// 自動根據開發/生產環境選擇正確的 API URL
class EnvConfig {
  // 開發環境配置
  static const String _devMacIP = '192.168.1.104'; // 你的 Mac 電腦 IP（已更新）
  static const String appName = 'Fooda';
  static const String _devPort = '8000';
  
  // 生產環境配置（部署後的域名）
  static const String _prodDomain = 'your-domain.com'; // 替換為實際域名
  
  /// 獲取 API Base URL
  /// 開發環境：http://192.168.1.106:8000/api
  /// 生產環境：https://your-domain.com/api
  static String get apiBaseUrl {
    if (kDebugMode) {
      // Debug 模式（開發中）
      return 'http://$_devMacIP:$_devPort/api';
    } else {
      // Release 模式（生產環境）
      return 'https://$_prodDomain/api';
    }
  }
  
  /// 獲取完整的 API URL
  static String getApiUrl(String endpoint) {
    return '$apiBaseUrl/$endpoint';
  }
  
  /// Analyze API
  static String get analyzeApiUrl => getApiUrl('analyze.php');
  
  /// Nutrition API
  static String get nutritionApiUrl => getApiUrl('nutrition.php');
  
  /// Membership API
  static String get membershipApiUrl => getApiUrl('membership.php');
  
  /// 檢查是否為開發環境
  static bool get isDevelopment => kDebugMode;
  
  /// 檢查是否為生產環境
  static bool get isProduction => kReleaseMode;
  
  /// 獲取環境名稱
  static String get environmentName {
    if (kDebugMode) return '開發環境';
    if (kReleaseMode) return '生產環境';
    return '未知環境';
  }
  
  /// 打印配置信息（僅在開發環境）
  static void printConfig() {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════');
      print('🔧 Fooda Flutter 配置信息');
      print('═══════════════════════════════════════════════');
      debugPrint('🚀 Fooda Config: $environmentName mode (API: $apiBaseUrl)');
      print('🌐 API Base URL: $apiBaseUrl');
      print('🔗 Analyze API: $analyzeApiUrl');
      print('🔗 Nutrition API: $nutritionApiUrl');
      print('🔗 Membership API: $membershipApiUrl');
      print('📱 平台: ${Platform.operatingSystem}');
      print('═══════════════════════════════════════════════');
    }
  }
  
  /// 測試 API 連接
  static Future<bool> testConnection() async {
    try {
      if (kDebugMode) {
        print('🔍 測試 API 連接...');
        print('📡 目標: $analyzeApiUrl');
      }
      
      // 這裡可以添加實際的連接測試
      // 暫時返回 true
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ API 連接測試失敗: $e');
      }
      return false;
    }
  }
}

/// 環境配置助手
/// 提供便捷的靜態方法
class EnvHelper {
  /// 根據環境獲取 API URL
  static String apiUrl(String endpoint) {
    return EnvConfig.getApiUrl(endpoint);
  }
  
  /// 檢查是否可以使用 AI 功能
  /// 在開發環境中，需要確保服務器運行
  static Future<bool> canUseAI() async {
    if (EnvConfig.isDevelopment) {
      // 開發環境：檢查本地服務器
      return await EnvConfig.testConnection();
    }
    // 生產環境：始終可用
    return true;
  }
  
  /// 獲取錯誤提示信息
  static String getConnectionErrorHint() {
    if (EnvConfig.isDevelopment) {
      return '''
連接失敗！請檢查：

1. Mac 電腦的 PHP 服務器是否運行？
   命令：cd Fooda && php -S 0.0.0.0:8000

2. iPhone/模擬器 和 Mac 在同一 WiFi？

3. Mac IP 地址是否正確？
   當前配置：${EnvConfig._devMacIP}
   
   查看實際 IP：
   Mac 終端執行：ifconfig | grep "inet "

4. 防火牆是否阻擋？

測試連接：
在 iPhone Safari 打開：http://${EnvConfig._devMacIP}:${EnvConfig._devPort}
''';
    } else {
      return '網絡連接失敗，請檢查您的網絡連接。';
    }
  }
}

/// 開發環境專用工具
class DevTools {
  /// 更新開發 IP 地址
  /// 如果你的 Mac IP 地址改變了，使用這個方法
  static String? _customIP;
  
  static void setDevIP(String ip) {
    _customIP = ip;
    if (kDebugMode) {
      print('✅ 開發 IP 已更新: $ip');
      EnvConfig.printConfig();
    }
  }
  
  static String get devIP => _customIP ?? EnvConfig._devMacIP;
  
  /// 重置為默認 IP
  static void resetIP() {
    _customIP = null;
    if (kDebugMode) {
      print('✅ 已重置為默認 IP');
    }
  }
}

