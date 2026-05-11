import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../meals/providers/meal_provider.dart';
import '../profile/providers/profile_provider.dart';
import '../membership/providers/membership_provider.dart';
import '../membership/membership_screen.dart';
import '../../core/widgets/meal_record_card.dart';
import '../../core/widgets/edit_meal_dialog.dart';
import '../../core/models/meal_model.dart';
import '../../core/services/smart_analysis_service.dart';
import '../../core/theme/text_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

import '../tutorial/tutorial_controller.dart';
import '../tutorial/showcase_widget_wrapper.dart';
import '../tutorial/tutorial_config.dart';


/// 首頁
/// 完全對應 PHP 版本的 firstpage.php
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 頂部標題（對應 header）
            _buildHeader(context),
            
            // 主要內容（可滾動）
            Expanded(
              child: Consumer2<MealProvider, ProfileProvider>(
                builder: (context, mealProvider, profileProvider, child) {
                  // 獲取今日餐點
                  final todayMeals = mealProvider.todayMeals;
                  
                  // 計算今日營養總和
                  final todayNutrition = mealProvider.todayNutrition;
                  
                  // 根據個人資料計算營養目標
                  final recommendedCalories = profileProvider.caloriesGoal;
                  final caloriesConsumed = todayNutrition.calories.toInt();
                  final progress = todayNutrition.calories / recommendedCalories;
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [


                        // 今日營養攝取模塊（對應 nutrition-overview-card）
                        ShowcaseWidgetWrapper(
                          showcaseKey: FoodaApp.tutorialController.nutritionCardKey,
                          title: TutorialConfig.getTitle(context, TutorialStep.step2_nutritionCard),
                          description: TutorialConfig.getDescription(context, TutorialStep.step2_nutritionCard),
                          step: TutorialStep.step2_nutritionCard,
                          targetShapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          disposeOnTap: true,
                          child: _buildNutritionOverviewCard(
                            context,
                            recommendedCalories.toInt(),
                            caloriesConsumed,
                            progress,
                            todayNutrition,
                          ).animate().slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutBack).fadeIn(duration: 600.ms),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 活動區域（對應 activity-section）
                        ShowcaseWidgetWrapper(
                          showcaseKey: FoodaApp.tutorialController.recordCardKey,
                          title: FoodaApp.tutorialController.currentStep == TutorialStep.step12_showRecord
                              ? AppLocalizations.of(context)!.tutorialStep12Title
                              : AppLocalizations.of(context)!.todayNutrition,
                          description: AppLocalizations.of(context)!.tutorialStep12Desc,
                          disposeOnTap: true,
                          step: FoodaApp.tutorialController.currentSession == TutorialSession.finalStep 
                              ? TutorialStep.step12_showRecord 
                              : TutorialStep.step2_nutritionCard,
                          targetShapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: _buildActivitySection(context, todayMeals),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 頂部標題（對應 header.header）
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    
    // Localized Date Format
    final String dateStr = DateFormat.yMd(Localizations.localeOf(context).toString()).format(now);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左側：Fooda Logo
          // 左側：Streak Counter
          Consumer<MealProvider>(
            builder: (context, mealProvider, child) {
              final streak = mealProvider.currentStreak;
              return Row(
                children: [
                  const Text(
                    '🔥',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$streak',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: context.primaryText,
                      letterSpacing: -0.5,
                      fontFamily: 'Rounded',
                    ),
                  ),
                ],
              );
            },
          ),
          

          // 中間：日期
          Flexible(
            child: Text(
              dateStr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.secondaryText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // 右側：會員狀態
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MembershipScreen()),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<MembershipProvider>(
                  builder: (context, membership, child) {
                    if (membership.isFree) {
                      return Container(
                        constraints: const BoxConstraints(maxWidth: 120), // Prevent right side overflow
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Text(
                          l10n.aiQuota(membership.remainingAiQuota, 10) ?? 'AI: ${membership.remainingAiQuota}/10',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),

                      );
                    } else {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                width: 1.5,
                                color: AppTheme.premiumGold, 
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.premiumGold.withOpacity(0.1),
                                  const Color(0xFFFFA500).withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.premium,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.premiumGoldDark, 
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${membership.aiQuotaUsedThisMonth}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary, 
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                

              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 今日營養攝取卡片（對應 nutrition-overview-card）
  Widget _buildNutritionOverviewCard(
    BuildContext context,
    int calorieTarget,
    int caloriesConsumed,
    double progress,
    NutritionData todayNutrition,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題行（對應 overview-header）
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.todayNutrition,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${AppLocalizations.of(context)!.calorieGoal}: $calorieTarget ${AppLocalizations.of(context)!.kcal}',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 熱量進度和營養素網格（對應 calories-progress）
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左側：圓環進度（對應 progress-circle）
              _buildCircularProgress(context, caloriesConsumed, progress),
              
              const SizedBox(width: 24),
              
              // 右側：營養素網格（對應 macros-grid）
              Expanded(
                child: _buildMacrosGrid(context, todayNutrition),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 圓環進度（對應 circle-container）
  Widget _buildCircularProgress(BuildContext context, int calories, double progress) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // "熱量" 標籤
        Text(
          AppLocalizations.of(context)!.calories,
          style: TextStyle(
            fontSize: 12,
            color: context.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        
        // 圓環
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景圓環
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              // 進度圓環
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.secondary,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ).animate().custom(
                duration: 1000.ms,
                curve: Curves.easeOut,
                builder: (context, value, child) => SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: progress * value,
                    strokeWidth: 12,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.secondary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
              // 中間數字
              SizedBox(
                width: 70, // 限制寬度，圓環直徑為 90，保留一些邊距
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        calories.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.primaryText,
                        ),
                      ),
                    ),
                    Text(
                      'kcal',
                      style: TextStyle(
                        fontSize: 10,
                        color: context.hintText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 營養素網格（對應 macros-grid）
  Widget _buildMacrosGrid(BuildContext context, NutritionData nutrition) {
    // 使用 MediaQuery 獲取螢幕寬度
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Column(
      children: [
        // 碳水化合物
        _buildMacroItem(
          context,
          AppLocalizations.of(context)!.carbs,
          '${nutrition.carbs.toStringAsFixed(0)}${AppLocalizations.of(context)!.gram}',
          AppTheme.macroCarbs,
          Icons.rice_bowl,
          isSmallScreen,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        
        // 蛋白質
        _buildMacroItem(
          context,
          AppLocalizations.of(context)!.protein,
          '${nutrition.protein.toStringAsFixed(0)}${AppLocalizations.of(context)!.gram}',
          AppTheme.macroProtein,
          Icons.fitness_center,
          isSmallScreen,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        
        // 脂肪
        _buildMacroItem(
          context,
          AppLocalizations.of(context)!.fat,
          '${nutrition.fat.toStringAsFixed(0)}${AppLocalizations.of(context)!.gram}',
          AppTheme.macroFat,
          Icons.opacity,
          isSmallScreen,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        
        // 鈉
        _buildMacroItem(
          context,
          AppLocalizations.of(context)!.sodium,
          '${nutrition.sodium.toStringAsFixed(0)}${AppLocalizations.of(context)!.milligram}',
          AppTheme.macroSodium,
          Icons.grain,
          isSmallScreen,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        
        // 膳食纖維
        _buildMacroItem(
          context,
          AppLocalizations.of(context)!.fiber,
          '${nutrition.fiber.toStringAsFixed(0)}${AppLocalizations.of(context)!.gram}',
          AppTheme.macroFiber,
          Icons.grass,
          isSmallScreen,
        ),
      ],
    );
  }

  /// 單個營養素項目（對應 macro-item）
  Widget _buildMacroItem(BuildContext context, String label, String value, Color color, IconData icon, bool isSmallScreen) {
    final theme = Theme.of(context);
    final fontSize = isSmallScreen ? 10.0 : 11.0;
    final valueFontSize = isSmallScreen ? 11.0 : 12.0;
    final iconSize = isSmallScreen ? 12.0 : 14.0;
    
    return Row(
      children: [
        // 營養素圖標
        Icon(
          icon,
          size: iconSize,
          color: color,
        ),
        SizedBox(width: isSmallScreen ? 4 : 6),
        
        // 文字
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: context.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.w600,
                    color: context.primaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 活動區域（對應 activity-section）
  Widget _buildActivitySection(BuildContext context, List<dynamic> todayMeals) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 標題（對應 section-title）
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.navHistory,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.primaryText,
              ),
            ),
            Text(
              '${todayMeals.length} ${AppLocalizations.of(context)!.records ?? 'records'}',
              style: TextStyle(
                fontSize: 14,
                color: context.secondaryText,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 餐點記錄列表
        if (todayMeals.isEmpty)
          _buildEmptyMealRecords(context).animate().fadeIn(duration: 800.ms)
        else
          ...todayMeals.asMap().entries.map((entry) {
            final index = entry.key;
            final meal = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MealRecordCard(
                meal: meal,
                onTap: () => _showEditDialog(context, meal),
              ),
            ).animate().slideX(begin: 0.2, end: 0, delay: (100 * index).ms, duration: 500.ms, curve: Curves.easeOut).fadeIn(delay: (100 * index).ms, duration: 500.ms);
          }).toList(),
      ],
    );
  }

  /// 空餐點記錄（對應 #mealRecords 為空時）
  Widget _buildEmptyMealRecords(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 64,
              color: context.disabledText,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noRecordsYet ?? '還沒有餐點記錄',
              style: TextStyle(
                fontSize: 16,
                color: context.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.clickAddToStart ?? '點擊下方 ➕ 按鈕開始記錄',
              style: TextStyle(
                fontSize: 14,
                color: context.hintText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顯示編輯對話框
  void _showEditDialog(BuildContext context, MealRecord meal) {
    showDialog(
      context: context,
      builder: (context) => EditMealDialog(meal: meal),
    );
  }
}
