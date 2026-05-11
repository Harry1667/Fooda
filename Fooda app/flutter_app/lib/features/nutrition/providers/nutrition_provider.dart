import 'package:flutter/foundation.dart';

/// 營養數據提供者
class NutritionProvider extends ChangeNotifier {
  // 今日營養攝取
  double _todayCalories = 0.0;
  double _todayCarbs = 0.0;
  double _todayProtein = 0.0;
  double _todayFat = 0.0;
  double _todaySodium = 0.0;
  double _todayFiber = 0.0;

  // Getters
  double get todayCalories => _todayCalories;
  double get todayCarbs => _todayCarbs;
  double get todayProtein => _todayProtein;
  double get todayFat => _todayFat;
  double get todaySodium => _todaySodium;
  double get todayFiber => _todayFiber;

  /// 更新今日營養數據
  void updateTodayNutrition({
    required double calories,
    required double carbs,
    required double protein,
    required double fat,
    required double sodium,
    required double fiber,
  }) {
    _todayCalories = calories;
    _todayCarbs = carbs;
    _todayProtein = protein;
    _todayFat = fat;
    _todaySodium = sodium;
    _todayFiber = fiber;
    notifyListeners();
  }

  /// 重置今日數據
  void resetTodayNutrition() {
    _todayCalories = 0.0;
    _todayCarbs = 0.0;
    _todayProtein = 0.0;
    _todayFat = 0.0;
    _todaySodium = 0.0;
    _todayFiber = 0.0;
    notifyListeners();
  }
}
