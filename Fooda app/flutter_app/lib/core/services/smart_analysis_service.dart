import '../../features/profile/providers/profile_provider.dart';
import '../../core/models/meal_model.dart';
import '../../l10n/app_localizations.dart';

/// 智能分析服務
/// 根據用戶的身體資料和營養目標提供個性化分析建議
class SmartAnalysisService {
  /// 根據個人資料計算建議熱量
  static double calculateRecommendedCalories(ProfileProvider profile) {
    return profile.dailyCalorieNeeds;
  }

  /// 根據個人資料計算建議營養素目標
  static Map<String, double> calculateRecommendedNutritionGoals(ProfileProvider profile) {
    final calories = profile.dailyCalorieNeeds;
    final weight = profile.weight.toDouble();
    
    // 根據體重和活動程度計算蛋白質需求
    double proteinGoal;
    if (profile.activityLevel == 'very_active') {
      proteinGoal = weight * 2.2; // 高強度運動：2.2g/kg
    } else if (profile.activityLevel == 'active') {
      proteinGoal = weight * 1.8; // 中高強度運動：1.8g/kg
    } else if (profile.activityLevel == 'moderate') {
      proteinGoal = weight * 1.6; // 中等強度運動：1.6g/kg
    } else {
      proteinGoal = weight * 1.2; // 輕度運動：1.2g/kg
    }
    
    // 脂肪：總熱量的25-30%
    final fatGoal = (calories * 0.275) / 9; // 9 kcal/g
    
    // 碳水化合物：剩餘熱量
    final remainingCalories = calories - (proteinGoal * 4) - (fatGoal * 9);
    final carbsGoal = remainingCalories / 4; // 4 kcal/g
    
    // 鈉：根據年齡調整
    double sodiumGoal;
    if (profile.age < 50) {
      sodiumGoal = 2300; // 50歲以下：2300mg
    } else {
      sodiumGoal = 1500; // 50歲以上：1500mg
    }
    
    // 膳食纖維：根據性別和年齡
    double fiberGoal;
    if (profile.gender == 'male') {
      fiberGoal = profile.age < 50 ? 38 : 30; // 男性：38g (50歲以下) / 30g (50歲以上)
    } else {
      fiberGoal = profile.age < 50 ? 25 : 21; // 女性：25g (50歲以下) / 21g (50歲以上)
    }
    
    return {
      'calories': calories,
      'carbs': carbsGoal,
      'protein': proteinGoal,
      'fat': fatGoal,
      'sodium': sodiumGoal,
      'fiber': fiberGoal,
    };
  }

  /// 生成個性化分析建議（基於實際記錄天數）
  static List<PersonalizedAnalysisCard> generatePersonalizedAnalysis(
    ProfileProvider profile,
    NutritionData nutrition,
    String selectedPeriod,
    AppLocalizations l10n, {
    int? actualRecordDays, // 實際記錄天數
    String? activityLevelDisplayName, // 翻譯後的活動程度名稱
  }) {
    final cards = <PersonalizedAnalysisCard>[];
    final recommended = {
      'calories': profile.caloriesGoal,
      'carbs': profile.carbsGoal,
      'protein': profile.proteinGoal,
      'fat': profile.fatGoal,
      'sodium': profile.sodiumGoal,
      'fiber': profile.fiberGoal,
    };
    
    // 使用實際記錄天數而不是理論天數
    final recordDays = actualRecordDays ?? _getPeriodDays(selectedPeriod);
    final hasActualData = actualRecordDays != null && actualRecordDays > 0;
    
    // 如果沒有實際記錄，顯示提示信息
    if (!hasActualData || recordDays == 0) {
      cards.add(PersonalizedAnalysisCard(
        type: AnalysisCardType.info,
        icon: '📝',
        title: l10n.startRecordingMeals,
        message: l10n.startRecordingMessage(_getPeriodName(selectedPeriod, l10n)),
        personalization: '${l10n.analysisBasedOn ?? 'Analysis based on'}：${profile.age}, ${profile.gender == 'male' ? l10n.male : l10n.female}, ${activityLevelDisplayName ?? profile.activityLevel}',
      ));
      return cards;
    }
    
    // 如果記錄天數太少（少於期間的1/3），給予不同的分析策略
    final theoreticalDays = _getPeriodDays(selectedPeriod);
    final isInsufficientData = recordDays < (theoreticalDays / 3);
    
    if (isInsufficientData && selectedPeriod != 'today') {
      cards.add(PersonalizedAnalysisCard(
        type: AnalysisCardType.info,
        icon: '📊',
        title: l10n.dataCollecting,
        message: l10n.dataCollectingMessage(recordDays.toString()),
        personalization: '${l10n.basedOnData ?? 'Based on'} $recordDays ${l10n.daysData ?? 'days data'}',
      ));
    }
    
    final avgDailyCalories = nutrition.calories / recordDays;
    final avgDailyRecommended = recommended['calories']!;
    
    // 1. 熱量分析（基於個人BMR和活動程度及實際記錄天數）
    final calorieRatio = avgDailyCalories / avgDailyRecommended;
    final bmi = profile.bmi;
    final bmiCategoryKey = profile.bmiCategory; // Now returns key 'bmiUnderweight' etc.
    final bmiCategoryDisplay = _getBmiCategoryDisplay(bmiCategoryKey, l10n);
    
    final periodName = _getPeriodName(selectedPeriod, l10n);
    final daysSuffix = recordDays == 1 ? '' : ' (${recordDays} ${l10n.days})';
    
    if (calorieRatio < 0.7) {
      String message;
      if (bmiCategoryKey == 'bmiUnderweight') {
        message = l10n.analysisCaloriesLowUnderweight(periodName, avgDailyCalories.toInt().toString(), daysSuffix);
      } else if (bmiCategoryKey == 'bmiNormal') {
        message = l10n.analysisCaloriesLowNormal(periodName, avgDailyCalories.toInt().toString(), daysSuffix);
      } else {
        message = l10n.analysisCaloriesLowOverweight(periodName, avgDailyCalories.toInt().toString(), daysSuffix);
      }
      
      cards.add(PersonalizedAnalysisCard(
        type: AnalysisCardType.warning,
        icon: '⚠️',
        title: l10n.insufficientCalories(periodName),
        message: message,
        personalization: '${l10n.basedOnProfile ?? 'Based on'}: ${profile.age}, ${profile.gender == 'male' ? l10n.male : l10n.female}, ${activityLevelDisplayName ?? profile.activityLevel}',
      ));
    } else if (calorieRatio > 1.3) {
      String message;
      if (bmiCategoryKey == 'bmiOverweight' || bmiCategoryKey.startsWith('bmiObese')) {
        message = l10n.analysisCaloriesHighOverweight(periodName, avgDailyCalories.toInt().toString(), daysSuffix);
      } else {
        message = l10n.analysisCaloriesHighNormal(periodName, avgDailyCalories.toInt().toString(), daysSuffix);
      }
      
      cards.add(PersonalizedAnalysisCard(
        type: AnalysisCardType.danger,
        icon: '🚨',
        title: l10n.excessiveCalories(periodName),
        message: message,
        personalization: '${l10n.basedOnProfile ?? 'Based on'}: ${profile.age}, ${profile.gender == 'male' ? l10n.male : l10n.female}, ${activityLevelDisplayName ?? profile.activityLevel}',
      ));
    } else {
      cards.add(PersonalizedAnalysisCard(
        type: AnalysisCardType.success,
        icon: '✅',
        title: l10n.appropriateCalories(periodName),
        message: l10n.appropriateCaloriesMessage(periodName, avgDailyCalories.toInt().toString(), daysSuffix),
        personalization: '${l10n.meetsRecommended ?? 'Meets recommended'}: ${avgDailyRecommended.toInt()} ${l10n.kcalPerDay ?? 'kcal/day'}',
      ));
    }
    
    // 2. 蛋白質分析（基於體重和活動程度）
    final avgDailyProtein = nutrition.protein / recordDays;
    final proteinRatio = avgDailyProtein / recommended['protein']!;
    
    if (proteinRatio < 0.8) {
      String message;
      if (profile.activityLevel == 'very_active' || profile.activityLevel == 'active') {
        message = l10n.analysisProteinLowHighActivity;
      } else if (profile.age > 50) {
        message = l10n.analysisProteinLowElderly;
      } else {
        message = l10n.analysisProteinLowGeneral;
      }
      
      cards.add(PersonalizedAnalysisCard(
        type: AnalysisCardType.warning,
        icon: '🥩',
        title: l10n.proteinInsufficient,
        message: message,
        personalization: '${l10n.recommendedIntake ?? 'Recommended'}: ${recommended['protein']!.toInt()}g/${l10n.day ?? 'day'}',
      ));
    } else if (proteinRatio > 1.5) {
      cards.add(PersonalizedAnalysisCard(
        type: AnalysisCardType.info,
        icon: '💪',
        title: l10n.proteinSufficient,
        message: l10n.proteinSufficientMessage,
        personalization: '${l10n.currentIntake ?? 'Current'}: ${avgDailyProtein.toInt()}g/${l10n.day ?? 'day'}',
      ));
    }
    
    // 3. 碳水化合物分析（基於活動程度）
    final avgDailyCarbs = nutrition.carbs / recordDays;
    final carbsRatio = avgDailyCarbs / recommended['carbs']!;
    
    if (profile.activityLevel == 'very_active' || profile.activityLevel == 'active') {
      if (carbsRatio < 0.7) {
        cards.add(PersonalizedAnalysisCard(
          type: AnalysisCardType.warning,
          icon: '🏃',
          title: l10n.carbsInsufficient,
          message: l10n.analysisCarbsLowHighActivity,
          personalization: '${l10n.recommendedIntake ?? 'Recommended'}: ${recommended['carbs']!.toInt()}g/${l10n.day ?? 'day'}',
        ));
      }
    } else {
      if (carbsRatio > 1.3) {
        cards.add(PersonalizedAnalysisCard(
          type: AnalysisCardType.warning,
          icon: '🍞',
          title: l10n.carbsExcessive,
          message: l10n.analysisCarbsHighLowActivity,
          personalization: '${l10n.recommendedIntake ?? 'Recommended'}: ${recommended['carbs']!.toInt()}g/${l10n.day ?? 'day'}',
        ));
      }
    }
    
    // 4. 脂肪分析（基於性別和年齡）
    final avgDailyFat = nutrition.fat / recordDays;
    final fatRatio = avgDailyFat / recommended['fat']!;
    
    if (fatRatio > 1.4) {
      String message;
      if (profile.gender == 'female' && profile.age > 50) {
        message = l10n.analysisFatHighElderlyFemale;
      } else {
        message = l10n.analysisFatHighGeneral;
      }
      
      cards.add(PersonalizedAnalysisCard(
        type: AnalysisCardType.warning,
        icon: '🫒',
        title: l10n.fatExcessive,
        message: message,
        personalization: '${l10n.recommendedIntake ?? 'Recommended'}: ${recommended['fat']!.toInt()}g/${l10n.day ?? 'day'}',
      ));
    }
    
    // 5. 鈉攝取分析（基於年齡）
    final avgDailySodium = nutrition.sodium / recordDays;
    final sodiumLimit = profile.age < 50 ? 2300.0 : 1500.0;
    
    if (avgDailySodium > sodiumLimit) {
      String message;
      if (profile.age >= 50) {
        message = l10n.analysisSodiumHighElderly;
      } else {
        message = l10n.analysisSodiumHighGeneral;
      }
      
      cards.add(PersonalizedAnalysisCard(
        type: AnalysisCardType.danger,
        icon: '🧂',
        title: l10n.sodiumExcessive,
        message: message,
        personalization: '${l10n.recommendedIntake ?? 'Recommended'}: ${sodiumLimit.toInt()}mg/${l10n.day ?? 'day'}',
      ));
    }
    
    // 6. 膳食纖維分析（基於性別和年齡）
    final avgDailyFiber = nutrition.fiber / recordDays;
    final fiberGoal = recommended['fiber']!;
    
    if (avgDailyFiber < fiberGoal * 0.7) {
      String message;
      if (profile.gender == 'female' && profile.age > 50) {
        message = l10n.analysisFiberLowElderlyFemale;
      } else {
        message = l10n.analysisFiberLowGeneral;
      }
      
      cards.add(PersonalizedAnalysisCard(
        type: AnalysisCardType.info,
        icon: '🥬',
        title: l10n.fiberInsufficient,
        message: message,
        personalization: '${l10n.recommendedIntake ?? 'Recommended'}: ${fiberGoal.toInt()}g/${l10n.day ?? 'day'}',
      ));
    }
    
    // 7. BMI 相關建議
    if (bmiCategoryKey == 'bmiUnderweight' && calorieRatio < 0.9) {
      cards.add(PersonalizedAnalysisCard(
        type: AnalysisCardType.warning,
        icon: '📈',
        title: l10n.weightUnderweight,
        message: l10n.analysisBmiUnderweightWarning,
        personalization: 'BMI: ${bmi.toStringAsFixed(1)} ($bmiCategoryDisplay)',
      ));
    } else if ((bmiCategoryKey == 'bmiOverweight' || bmiCategoryKey.startsWith('bmiObese')) && calorieRatio > 1.1) {
      cards.add(PersonalizedAnalysisCard(
        type: AnalysisCardType.danger,
        icon: '⚖️',
        title: l10n.weightControl,
        message: l10n.analysisBmiOverweightWarning,
        personalization: 'BMI: ${bmi.toStringAsFixed(1)} ($bmiCategoryDisplay)',
      ));
    }
    
    return cards;
  }

  /// 獲取時間段天數
  static int _getPeriodDays(String period) {
    switch (period) {
      case 'today':
        return 1;
      case 'week':
        return 7;
      case 'month':
        return 31;
      default:
        return 1;
    }
  }

  /// 獲取時間段名稱
  static String _getPeriodName(String period, AppLocalizations l10n) {
    switch (period) {
      case 'today':
        return l10n.today;
      case 'week':
        return l10n.thisWeek;
      case 'month':
        return l10n.thisMonth;
      default:
        return l10n.current;
    }
  }

  static String _getBmiCategoryDisplay(String key, AppLocalizations l10n) {
    switch (key) {
      case 'bmiUnderweight': return l10n.bmiUnderweight;
      case 'bmiNormal': return l10n.bmiNormal;
      case 'bmiOverweight': return l10n.bmiOverweight;
      case 'bmiObeseMild': return l10n.bmiObeseMild;
      case 'bmiObeseModerate': return l10n.bmiObeseModerate;
      case 'bmiObeseSevere': return l10n.bmiObeseSevere;
      default: return key;
    }
  }
}

/// 個性化分析卡片
class PersonalizedAnalysisCard {
  final AnalysisCardType type;
  final String icon;
  final String title;
  final String message;
  final String personalization; // 個性化說明

  PersonalizedAnalysisCard({
    required this.type,
    required this.icon,
    required this.title,
    required this.message,
    required this.personalization,
  });
}

/// 分析卡片類型
enum AnalysisCardType {
  success,
  warning,
  danger,
  info,
}
