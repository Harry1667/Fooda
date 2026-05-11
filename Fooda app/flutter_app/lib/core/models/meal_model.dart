import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// 餐點記錄模型
/// 對應 PHP 版本的餐點數據結構
class MealRecord {
  final String id;
  final String name;
  final String type; // breakfast, lunch, dinner, etc.
  final DateTime dateTime;
  final List<FoodItem> foods;
  final NutritionSummary nutrition;
  final String? notes;
  final String? imageUrl;
  final String source; // 'manual', 'ai_camera', 'ai_gallery', 'unknown'

  const MealRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.dateTime,
    required this.foods,
    required this.nutrition,
    this.notes,
    this.imageUrl,
    this.source = 'unknown',
  });

  factory MealRecord.fromJson(Map<String, dynamic> json) {
    return MealRecord(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Unknown Meal',
      type: json['type'] as String? ?? 'breakfast',
      dateTime: DateTime.tryParse(json['dateTime'] as String? ?? '') ?? DateTime.now(),
      foods: (json['foods'] as List<dynamic>? ?? [])
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nutrition: json['nutrition'] != null 
          ? NutritionSummary.fromJson(json['nutrition'] as Map<String, dynamic>) 
          : NutritionSummary(
              total: NutritionData.empty(), 
              goals: NutritionData.empty(), 
              percentages: {}
            ),
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      source: json['source'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'dateTime': dateTime.toIso8601String(),
      'foods': foods.map((e) => e.toJson()).toList(),
      'nutrition': nutrition.toJson(),
      'notes': notes,
      'imageUrl': imageUrl,
      'source': source,
    };
  }

  MealRecord copyWith({
    String? id,
    String? name,
    String? type,
    DateTime? dateTime,
    List<FoodItem>? foods,
    NutritionSummary? nutrition,
    String? notes,
    String? imageUrl,
    String? source,
  }) {
    return MealRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      foods: foods ?? this.foods,
      nutrition: nutrition ?? this.nutrition,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
    );
  }
}

/// 食物項目模型
class FoodItem {
  final String id;
  final String name;
  final String nameEn; // 英文名稱，用於 USDA 查詢
  final double grams;
  final NutritionData nutrition;
  final String? imageUrl;
  final bool isAiRecognized;

  const FoodItem({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.grams,
    required this.nutrition,
    this.imageUrl,
    this.isAiRecognized = false,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Unknown Food',
      nameEn: json['nameEn'] as String? ?? json['name'] as String? ?? '',
      grams: (json['grams'] as num?)?.toDouble() ?? 100.0,
      nutrition: json['nutrition'] != null 
          ? NutritionData.fromJson(json['nutrition'] as Map<String, dynamic>)
          : NutritionData.empty(),
      imageUrl: json['imageUrl'] as String?,
      isAiRecognized: json['isAiRecognized'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'grams': grams,
      'nutrition': nutrition.toJson(),
      'imageUrl': imageUrl,
      'isAiRecognized': isAiRecognized,
    };
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? nameEn,
    double? grams,
    NutritionData? nutrition,
    String? imageUrl,
    bool? isAiRecognized,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      grams: grams ?? this.grams,
      nutrition: nutrition ?? this.nutrition,
      imageUrl: imageUrl ?? this.imageUrl,
      isAiRecognized: isAiRecognized ?? this.isAiRecognized,
    );
  }
}

/// 營養數據模型
class NutritionData {
  final double calories;
  final double carbs; // 碳水化合物 (g)
  final double protein; // 蛋白質 (g)
  final double fat; // 脂肪 (g)
  final double sodium; // 鈉 (mg)
  final double fiber; // 膳食纖維 (g)
  final double sugar; // 糖 (g)
  final double saturatedFat; // 飽和脂肪 (g)
  final double cholesterol; // 膽固醇 (mg)

  const NutritionData({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.sodium,
    required this.fiber,
    this.sugar = 0,
    this.saturatedFat = 0,
    this.cholesterol = 0,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
      saturatedFat: (json['saturatedFat'] as num?)?.toDouble() ?? 0,
      cholesterol: (json['cholesterol'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'sodium': sodium,
      'fiber': fiber,
      'sugar': sugar,
      'saturatedFat': saturatedFat,
      'cholesterol': cholesterol,
    };
  }

  /// 空營養數據
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

  /// 營養數據相加
  NutritionData operator +(NutritionData other) {
    return NutritionData(
      calories: calories + other.calories,
      carbs: carbs + other.carbs,
      protein: protein + other.protein,
      fat: fat + other.fat,
      sodium: sodium + other.sodium,
      fiber: fiber + other.fiber,
      sugar: sugar + other.sugar,
      saturatedFat: saturatedFat + other.saturatedFat,
      cholesterol: cholesterol + other.cholesterol,
    );
  }

  /// 營養數據乘以倍數（用於調整份量）
  NutritionData operator *(double multiplier) {
    return NutritionData(
      calories: calories * multiplier,
      carbs: carbs * multiplier,
      protein: protein * multiplier,
      fat: fat * multiplier,
      sodium: sodium * multiplier,
      fiber: fiber * multiplier,
      sugar: sugar * multiplier,
      saturatedFat: saturatedFat * multiplier,
      cholesterol: cholesterol * multiplier,
    );
  }

  NutritionData copyWith({
    double? calories,
    double? carbs,
    double? protein,
    double? fat,
    double? sodium,
    double? fiber,
    double? sugar,
    double? saturatedFat,
    double? cholesterol,
  }) {
    return NutritionData(
      calories: calories ?? this.calories,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      sodium: sodium ?? this.sodium,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      cholesterol: cholesterol ?? this.cholesterol,
    );
  }
}

/// 營養總結模型
class NutritionSummary {
  final NutritionData total;
  final NutritionData goals;
  final Map<String, double> percentages;

  const NutritionSummary({
    required this.total,
    required this.goals,
    required this.percentages,
  });

  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    return NutritionSummary(
      total: NutritionData.fromJson(json['total'] as Map<String, dynamic>),
      goals: NutritionData.fromJson(json['goals'] as Map<String, dynamic>),
      percentages: Map<String, double>.from(json['percentages'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total.toJson(),
      'goals': goals.toJson(),
      'percentages': percentages,
    };
  }

  /// 計算營養素達成百分比
  factory NutritionSummary.calculate(
    NutritionData total,
    NutritionData goals,
  ) {
    final percentages = <String, double>{
      'calories': goals.calories > 0 ? (total.calories / goals.calories) * 100 : 0,
      'carbs': goals.carbs > 0 ? (total.carbs / goals.carbs) * 100 : 0,
      'protein': goals.protein > 0 ? (total.protein / goals.protein) * 100 : 0,
      'fat': goals.fat > 0 ? (total.fat / goals.fat) * 100 : 0,
      'sodium': goals.sodium > 0 ? (total.sodium / goals.sodium) * 100 : 0,
      'fiber': goals.fiber > 0 ? (total.fiber / goals.fiber) * 100 : 0,
    };

    return NutritionSummary(
      total: total,
      goals: goals,
      percentages: percentages,
    );
  }
}

/// 餐點類型枚舉
enum MealType {
  breakfast('breakfast'),
  morningSnack('morning-snack'),
  lunch('lunch'),
  afternoonTea('afternoon-tea'),
  dinner('dinner'),
  lateNight('late-night');

  const MealType(this.value);

  final String value;

  static MealType fromValue(String value) {
    return MealType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MealType.breakfast,
    );
  }
}

extension MealTypeExtension on MealType {
  String getDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case MealType.breakfast:
        return l10n.breakfast;
      case MealType.morningSnack:
        return l10n.morningSnack;
      case MealType.lunch:
        return l10n.lunch;
      case MealType.afternoonTea:
        return l10n.afternoonTea ?? l10n.afternoonSnack ?? 'Afternoon Snack';
      case MealType.dinner:
        return l10n.dinner;
      case MealType.lateNight:
        return l10n.lateNight ?? 'Late Night';
    }
  }
}

/// AI 識別結果模型
class AiRecognitionResult {
  final List<RecognizedFood> foods;
  final String? error;
  final bool success;

  const AiRecognitionResult({
    required this.foods,
    this.error,
    required this.success,
  });

  factory AiRecognitionResult.fromJson(Map<String, dynamic> json) {
    return AiRecognitionResult(
      foods: (json['foods'] as List<dynamic>)
          .map((e) => RecognizedFood.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String?,
      success: json['success'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foods': foods.map((e) => e.toJson()).toList(),
      'error': error,
      'success': success,
    };
  }
}

/// 識別的食物模型
class RecognizedFood {
  final String name;
  final String nameEn;
  final double estimatedGrams;
  final double confidence;
  final NutritionData? nutrition;

  const RecognizedFood({
    required this.name,
    required this.nameEn,
    required this.estimatedGrams,
    required this.confidence,
    this.nutrition,
  });

  factory RecognizedFood.fromJson(Map<String, dynamic> json) {
    return RecognizedFood(
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      estimatedGrams: (json['estimatedGrams'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      nutrition: json['nutrition'] != null
          ? NutritionData.fromJson(json['nutrition'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nameEn': nameEn,
      'estimatedGrams': estimatedGrams,
      'confidence': confidence,
      'nutrition': nutrition?.toJson(),
    };
  }
}