import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../config/development_config.dart';

/// 應用工具類
/// 提供應用管理功能
class DevelopmentUtils {
  
  /// 是否為開發模式
  static bool get isDevelopment {
    bool isDev = false;
    assert(() {
      isDev = true;
      return true;
    }());
    return isDev;
  }

  /// 重置應用 - 清除所有數據
  static Future<bool> resetApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 獲取所有存儲的 keys
      final keys = prefs.getKeys();
      debugPrint('🔍 清除前的 keys (${keys.length} 項): $keys');
      
      // 逐一清除特定數據類型以確保完全清除
      await _clearUserProfileData(prefs);
      await _clearNutritionGoals(prefs);
      await _clearMealRecords(prefs);
      await _clearAppSettings(prefs);
      await _clearOnboardingData(prefs);
      await _clearAuthData(prefs);
      
      // 最後清除所有剩餘數據
      await prefs.clear();
      
      // 多次驗證清除結果
      await Future.delayed(const Duration(milliseconds: 200));
      final remainingKeys = prefs.getKeys();
      debugPrint('🧹 清除後的 keys (${remainingKeys.length} 項): $remainingKeys');
      
      // 如果還有剩餘數據，強制清除
      if (remainingKeys.isNotEmpty) {
        debugPrint('⚠️ 發現剩餘數據，進行強制清除...');
        for (final key in remainingKeys) {
          await prefs.remove(key);
        }
      }
      
      // 最終檢查
      await Future.delayed(const Duration(milliseconds: 100));
      final finalKeys = prefs.getKeys();
      debugPrint('✅ 最終檢查 keys (${finalKeys.length} 項): $finalKeys');
      
      return finalKeys.isEmpty;
    } catch (e) {
      debugPrint('❌ 重置應用失敗: $e');
      return false;
    }
  }

  /// 清除用戶個人資料數據
  static Future<void> _clearUserProfileData(SharedPreferences prefs) async {
    final profileKeys = [
      // 基本個人資料
      'user_height',
      'user_weight', 
      'user_age',
      'user_gender',
      'user_activity_level',
      'user_profile_completed',
      'profile_data',
      'personal_info',
      // 引導流程中設置的資料
      'height',
      'weight',
      'age',
      'gender',
      'activity_level',
      'bmi',
      // profile_provider 使用的 keys
      'profile_userName',
      'profile_height',
      'profile_weight',
      'profile_age',
      'profile_gender',
      'profile_activityLevel',
      'profile_initialized',
      // 身體數據
      'body_data',
    ];
    
    for (final key in profileKeys) {
      await prefs.remove(key);
    }
    debugPrint('🧑 用戶個人資料數據已清除 (${profileKeys.length} 項)');
  }

  /// 清除營養目標數據  
  static Future<void> _clearNutritionGoals(SharedPreferences prefs) async {
    final nutritionKeys = [
      // 卡路里目標
      'user_calorie_goal',
      'user_use_ai_goal',
      'daily_calorie_goal',
      'calorie_goal',
      'home_calorie_goal',
      'nutrition_card_calorie_target',
      'profile_calorie_goal',
      'profile_nutrition_target',
      'profile_caloriesGoal',
      'nutrition_goals',
      'custom_calorie_goal',
      'recommended_calories',
      'use_ai_goal',
      // 營養素目標
      'protein_goal',
      'carbs_goal',
      'fat_goal',
      'daily_protein_goal',
      'daily_carbs_goal',
      'daily_fat_goal',
      'profile_proteinGoal',
      'profile_carbsGoal',
      'profile_fatGoal',
      'profile_fiberGoal',
      'profile_sodiumGoal',
      // 用餐時間設置
      'profile_breakfastTime',
      'profile_lunchTime',
      'profile_dinnerTime',
      // 通知設置
      'profile_notificationsEnabled',
    ];
    
    for (final key in nutritionKeys) {
      await prefs.remove(key);
    }
    debugPrint('🎯 營養目標數據已清除 (${nutritionKeys.length} 項)');
  }

  /// 清除餐飲記錄數據
  static Future<void> _clearMealRecords(SharedPreferences prefs) async {
    final mealKeys = [
      'meal_records',
      'nutrition_data',
      'food_history',
      'recent_foods',
      'saved_meals',
    ];
    
    // 清除已知的餐飲相關 keys
    for (final key in mealKeys) {
      await prefs.remove(key);
    }
    
    // 查找並清除日期格式的餐飲記錄 (例如: meals_2024-01-15)
    final allKeys = prefs.getKeys();
    final dateRelatedKeys = allKeys.where((key) => 
      key.startsWith('meals_') || 
      key.startsWith('nutrition_') ||
      key.startsWith('food_') ||
      key.contains('meal') ||
      key.contains('nutrition')
    ).toList();
    
    for (final key in dateRelatedKeys) {
      await prefs.remove(key);
    }
    
    debugPrint('🍽️ 餐飲記錄數據已清除 (${mealKeys.length + dateRelatedKeys.length} 項)');
  }

  /// 清除應用設置數據
  static Future<void> _clearAppSettings(SharedPreferences prefs) async {
    final settingsKeys = [
      // 語言設置
      'selected_language',
      'app_language',
      'language_code',
      'locale',
      // 主題設置
      'theme_mode',
      'fooda_darkMode',
      'dark_mode',
      // 通知設置
      'notification_enabled',
      'notifications_enabled',
      // 其他設置
      'app_settings',
    ];
    
    for (final key in settingsKeys) {
      await prefs.remove(key);
    }
    debugPrint('⚙️ 應用設置數據已清除 (${settingsKeys.length} 項)');
  }

  /// 清除引導相關數據
  static Future<void> _clearOnboardingData(SharedPreferences prefs) async {
    final onboardingKeys = [
      'onboarding_completed',
      'onboarding_completed_date',
      'first_launch_completed',
      'tutorial_completed',
      'user_onboarding_step',
      'intro_completed',
      'onboarding_step',
      'skip_onboarding',
    ];
    
    for (final key in onboardingKeys) {
      await prefs.remove(key);
    }
    debugPrint('🚀 引導相關數據已清除 (${onboardingKeys.length} 項)');
  }

  /// 清除認證相關數據
  static Future<void> _clearAuthData(SharedPreferences prefs) async {
    final authKeys = [
      // 用戶認證信息
      'user_id',
      'user_name',
      'user_email',
      'user_photo_url',
      'user_provider',
      'user_logged_in',
      // 登入時間
      'login_time',
      'last_login',
      'loginTime',
      // Token 相關（如果有）
      'access_token',
      'refresh_token',
      'id_token',
      // 會員相關
      'membership_type',
      'membership_expiry',
      'is_premium',
    ];
    
    for (final key in authKeys) {
      await prefs.remove(key);
    }
    debugPrint('🔐 認證相關數據已清除 (${authKeys.length} 項)');
  }

  /// 檢查是否為第一次啟動
  static Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !prefs.containsKey('first_launch_completed');
    } catch (e) {
      debugPrint('檢查首次啟動失敗: $e');
      return true;
    }
  }

  /// 標記首次啟動完成
  static Future<void> markFirstLaunchCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_launch_completed', true);
    } catch (e) {
      debugPrint('標記首次啟動完成失敗: $e');
    }
  }
  
  /// 重置用戶引導狀態（完整重置，清除所有數據）
  static Future<bool> resetOnboardingState() async {
    try {
      debugPrint('🔄 開始完整重置應用...');
      
      // 調用完整的重置功能
      final success = await resetApp();
      
      if (success) {
        debugPrint('✅ 應用完整重置成功！所有數據已清除');
      } else {
        debugPrint('⚠️ 應用重置完成，但可能有部分數據未清除');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ 重置引導狀態失敗: $e');
      return false;
    }
  }
  
  /// 顯示應用選項對話框（正式版本已禁用）
  static Future<void> showDevelopmentOptions(BuildContext context) async {
    // 正式版本中禁用開發選項
    return;
    
    // 以下代碼在正式版本中被註釋
    /*
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🛠️ 應用選項'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.orange),
              title: const Text('重置用戶引導'),
              subtitle: const Text('清除引導狀態，重新顯示引導'),
              onTap: () async {
                Navigator.of(context).pop();
                await _resetOnboardingWithConfirmation(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('清除所有數據'),
              subtitle: const Text('重置應用到初始狀態'),
              onTap: () async {
                Navigator.of(context).pop();
                await _clearAllDataWithConfirmation(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('顯示調試信息'),
              subtitle: const Text('查看當前應用狀態'),
              onTap: () {
                Navigator.of(context).pop();
                _showDebugInfo(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
    */
  }
  
  /// 重置引導確認對話框
  static Future<void> _resetOnboardingWithConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔄 確認重置'),
        content: const Text('確定要重置用戶引導嗎？這會清除所有引導相關的數據。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('確定重置'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      final success = await resetOnboardingState();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '✅ 引導狀態已重置，請重新啟動應用' : '❌ 重置失敗',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  /// 清除所有數據確認對話框
  static Future<void> _clearAllDataWithConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ 危險操作'),
        content: const Text(
          '這會清除所有應用數據，包括：\n'
          '• 用戶引導狀態\n'
          '• 用戶個人資料\n'
          '• 飲食記錄\n'
          '• 應用設置\n\n'
          '此操作不可恢復！',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('確定清除'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 所有數據已清除，請重新啟動應用'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 清除失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// 顯示調試信息
  static Future<void> _showDebugInfo(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final debugInfo = StringBuffer();
      debugInfo.writeln('📱 應用狀態信息\n');
      
      debugInfo.writeln('🔧 開發配置:');
      debugInfo.writeln('- 開發模式: ${DevelopmentConfig.isDevelopmentMode}');
      debugInfo.writeln('- 總是顯示引導: ${DevelopmentConfig.alwaysShowOnboarding}');
      debugInfo.writeln('- 顯示調試信息: ${DevelopmentConfig.showDebugInfo}\n');
      
      debugInfo.writeln('💾 本地存儲 (${keys.length} 項):');
      for (final key in keys) {
        final value = prefs.get(key);
        debugInfo.writeln('- $key: $value');
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🐛 調試信息'),
          content: SingleChildScrollView(
            child: Text(
              debugInfo.toString(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('關閉'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('獲取調試信息失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}