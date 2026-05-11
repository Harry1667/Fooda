import 'package:shared_preferences/shared_preferences.dart';

/// 應用配置類
/// 管理 API 金鑰、設定和初始化
class AppConfig {
  static late SharedPreferences _prefs;
  
  // API 配置 - 對應 PHP 版本的 env.php
  static const String geminiApiKey = 'AIzaSyAc3-UB_ZZ_siVNGCqJuy3vz5fWQxtPiw8';
  static const String usdaApiKey = 'pGMQcAgrPtdumSJX8w8vK3bYrERN8P6pzS58B8Zf';
  
  // API URLs - 使用本地 PHP API 作為代理
  static const String baseApiUrl = 'http://localhost:8000/api'; // 您的 PHP 服務器地址
  static const String analyzeApiUrl = '$baseApiUrl/analyze.php';
  static const String nutritionApiUrl = '$baseApiUrl/nutrition.php';
  static const String membershipApiUrl = '$baseApiUrl/membership.php';
  
  // Gemini AI 直接 API URL（用於 analyzeImageDirect 方法）
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';
  
  // USDA API URLs（對應 PHP 版本）
  static const String usdaSearchUrl = 'https://api.nal.usda.gov/fdc/v1/foods/search';
  static const String usdaDetailUrl = 'https://api.nal.usda.gov/fdc/v1/food';
  
  // 應用設定
  static const int maxUploadSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['image/jpeg', 'image/png', 'image/webp'];
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Gemini 配置
  static const Map<String, dynamic> geminiConfig = {
    'temperature': 0.2,
    'maxOutputTokens': 8192, // 增加到 8192，避免思考鏈佔用過多 Token 導致截斷
    // 注意：不設置 responseMimeType，讓 Gemini 返回 text/plain
    // 然後手動解析 JSON，避免 parts 為空的問題
  };
  
  // USDA 配置
  static const Map<String, dynamic> usdaConfig = {
    'pageSize': 1
  };
  
  // 錯誤代碼
  static const Map<String, String> errorCodes = {
    'ANALYZE_BAD_FILE': 'ANALYZE_BAD_FILE',
    'ANALYZE_MODEL_FORMAT': 'ANALYZE_MODEL_FORMAT',
    'ANALYZE_INTERNAL': 'ANALYZE_INTERNAL',
    'USDA_NOT_FOUND': 'USDA_NOT_FOUND',
    'USDA_BAD_PARAMS': 'USDA_BAD_PARAMS',
    'USDA_INTERNAL': 'USDA_INTERNAL'
  };
  
  /// 初始化應用配置
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// 獲取 SharedPreferences 實例
  static SharedPreferences get prefs => _prefs;
  
  /// 獲取用戶設定
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }
  
  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }
  
  static String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }
  
  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }
  
  /// 設定用戶設定
  static Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }
  
  static Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }
  
  static Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }
  
  static Future<bool> setDouble(String key, double value) {
    return _prefs.setDouble(key, value);
  }
  
  /// 清除所有設定
  static Future<bool> clear() {
    return _prefs.clear();
  }
  
  /// 移除特定設定
  static Future<bool> remove(String key) {
    return _prefs.remove(key);
  }
}

/// 應用常數
class AppConstants {
  // 本地存儲鍵值
  static const String keyFirstLaunch = 'first_launch';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyMembershipLevel = 'membership_level';
  static const String keyAiQuotaUsed = 'ai_quota_used';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyCalorieGoal = 'calorie_goal';
  static const String keyCarbsGoal = 'carbs_goal';
  static const String keyProteinGoal = 'protein_goal';
  static const String keyFatGoal = 'fat_goal';
  static const String keySodiumGoal = 'sodium_goal';
  static const String keyFiberGoal = 'fiber_goal';
  static const String keyAge = 'age';
  static const String keyHeight = 'height';
  static const String keyWeight = 'weight';
  static const String keyGender = 'gender';
  static const String keyActivityLevel = 'activity_level';
  static const String keyBreakfastTime = 'breakfast_time';
  static const String keyLunchTime = 'lunch_time';
  static const String keyDinnerTime = 'dinner_time';
  static const String keyConsecutiveDays = 'consecutive_days';
  static const String keyLastRecordDate = 'last_record_date';
  static const String keyTutorialCompleted = 'tutorial_completed';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  
  // 預設值
  static const int defaultCalorieGoal = 2000;
  static const int defaultCarbsGoal = 250;
  static const int defaultProteinGoal = 150;
  static const int defaultFatGoal = 65;
  static const int defaultSodiumGoal = 2300;
  static const int defaultFiberGoal = 25;
  static const int defaultAge = 25;
  static const int defaultHeight = 175;
  static const int defaultWeight = 70;
  static const String defaultGender = '男';
  static const String defaultActivityLevel = '中等';
  static const String defaultBreakfastTime = '09:00';
  static const String defaultLunchTime = '12:00';
  static const String defaultDinnerTime = '18:00';
  
  // 會員等級
  static const String membershipFree = 'free';
  static const String membershipPremium = 'premium';
  static const String membershipPremiumPlus = 'premium_plus';
  
  // 餐點類型
  static const String mealBreakfast = 'breakfast';
  static const String mealMorningSnack = 'morning-snack';
  static const String mealLunch = 'lunch';
  static const String mealAfternoonTea = 'afternoon-tea';
  static const String mealDinner = 'dinner';
  static const String mealLateNight = 'late-night';
}