// 簡化的模型類，用於快速運行應用

/// 餐點記錄模型
class MealRecord {
  final String id;
  final String name;
  final String type;
  final DateTime dateTime;
  final NutritionSummary nutrition;

  const MealRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.dateTime,
    required this.nutrition,
  });
}

/// 營養總結模型
class NutritionSummary {
  final NutritionData total;

  const NutritionSummary({
    required this.total,
  });
}

/// 營養數據模型
class NutritionData {
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final double sodium;
  final double fiber;

  const NutritionData({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.sodium,
    required this.fiber,
  });

  factory NutritionData.empty() {
    return const NutritionData(
      calories: 0,
      carbs: 0,
      protein: 0,
      fat: 0,
      sodium: 0,
      fiber: 0,
    );
  }

  /// 根據重量比例縮放營養數據
  NutritionData scaleByWeight(double newWeightGrams, double originalWeightGrams) {
    final ratio = newWeightGrams / originalWeightGrams;
    return NutritionData(
      calories: calories * ratio,
      carbs: carbs * ratio,
      protein: protein * ratio,
      fat: fat * ratio,
      sodium: sodium * ratio,
      fiber: fiber * ratio,
    );
  }
}

/// 會員資訊模型
class MembershipInfo {
  final String level;
  final String name;
  final MembershipFeatures features;
  final AiQuota aiQuota;

  const MembershipInfo({
    required this.level,
    required this.name,
    required this.features,
    required this.aiQuota,
  });
}

/// 會員功能權限模型
class MembershipFeatures {
  final bool aiRecognition;

  const MembershipFeatures({
    required this.aiRecognition,
  });
}

/// AI 額度模型
class AiQuota {
  final int monthlyLimit;
  final int remaining;

  const AiQuota({
    required this.monthlyLimit,
    required this.remaining,
  });

  bool get hasQuota => remaining > 0;
}