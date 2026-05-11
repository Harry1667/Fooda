import 'package:flutter/foundation.dart';
import '../../../core/models/meal_model.dart';
import '../../../core/services/storage_service.dart';

import '../../../core/services/backup_service.dart';

/// 餐點記錄提供者
class MealProvider extends ChangeNotifier {
  StorageService? _storageService;
  List<MealRecord> _meals = [];
  bool _isLoading = false;

  MealProvider() {
    _initializeService();
  }

  /// 初始化存儲服務
  Future<void> _initializeService() async {
    _storageService = await StorageService.init();
    await _loadMeals();
  }

  // ========== Getters ==========

  List<MealRecord> get meals => _meals;
  bool get isLoading => _isLoading;

  /// 今日餐點
  List<MealRecord> get todayMeals {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _meals.where((meal) {
      return meal.dateTime.isAfter(today) && meal.dateTime.isBefore(tomorrow);
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// 獲取指定日期的餐點
  List<MealRecord> getMealsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _meals.where((meal) {
      return meal.dateTime.isAfter(startOfDay) && 
             meal.dateTime.isBefore(endOfDay.add(const Duration(seconds: 1)));
    }).toList()
      ..sort(_compareMealsByTypeAndTime);
  }

  /// 獲取指定日期範圍的餐點
  List<MealRecord> getMealsByDateRange(DateTime startDate, DateTime endDate) {
    return _meals.where((meal) {
      return meal.dateTime.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
             meal.dateTime.isBefore(endDate.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// 計算指定日期範圍的營養總和
  NutritionData calculateTotalNutrition(DateTime startDate, DateTime endDate) {
    final mealsInRange = getMealsByDateRange(startDate, endDate);
    
    if (mealsInRange.isEmpty) {
      return NutritionData.empty();
    }
    
    return mealsInRange
        .map((meal) => meal.nutrition.total)
        .reduce((a, b) => a + b);
  }

  /// 計算今日營養總和
  NutritionData get todayNutrition {
    if (todayMeals.isEmpty) {
      return NutritionData.empty();
    }
    
    return todayMeals
        .map((meal) => meal.nutrition.total)
        .reduce((a, b) => a + b);
  }

  /// 計算連續記錄天數
  int get currentStreak {
    if (_meals.isEmpty) return 0;

    // 獲取所有有記錄的日期（去重）
    final dates = _meals
        .map((m) => DateTime(m.dateTime.year, m.dateTime.month, m.dateTime.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // 降序排列

    if (dates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    int streak = 0;
    
    // 檢查今天是否有記錄
    // 如果今天有記錄，從今天開始計算
    // 如果今天沒記錄，但昨天有記錄，從昨天開始計算
    // 如果今天和昨天都沒記錄，streak 為 0
    
    DateTime? currentDate;
    
    if (dates.contains(todayDate)) {
      currentDate = todayDate;
    } else if (dates.contains(yesterdayDate)) {
      currentDate = yesterdayDate;
    } else {
      return 0;
    }

    // 計算連續天數
    for (int i = 0; i < dates.length; i++) {
      // 找到起始日期在列表中的位置
      if (dates[i].isAfter(currentDate!)) continue;
      
      if (dates[i].isAtSameMomentAs(currentDate!)) {
        streak++;
        currentDate = currentDate!.subtract(const Duration(days: 1));
      } else {
        // 日期不連續，中斷
        break;
      }
    }

    return streak;
  }

  // ========== 餐點管理方法 ==========

  /// 載入餐點記錄
  Future<void> _loadMeals() async {
    if (_storageService == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _meals = await _storageService!.getMealRecords();
    } catch (e) {
      print('載入餐點記錄失敗: $e');
      _meals = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 重新載入餐點
  Future<void> reloadMeals() async {
    await _loadMeals();
  }

  /// 添加餐點
  Future<bool> addMeal(MealRecord meal) async {
    if (_storageService == null) return false;
    
    try {
      final success = await _storageService!.addMealRecord(meal);
      if (success) {
        _meals.add(meal);
        _meals.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        notifyListeners();
        
        // CloudKit backup removed
        // BackupService.uploadToCloud(null);
      }
      return success;
    } catch (e) {
      print('添加餐點失敗: $e');
      rethrow;
    }
  }

  /// 更新餐點
  Future<bool> updateMeal(String id, MealRecord meal) async {
    if (_storageService == null) return false;
    
    try {
      final success = await _storageService!.updateMealRecord(id, meal);
      if (success) {
        final index = _meals.indexWhere((m) => m.id == id);
        if (index != -1) {
          _meals[index] = meal;
          _meals.sort((a, b) => b.dateTime.compareTo(a.dateTime));
          notifyListeners();
          
          // CloudKit backup removed
          // BackupService.uploadToCloud(null);
        }
      }
      return success;
    } catch (e) {
      print('更新餐點失敗: $e');
      rethrow;
    }
  }

  /// 刪除餐點
  Future<bool> deleteMeal(String id) async {
    if (_storageService == null) return false;
    
    try {
      final success = await _storageService!.deleteMealRecord(id);
      if (success) {
        _meals.removeWhere((meal) => meal.id == id);
        notifyListeners();
        
        // CloudKit backup removed
        // BackupService.uploadToCloud(null);
      }
      return success;
    } catch (e) {
      print('刪除餐點失敗: $e');
      rethrow;
    }
  }

  /// 清空所有餐點
  Future<bool> clearAllMeals() async {
    if (_storageService == null) return false;
    
    try {
      final success = await _storageService!.clearMealRecords();
      if (success) {
        _meals.clear();
        notifyListeners();
        // CloudKit backup removed
        // BackupService.uploadToCloud(null);
      }
      return success;
    } catch (e) {
      print('清空餐點失敗: $e');
      return false;
    }
  }

  // ========== 私有輔助方法 ==========

  /// 從手動輸入數據創建餐點
  Future<bool> addMealFromManualInput(Map<String, dynamic> inputData) async {
    try {
      // 處理AI識別結果或使用預設值
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      double totalSodium = 0;
      double totalFiber = 0;
      
      final recognizedItems = inputData['recognizedItems'] as List<Map<String, dynamic>>?;
      
      if (inputData.containsKey('calories') && inputData['calories'] != null) {
        // 優先使用手動輸入的營養數據
        totalCalories = (inputData['calories'] as num).toDouble();
        totalProtein = (inputData['protein'] as num?)?.toDouble() ?? 0;
        totalCarbs = (inputData['carbs'] as num?)?.toDouble() ?? 0;
        totalFat = (inputData['fat'] as num?)?.toDouble() ?? 0;
        totalSodium = (inputData['sodium'] as num?)?.toDouble() ?? 0;
        totalFiber = (inputData['fiber'] as num?)?.toDouble() ?? 0;
      } else if (recognizedItems != null && recognizedItems.isNotEmpty) {
        // 使用AI識別的營養數據
        for (final item in recognizedItems) {
          totalCalories += (item['calories'] as num?)?.toDouble() ?? 0;
          totalProtein += (item['protein'] as num?)?.toDouble() ?? 0;
          totalCarbs += (item['carbs'] as num?)?.toDouble() ?? 0;
          totalFat += (item['fat'] as num?)?.toDouble() ?? 0;
          totalSodium += (item['sodium'] as num?)?.toDouble() ?? 0;
          totalFiber += (item['fiber'] as num?)?.toDouble() ?? 0;
        }
      } else {
        // 使用估算值（基於餐點名稱的簡單估算）
        totalCalories = _estimateCalories(inputData['name'] ?? '');
        totalProtein = totalCalories * 0.15 / 4; // 15% 蛋白質
        totalCarbs = totalCalories * 0.55 / 4;   // 55% 碳水化合物
        totalFat = totalCalories * 0.30 / 9;     // 30% 脂肪
      }

      final dateStr = inputData['date'] ?? '';
      final timeStr = inputData['time'] ?? '';
      final dateTime = DateTime.parse('$dateStr ${timeStr}:00');
      final name = inputData['name'] ?? '未命名餐點';

      // 創建食物項目
      final foods = recognizedItems?.map((item) => 
        FoodItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: item['name'] ?? name,
          nameEn: item['nameEn'] ?? name,
          grams: double.tryParse(item['portion']?.toString() ?? '100') ?? 100.0,
          nutrition: NutritionData(
            calories: (item['calories'] as num?)?.toDouble() ?? totalCalories,
            protein: (item['protein'] as num?)?.toDouble() ?? totalProtein,
            carbs: (item['carbs'] as num?)?.toDouble() ?? totalCarbs,
            fat: (item['fat'] as num?)?.toDouble() ?? totalFat,
            sodium: totalSodium,
            fiber: totalFiber,
          ),
          isAiRecognized: true,
        )
      ).toList() ?? [
        FoodItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          nameEn: name,
          grams: 100.0,
          nutrition: NutritionData(
            calories: totalCalories,
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat,
            sodium: totalSodium,
            fiber: totalFiber,
          ),
          isAiRecognized: false,
        )
      ];

      final mealRecord = MealRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: inputData['mealType'] ?? 'breakfast',
        dateTime: dateTime,
        foods: foods,
        nutrition: NutritionSummary(
          total: NutritionData(
            calories: totalCalories,
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat,
            sodium: totalSodium,
            fiber: totalFiber,
          ),
          goals: NutritionData(
            calories: totalCalories * 1.2,
            protein: totalProtein * 1.2,
            carbs: totalCarbs * 1.2,
            fat: totalFat * 1.2,
            sodium: 2300,
            fiber: 25,
          ),
          percentages: {
            'calories': 100.0,
            'protein': 100.0,
            'carbs': 100.0,
            'fat': 100.0,
            'sodium': 100.0,
            'fiber': 100.0,
          },
        ),
        notes: inputData['notes'] ?? '',
        imageUrl: inputData['photo'] as String?,
        source: 'manual',
      );

      return await addMeal(mealRecord);
    } catch (e) {
      print('❌ 從手動輸入創建餐點失敗: $e');
      return false;
    }
  }

  /// 簡單的卡路里估算（基於關鍵詞）
  double _estimateCalories(String foodName) {
    final name = foodName.toLowerCase();
    
    // 基本估算邏輯
    if (name.contains('沙拉')) return 150;
    if (name.contains('雞肉') || name.contains('雞胸')) return 250;
    if (name.contains('牛肉')) return 300;
    if (name.contains('豬肉')) return 280;
    if (name.contains('魚') || name.contains('鮭魚')) return 200;
    if (name.contains('米飯') || name.contains('飯')) return 200;
    if (name.contains('麵') || name.contains('意麵')) return 300;
    if (name.contains('麵包')) return 250;
    if (name.contains('蛋')) return 150;
    if (name.contains('湯')) return 100;
    if (name.contains('果汁') || name.contains('飲料')) return 120;
    if (name.contains('甜點') || name.contains('蛋糕')) return 350;
    
    // 預設值
    return 200;
  }

  // ========== 私有輔助方法 ==========

  /// 按餐食類型和時間排序
  int _compareMealsByTypeAndTime(MealRecord a, MealRecord b) {
    // 先按餐食類型排序
    final priorityA = _getMealTypePriority(a.type);
    final priorityB = _getMealTypePriority(b.type);
    
    if (priorityA != priorityB) {
      return priorityA.compareTo(priorityB);
    }
    
    // 同一餐食類型按時間排序
    return a.dateTime.compareTo(b.dateTime);
  }

  /// 獲取餐食類型優先級
  int _getMealTypePriority(String type) {
    const priorities = {
      'breakfast': 0,
      'morning-snack': 1,
      'lunch': 2,
      'afternoon-tea': 3,
      'dinner': 4,
      'late-night': 5,
    };
    
    return priorities[type] ?? 99;
  }
}
