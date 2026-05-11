import 'package:flutter/foundation.dart';
import '../models/meal_model.dart';
import '../services/storage_service.dart';

/// 簡化的餐點模型 - 適配手動輸入
class SimpleMealModel {
  final String id;
  final String name;
  final String date;
  final String time;
  final String mealType;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sodium;
  final double fiber;
  final String? photoPath;
  final List<String> tags;
  final String notes;
  final String source;
  final List<Map<String, dynamic>>? recognizedItems;

  SimpleMealModel({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sodium,
    required this.fiber,
    this.photoPath,
    required this.tags,
    required this.notes,
    required this.source,
    this.recognizedItems,
  });

  /// 轉換為MealRecord以便存儲
  MealRecord toMealRecord() {
    final dateTime = DateTime.parse('$date ${time}:00');
    
    // 創建食物項目
    final foods = recognizedItems?.map((item) => 
      FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: item['name'] ?? name,
        nameEn: item['nameEn'] ?? name,
        grams: double.tryParse(item['portion']?.toString() ?? '100') ?? 100.0,
        nutrition: NutritionData(
          calories: (item['calories'] as num?)?.toDouble() ?? calories,
          protein: (item['protein'] as num?)?.toDouble() ?? protein,
          carbs: (item['carbs'] as num?)?.toDouble() ?? carbs,
          fat: (item['fat'] as num?)?.toDouble() ?? fat,
          sodium: sodium,
          fiber: fiber,
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
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          sodium: sodium,
          fiber: fiber,
        ),
        isAiRecognized: false,
      )
    ];

    return MealRecord(
      id: id,
      name: name,
      type: mealType,
      dateTime: dateTime,
      foods: foods,
      nutrition: NutritionSummary(
        total: NutritionData(
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          sodium: sodium,
          fiber: fiber,
        ),
        goals: NutritionData(
          calories: calories * 1.2, // 稍微高一點的目標
          protein: protein * 1.2,
          carbs: carbs * 1.2,
          fat: fat * 1.2,
          sodium: 2300, // 建議的鈉攝取量
          fiber: 25, // 建議的膳食纖維攝取量
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
      notes: notes.isNotEmpty ? notes : null,
      imageUrl: photoPath,
    );
  }

  /// 從MealRecord創建
  factory SimpleMealModel.fromMealRecord(MealRecord record) {
    return SimpleMealModel(
      id: record.id,
      name: record.name,
      date: record.dateTime.toIso8601String().split('T')[0],
      time: '${record.dateTime.hour.toString().padLeft(2, '0')}:${record.dateTime.minute.toString().padLeft(2, '0')}',
      mealType: record.type,
      calories: record.nutrition.total.calories,
      protein: record.nutrition.total.protein,
      carbs: record.nutrition.total.carbs,
      fat: record.nutrition.total.fat,
      sodium: record.nutrition.total.sodium,
      fiber: record.nutrition.total.fiber,
      photoPath: record.imageUrl,
      tags: [], // MealRecord沒有tags，設為空
      notes: record.notes ?? '',
      source: 'stored',
    );
  }

  SimpleMealModel copyWith({
    String? id,
    String? name,
    String? date,
    String? time,
    String? mealType,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? sodium,
    double? fiber,
    String? photoPath,
    List<String>? tags,
    String? notes,
    String? source,
    List<Map<String, dynamic>>? recognizedItems,
  }) {
    return SimpleMealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      mealType: mealType ?? this.mealType,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      sodium: sodium ?? this.sodium,
      fiber: fiber ?? this.fiber,
      photoPath: photoPath ?? this.photoPath,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      recognizedItems: recognizedItems ?? this.recognizedItems,
    );
  }
}

/// 統一的餐點數據管理Provider
/// 負責所有餐點相關數據的CRUD操作
class MealDataProvider with ChangeNotifier {
  StorageService? _storage;
  
  List<SimpleMealModel> _meals = [];
  List<SimpleMealModel> _todayMeals = [];
  bool _isLoading = false;
  String? _error;
  
  // 當日營養統計
  double _todayCalories = 0;
  double _todayProtein = 0;
  double _todayCarbs = 0;
  double _todayFat = 0;
  double _todaySodium = 0;
  double _todayFiber = 0;

  // Getters
  List<SimpleMealModel> get meals => _meals;
  List<SimpleMealModel> get todayMeals => _todayMeals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  double get todayCalories => _todayCalories;
  double get todayProtein => _todayProtein;
  double get todayCarbs => _todayCarbs;
  double get todayFat => _todayFat;
  double get todaySodium => _todaySodium;
  double get todayFiber => _todayFiber;

  /// 初始化數據
  Future<void> initialize() async {
    _storage = await StorageService.init();
    await loadMeals();
    await loadTodayMeals();
  }

  /// 載入所有餐點數據
  Future<void> loadMeals() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final mealsData = await _storage!.getMealRecords();
      _meals = mealsData.map((record) => SimpleMealModel.fromMealRecord(record)).toList();
      
      _isLoading = false;
      notifyListeners();
      
      print('✅ 已載入 ${_meals.length} 筆餐點記錄');
    } catch (e) {
      _error = '載入餐點數據失敗: $e';
      _isLoading = false;
      notifyListeners();
      print('❌ 載入餐點數據失敗: $e');
    }
  }

  /// 載入今日餐點數據
  Future<void> loadTodayMeals() async {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    _todayMeals = _meals.where((meal) => meal.date == todayString).toList();
    _calculateTodayNutrition();
    notifyListeners();
  }

  /// 計算今日營養統計
  void _calculateTodayNutrition() {
    _todayCalories = 0;
    _todayProtein = 0;
    _todayCarbs = 0;
    _todayFat = 0;
    _todaySodium = 0;
    _todayFiber = 0;

    for (final meal in _todayMeals) {
      _todayCalories += meal.calories;
      _todayProtein += meal.protein;
      _todayCarbs += meal.carbs;
      _todayFat += meal.fat;
      _todaySodium += meal.sodium;
      _todayFiber += meal.fiber;
    }
  }

  /// 添加新餐點
  Future<bool> addMeal(SimpleMealModel meal) async {
    try {
      // 生成唯一ID
      meal = meal.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // 保存到存儲
      await _storage!.addMealRecord(meal.toMealRecord());
      
      // 更新本地列表
      _meals.add(meal);
      
      // 如果是今日餐點，更新今日統計
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      if (meal.date == todayString) {
        _todayMeals.add(meal);
        _calculateTodayNutrition();
      }
      
      notifyListeners();
      print('✅ 新增餐點成功: ${meal.name}');
      return true;
    } catch (e) {
      _error = '保存餐點失敗: $e';
      notifyListeners();
      print('❌ 保存餐點失敗: $e');
      return false;
    }
  }

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

      final meal = SimpleMealModel(
        id: '',
        name: inputData['name'] ?? '未命名餐點',
        date: inputData['date'] ?? '',
        time: inputData['time'] ?? '',
        mealType: inputData['mealType'] ?? 'breakfast',
        calories: totalCalories,
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        sodium: totalSodium,
        fiber: totalFiber,
        photoPath: inputData['photo'] as String?,
        tags: List<String>.from(inputData['tags'] ?? []),
        notes: inputData['notes'] ?? '',
        source: 'manual',
        recognizedItems: recognizedItems,
      );

      return await addMeal(meal);
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

  /// 更新餐點
  Future<bool> updateMeal(SimpleMealModel meal) async {
    try {
      await _storage!.updateMealRecord(meal.id, meal.toMealRecord());
      
      // 更新本地列表
      final index = _meals.indexWhere((m) => m.id == meal.id);
      if (index != -1) {
        _meals[index] = meal;
      }
      
      // 重新計算今日數據
      await loadTodayMeals();
      
      notifyListeners();
      print('✅ 更新餐點成功: ${meal.name}');
      return true;
    } catch (e) {
      _error = '更新餐點失敗: $e';
      notifyListeners();
      print('❌ 更新餐點失敗: $e');
      return false;
    }
  }

  /// 刪除餐點
  Future<bool> deleteMeal(String mealId) async {
    try {
      await _storage!.deleteMealRecord(mealId);
      
      // 從本地列表中移除
      _meals.removeWhere((meal) => meal.id == mealId);
      _todayMeals.removeWhere((meal) => meal.id == mealId);
      
      // 重新計算今日營養統計
      _calculateTodayNutrition();
      
      notifyListeners();
      print('✅ 刪除餐點成功');
      return true;
    } catch (e) {
      _error = '刪除餐點失敗: $e';
      notifyListeners();
      print('❌ 刪除餐點失敗: $e');
      return false;
    }
  }

  /// 獲取指定日期的餐點
  List<SimpleMealModel> getMealsByDate(DateTime date) {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _meals.where((meal) => meal.date == dateString).toList();
  }

  /// 獲取本週統計
  Map<String, double> getWeeklyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    
    for (final meal in _meals) {
      final mealDate = DateTime.parse(meal.date);
      if (mealDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          mealDate.isBefore(weekEnd.add(const Duration(days: 1)))) {
        totalCalories += meal.calories;
        totalProtein += meal.protein;
        totalCarbs += meal.carbs;
        totalFat += meal.fat;
      }
    }
    
    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  /// 清空錯誤狀態
  void clearError() {
    _error = null;
    notifyListeners();
  }
}