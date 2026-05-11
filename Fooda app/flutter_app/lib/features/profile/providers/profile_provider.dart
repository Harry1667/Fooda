import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/notification_service.dart';

/// 用戶資料提供者
/// 所有數據存儲在本地，不使用雲端服務
class ProfileProvider extends ChangeNotifier {
  // 用戶基本信息（僅本地存儲）
  String _userName = '本地用戶';
  
  // 身體數據
  int _height = 175; // cm
  int _weight = 70; // kg
  int _age = 25;
  String _gender = 'male'; // male, female
  String _activityLevel = 'moderate'; // sedentary, light, moderate, active, very_active
  
  // 營養目標
  double _caloriesGoal = 2000; // kcal
  double _carbsGoal = 250; // g
  double _proteinGoal = 75; // g
  double _fatGoal = 67; // g
  double _sodiumGoal = 2300; // mg
  double _fiberGoal = 25; // g
  
  // 通知設定
  String _breakfastTime = '09:00';
  String _lunchTime = '12:00';
  String _dinnerTime = '18:00';
  bool _notificationsEnabled = false;

  // Getters
  String get userName => _userName;
  int get height => _height;
  int get weight => _weight;
  int get age => _age;
  String get gender => _gender;
  String get activityLevel => _activityLevel;
  
  double get caloriesGoal => _caloriesGoal;
  double get carbsGoal => _carbsGoal;
  double get proteinGoal => _proteinGoal;
  double get fatGoal => _fatGoal;
  double get sodiumGoal => _sodiumGoal;
  double get fiberGoal => _fiberGoal;
  
  String get breakfastTime => _breakfastTime;
  String get lunchTime => _lunchTime;
  String get dinnerTime => _dinnerTime;
  bool get notificationsEnabled => _notificationsEnabled;

  ProfileProvider() {
    _loadData();
  }

  /// 加載保存的數據
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _userName = prefs.getString('profile_userName') ?? '本地用戶';
      
      // 優先從引導頁面設定的數據載入，如果沒有則使用原有預設值
      _height = prefs.getDouble('height')?.round() ?? 
                prefs.getDouble('user_height')?.round() ?? 
                prefs.getInt('profile_height') ?? 175;
      _weight = prefs.getDouble('weight')?.round() ?? 
                prefs.getDouble('user_weight')?.round() ?? 
                prefs.getInt('profile_weight') ?? 70;
      _age = prefs.getInt('age') ?? 
             prefs.getInt('user_age') ?? 
             prefs.getInt('profile_age') ?? 25;
      _gender = prefs.getString('gender') ?? 
                prefs.getString('user_gender') ?? 
                prefs.getString('profile_gender') ?? 'male';
      _activityLevel = prefs.getString('activity_level') ?? 
                       prefs.getString('user_activity_level') ?? 
                       prefs.getString('profile_activityLevel') ?? 'moderate';
      
      // 營養目標 - 優先使用引導頁面設定的值
      _caloriesGoal = (prefs.getInt('calorie_goal') ?? 
                       prefs.getInt('user_calorie_goal') ?? 
                       prefs.getInt('daily_calorie_goal') ?? 
                       prefs.getDouble('profile_caloriesGoal') ?? 2000).toDouble();
      
      _proteinGoal = (prefs.getInt('protein_goal') ?? 
                      prefs.getInt('daily_protein_goal') ?? 
                      prefs.getDouble('profile_proteinGoal') ?? 75).toDouble();
      
      _carbsGoal = (prefs.getInt('carbs_goal') ?? 
                    prefs.getInt('daily_carbs_goal') ?? 
                    prefs.getDouble('profile_carbsGoal') ?? 250).toDouble();
      
      _fatGoal = (prefs.getInt('fat_goal') ?? 
                  prefs.getInt('daily_fat_goal') ?? 
                  prefs.getDouble('profile_fatGoal') ?? 67).toDouble();
      
      _sodiumGoal = prefs.getDouble('profile_sodiumGoal') ?? 2300;
      _fiberGoal = prefs.getDouble('profile_fiberGoal') ?? 25;
      
      _breakfastTime = prefs.getString('profile_breakfastTime') ?? '09:00';
      _lunchTime = prefs.getString('profile_lunchTime') ?? '12:00';
      _dinnerTime = prefs.getString('profile_dinnerTime') ?? '18:00';
      _notificationsEnabled = prefs.getBool('profile_notificationsEnabled') ?? false;
      
      print('✅ ProfileProvider 已載入數據:');
      print('身高: $_height cm, 體重: $_weight kg, 年齡: $_age');
      print('性別: $_gender, 活動量: $_activityLevel');
      print('卡路里目標: $_caloriesGoal, 蛋白質: $_proteinGoal, 碳水: $_carbsGoal, 脂肪: $_fatGoal');
      
      notifyListeners();
    } catch (e) {
      print('❌ 載入個人資料失敗: $e');
    }
  }

  /// 保存數據
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('profile_userName', _userName);
      await prefs.setInt('profile_height', _height);
      await prefs.setInt('profile_weight', _weight);
      await prefs.setInt('profile_age', _age);
      await prefs.setString('profile_gender', _gender);
      await prefs.setString('profile_activityLevel', _activityLevel);
      
      await prefs.setDouble('profile_caloriesGoal', _caloriesGoal);
      await prefs.setDouble('profile_carbsGoal', _carbsGoal);
      await prefs.setDouble('profile_proteinGoal', _proteinGoal);
      await prefs.setDouble('profile_fatGoal', _fatGoal);
      await prefs.setDouble('profile_sodiumGoal', _sodiumGoal);
      await prefs.setDouble('profile_fiberGoal', _fiberGoal);
      
      await prefs.setString('profile_breakfastTime', _breakfastTime);
      await prefs.setString('profile_lunchTime', _lunchTime);
      await prefs.setString('profile_dinnerTime', _dinnerTime);
      await prefs.setBool('profile_notificationsEnabled', _notificationsEnabled);
    } catch (e) {
      print('保存個人資料失敗: $e');
    }
  }
  /// 更新用戶名稱
  Future<void> updateUserName(String name) async {
    _userName = name;
    await _saveData();
    notifyListeners();
  }

  /// 更新身體數據
  Future<void> updateBodyData({
    int? height,
    int? weight,
    int? age,
    String? gender,
    String? activityLevel,
  }) async {
    if (height != null) _height = height;
    if (weight != null) _weight = weight;
    if (age != null) _age = age;
    if (gender != null) _gender = gender;
    if (activityLevel != null) _activityLevel = activityLevel;
    await _saveData();
    notifyListeners();
  }

  /// 更新營養目標
  Future<void> updateNutritionGoals({
    double? calories,
    double? carbs,
    double? protein,
    double? fat,
    double? sodium,
    double? fiber,
  }) async {
    if (calories != null) _caloriesGoal = calories;
    if (carbs != null) _carbsGoal = carbs;
    if (protein != null) _proteinGoal = protein;
    if (fat != null) _fatGoal = fat;
    if (sodium != null) _sodiumGoal = sodium;
    if (fiber != null) _fiberGoal = fiber;
    await _saveData();
    notifyListeners();
  }

  /// 更新通知設定
  Future<void> updateNotificationSettings({
    String? breakfastTime,
    String? lunchTime,
    String? dinnerTime,
    bool? enabled,
  }) async {
    if (breakfastTime != null) _breakfastTime = breakfastTime;
    if (lunchTime != null) _lunchTime = lunchTime;
    if (dinnerTime != null) _dinnerTime = dinnerTime;
    if (enabled != null) _notificationsEnabled = enabled;
    await _saveData();
    // 重新排程通知
    await NotificationService().scheduleAllMeals(
      breakfastTime: _breakfastTime,
      lunchTime: _lunchTime,
      dinnerTime: _dinnerTime,
      enabled: _notificationsEnabled,
    );
    notifyListeners();
  }

  /// 計算 BMI
  double get bmi {
    return _weight / ((_height / 100) * (_height / 100));
  }

  /// 獲取BMI分類
  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'bmiUnderweight';
    if (b < 24) return 'bmiNormal';
    if (b < 27) return 'bmiOverweight';
    if (b < 30) return 'bmiObeseMild';
    if (b < 35) return 'bmiObeseModerate';
    return 'bmiObeseSevere';
  }

  /// 獲取活動程度名稱
  /// 注意：這個方法現在返回原始值，需要在UI層使用多語言系統進行轉換
  String get activityLevelName {
    return _activityLevel;
  }

  /// 獲取活動係數
  double get activityFactor {
    switch (_activityLevel) {
      case 'sedentary':
        return 1.2;
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'active':
        return 1.725;
      case 'very_active':
        return 1.9;
      default:
        return 1.55;
    }
  }

  /// 計算每日熱量需求（Harris-Benedict 公式）
  double get dailyCalorieNeeds {
    double bmr;
    if (_gender == 'male') {
      bmr = 88.362 + (13.397 * _weight) + (4.799 * _height) - (5.677 * _age);
    } else {
      bmr = 447.593 + (9.247 * _weight) + (3.098 * _height) - (4.330 * _age);
    }
    return bmr * activityFactor;
  }
  /// 重置所有數據 (恢復原廠設定)
  Future<void> resetAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // 清除所有 SharedPreferences 數據
      
      // 重置本地狀態為默認值
      _userName = '本地用戶';
      _height = 175;
      _weight = 70;
      _age = 25;
      _gender = 'male';
      _activityLevel = 'moderate';
      
      _caloriesGoal = 2000;
      _carbsGoal = 250;
      _proteinGoal = 75;
      _fatGoal = 67;
      _sodiumGoal = 2300;
      _fiberGoal = 25;
      
      _breakfastTime = '09:00';
      _lunchTime = '12:00';
      _dinnerTime = '18:00';
      _notificationsEnabled = false;
      
      print('✅ 所有數據已重置');
      notifyListeners();
    } catch (e) {
      print('❌ 重置數據失敗: $e');
    }
  }
}
