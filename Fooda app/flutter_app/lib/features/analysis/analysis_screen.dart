import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../meals/providers/meal_provider.dart';
import '../profile/providers/profile_provider.dart';
import '../../core/models/meal_model.dart';
import '../../core/services/smart_analysis_service.dart';
import '../../l10n/app_localizations.dart';
import '../membership/providers/membership_provider.dart';
import '../membership/membership_screen.dart';
import '../../core/theme/app_theme.dart';

/// 分析頁面
/// 完全對應 PHP 版本的 analyzepage.php
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String _selectedPeriod = 'today'; // today, week, month

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 時間選擇區域（對應 time-selection）
                    _buildTimeSelection(context),
                    
                    const SizedBox(height: 24),
                    
                    // 營養總覽（對應 nutrition-analysis）
                    _buildNutritionAnalysis(context),
                    
                    const SizedBox(height: 24),
                    
                    // 飲食分析區域（對應 diet-analysis）
                    _buildDietAnalysis(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 頂部標題（對應 header）
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
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
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.navAnalysis,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 時間選擇區域（對應 time-selection）
  Widget _buildTimeSelection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 時間範圍顯示（對應 time-range-display）
          Text(
            _getTimeRangeText(),
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 時間卡片（對應 time-cards）
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(context, AppLocalizations.of(context)!.today ?? '本日', 'today'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeCard(context, AppLocalizations.of(context)!.thisWeek ?? '本週', 'week'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeCard(context, AppLocalizations.of(context)!.thisMonth ?? '本月', 'month'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 時間卡片（對應 time-card）
  Widget _buildTimeCard(BuildContext context, String label, String period) {
    final theme = Theme.of(context);
    final isActive = _selectedPeriod == period;
    
    return GestureDetector(
      onTap: () {
        if (period != 'today') {
          final membership = Provider.of<MembershipProvider>(context, listen: false);
          if (!membership.hasAdvancedAnalysis) {
            _showUpgradeDialog();
            return;
          }
        }
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive 
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  /// 營養總覽（對應 nutrition-analysis）
  Widget _buildNutritionAnalysis(BuildContext context) {
    return Consumer2<MealProvider, ProfileProvider>(
      builder: (context, mealProvider, profileProvider, child) {
        // 計算營養數據
        final nutrition = _calculateNutrition(mealProvider);
        final calories = nutrition.calories.toInt();
        final recommendedCalories = profileProvider.caloriesGoal.toInt();
        final progress = math.min(calories / recommendedCalories, 1.0);
        
        return _buildNutritionCard(context, calories, recommendedCalories, progress, nutrition);
      },
    );
  }

  /// 營養卡片
  Widget _buildNutritionCard(
    BuildContext context,
    int calories,
    int recommendedCalories,
    double progress,
    NutritionData nutrition,
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
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _getAnalysisTitle(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '${AppLocalizations.of(context)!.recommended}: $recommendedCalories kcal',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 熱量進度和營養素網格（復用首頁組件）
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 圓環進度
              _buildCircularProgress(calories, progress),
              
              const SizedBox(width: 24),
              
              // 營養素網格
              Expanded(
                child: _buildMacrosGridWithData(context, nutrition),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 圓環進度
  Widget _buildCircularProgress(int calories, double progress) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Column(
          children: [
            Text(
              AppLocalizations.of(context)!.calories,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        ),
                      ),
                  ),
                  SizedBox(
                    width: 90,
                    height: 90,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.secondary,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                  ),
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
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          'kcal',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
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
      },
    );
  }

  /// 營養素網格（帶數據）

  Widget _buildMacrosGridWithData(BuildContext context, NutritionData nutrition) {
    // 使用 MediaQuery 獲取螢幕寬度
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Column(
      children: [
        // 碳水化合物
        _buildMacroItem(
          AppLocalizations.of(context)!.carbs,
          '${nutrition.carbs.toStringAsFixed(0)}${AppLocalizations.of(context)!.gram}',
          AppTheme.macroCarbs,
          Icons.rice_bowl,
          isSmallScreen,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        
        // 蛋白質
        _buildMacroItem(
          AppLocalizations.of(context)!.protein,
          '${nutrition.protein.toStringAsFixed(0)}${AppLocalizations.of(context)!.gram}',
          AppTheme.macroProtein,
          Icons.fitness_center,
          isSmallScreen,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        
        // 脂肪
        _buildMacroItem(
          AppLocalizations.of(context)!.fat,
          '${nutrition.fat.toStringAsFixed(0)}${AppLocalizations.of(context)!.gram}',
          AppTheme.macroFat,
          Icons.opacity,
          isSmallScreen,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        
        // 鈉
        _buildMacroItem(
          AppLocalizations.of(context)!.sodium,
          '${nutrition.sodium.toStringAsFixed(0)}${AppLocalizations.of(context)!.milligram}',
          AppTheme.macroSodium,
          Icons.grain,
          isSmallScreen,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        
        // 膳食纖維
        _buildMacroItem(
          AppLocalizations.of(context)!.fiber,
          '${nutrition.fiber.toStringAsFixed(0)}${AppLocalizations.of(context)!.gram}',
          AppTheme.macroFiber,
          Icons.grass,
          isSmallScreen,
        ),
      ],
    );
  }

  /// 營養素項目
  Widget _buildMacroItem(String label, String value, Color color, IconData icon, bool isSmallScreen) {
    final fontSize = isSmallScreen ? 10.0 : 11.0;
    final valueFontSize = isSmallScreen ? 11.0 : 12.0;
    final iconSize = isSmallScreen ? 12.0 : 14.0;
    
    return Row(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: color,
        ),
        SizedBox(width: isSmallScreen ? 4 : 6),
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
                    color: Theme.of(context).textTheme.bodyMedium?.color,
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
                  color: Theme.of(context).colorScheme.onSurface,
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

  /// 飲食分析區域（對應 diet-analysis）
  Widget _buildDietAnalysis(BuildContext context) {
    return Consumer2<MealProvider, ProfileProvider>(
      builder: (context, mealProvider, profileProvider, child) {
        final nutrition = _calculateNutrition(mealProvider);
        final actualRecordDays = _calculateActualRecordDays(mealProvider);
        final personalizedCards = SmartAnalysisService.generatePersonalizedAnalysis(
          profileProvider,
          nutrition,
          _selectedPeriod,
          AppLocalizations.of(context)!,
          actualRecordDays: actualRecordDays,
          activityLevelDisplayName: _getActivityLevelDisplayName(context, profileProvider.activityLevel),
        );
        
        if (personalizedCards.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noAnalysisData ?? '暫無分析數據',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.startRecordingHint ?? '開始記錄餐點後將顯示個性化分析建議',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Column(
          children: personalizedCards.map((card) => _buildPersonalizedAnalysisCard(card)).toList(),
        );
      },
    );
  }

  /// 構建個性化分析卡片
  Widget _buildPersonalizedAnalysisCard(PersonalizedAnalysisCard card) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        Color borderColor;
        Color bgColor;
        
        switch (card.type) {
          case AnalysisCardType.success:
            borderColor = AppTheme.alertSuccess;
            bgColor = borderColor.withOpacity(isDark ? 0.15 : 0.02);
            break;
          case AnalysisCardType.warning:
            borderColor = AppTheme.alertWarning;
            bgColor = borderColor.withOpacity(isDark ? 0.15 : 0.02);
            break;
          case AnalysisCardType.danger:
            borderColor = AppTheme.alertDanger;
            bgColor = borderColor.withOpacity(isDark ? 0.15 : 0.02);
            break;
          case AnalysisCardType.info:
            borderColor = AppTheme.alertInfo;
            bgColor = borderColor.withOpacity(isDark ? 0.15 : 0.02);
            break;
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: borderColor,
                width: 4,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 圖標
              Text(
                card.icon,
                style: const TextStyle(fontSize: 24),
              ),
              
              const SizedBox(width: 12),
              
              // 內容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        card.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      card.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 個性化說明
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              card.personalization,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }

  /// 構建分析卡片（保留舊方法以兼容）
  Widget _buildAnalysisCard(AnalysisCard card) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        Color borderColor;
        Color bgColor;
        
        switch (card.type) {
          case AnalysisCardType.success:
            borderColor = AppTheme.alertSuccess;
            bgColor = borderColor.withOpacity(isDark ? 0.15 : 0.02);
            break;
          case AnalysisCardType.warning:
            borderColor = AppTheme.alertWarning;
            bgColor = borderColor.withOpacity(isDark ? 0.15 : 0.02);
            break;
          case AnalysisCardType.danger:
            borderColor = AppTheme.alertDanger;
            bgColor = borderColor.withOpacity(isDark ? 0.15 : 0.02);
            break;
          case AnalysisCardType.info:
            borderColor = AppTheme.alertInfo;
            bgColor = borderColor.withOpacity(isDark ? 0.15 : 0.02);
            break;
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: borderColor,
                width: 4,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 圖標
              Text(
                card.icon,
                style: const TextStyle(fontSize: 24),
              ),
              
              const SizedBox(width: 12),
              
              // 內容
              Expanded(
                child: Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 獲取時間範圍文字
  String _getTimeRangeText() {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final actualRecordDays = _calculateActualRecordDays(mealProvider);
    
    switch (_selectedPeriod) {
      case 'today':
        return '${now.year}/${now.month}/${now.day}';
      case 'week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final recordDaysText = actualRecordDays > 0 
            ? '(${l10n.recordsRecorded(actualRecordDays) ?? "$actualRecordDays 天有記錄"})'
            : '(${l10n.noRecords ?? "無記錄"})';
        return '${_formatDate(startOfWeek)} - ${_formatDate(now)} $recordDaysText';
      case 'month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        final recordDaysText = actualRecordDays > 0 
            ? '(${l10n.recordsRecorded(actualRecordDays) ?? "$actualRecordDays 天有記錄"})'
            : '(${l10n.noRecords ?? "無記錄"})';
        return '${_formatDate(startOfMonth)} - ${_formatDate(now)} $recordDaysText';
      default:
        return '';
    }
  }

  /// 格式化日期顯示
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  /// 獲取分析標題
  String _getAnalysisTitle() {
    final l10n = AppLocalizations.of(context)!;
    switch (_selectedPeriod) {
      case 'today':
        return '${l10n.today ?? '本日'}${l10n.nutritionOverview ?? '營養總覽'}';
      case 'week':
        return '${l10n.thisWeek ?? '本週'}${l10n.nutritionOverview ?? '營養總覽'}';
      case 'month':
        return '${l10n.thisMonth ?? '本月'}${l10n.nutritionOverview ?? '營養總覽'}';
      default:
        return l10n.nutritionOverview ?? '營養總覽';
    }
  }

  // ========== 私有輔助方法 ==========

  /// 計算營養數據
  NutritionData _calculateNutrition(MealProvider mealProvider) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;
    
    switch (_selectedPeriod) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1));
        break;
      case 'week':
        // 本週一到星期日
        final dayOfWeek = now.weekday; // 1=星期一, 7=星期日
        startDate = now.subtract(Duration(days: dayOfWeek - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate.add(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;
      default:
        return NutritionData.empty();
    }
    
    return mealProvider.calculateTotalNutrition(startDate, endDate);
  }

  /// 計算實際記錄天數
  int _calculateActualRecordDays(MealProvider mealProvider) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;
    
    switch (_selectedPeriod) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1));
        break;
      case 'week':
        final dayOfWeek = now.weekday;
        startDate = now.subtract(Duration(days: dayOfWeek - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate.add(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;
      default:
        return 0;
    }
    
    // 獲取指定時間範圍內的所有餐點
    final meals = mealProvider.getMealsByDateRange(startDate, endDate);
    
    // 計算有記錄的天數
    final recordedDates = <DateTime>{};
    for (final meal in meals) {
      final mealDate = DateTime(
        meal.dateTime.year,
        meal.dateTime.month,
        meal.dateTime.day,
      );
      recordedDates.add(mealDate);
    }
    
    return recordedDates.length;
  }

  /// 獲取建議攝取熱量
  int _getRecommendedCalories() {
    // 基礎代謝率，可以根據用戶數據計算
    // 這裡使用簡化版本
    const dailyCalories = 2000;
    
    switch (_selectedPeriod) {
      case 'today':
        return dailyCalories;
      case 'week':
        return dailyCalories * 7;
      case 'month':
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        return dailyCalories * daysInMonth;
      default:
        return dailyCalories;
    }
  }

  /// 生成分析卡片
  List<AnalysisCard> _generateAnalysisCards(
    NutritionData nutrition,
    int recommendedCalories,
  ) {
    final cards = <AnalysisCard>[];
    
    // 如果沒有數據，返回空列表
    if (nutrition.calories == 0) {
      return cards;
    }
    
    final periodDays = _getPeriodDays();
    final avgDailyCalories = nutrition.calories / periodDays;
    final dailyRecommended = 2000.0;
    
    // 熱量分析
    final calorieRatio = nutrition.calories / recommendedCalories;
    final avgCalorieRatio = avgDailyCalories / dailyRecommended;
    
    if (_selectedPeriod == 'today') {
      // 本日分析
      if (calorieRatio < 0.7) {
        cards.add(AnalysisCard(
          type: AnalysisCardType.warning,
          icon: '🍞',
          title: AppLocalizations.of(context)!.caloriesLowTitle ?? '熱量攝取不足',
          message: AppLocalizations.of(context)!.caloriesLowMessage ?? '今日攝取熱量低於建議值，建議增加營養密度高的食物攝取。',
        ));
      } else if (calorieRatio > 1.2) {
        cards.add(AnalysisCard(
          type: AnalysisCardType.danger,
          icon: '🚨',
          title: AppLocalizations.of(context)!.caloriesHighTitle ?? '熱量攝取過量',
          message: AppLocalizations.of(context)!.caloriesHighMessage ?? '今日攝取熱量超過建議值，建議控制食物份量，選擇低熱量高營養的食物。',
        ));
      } else {
        cards.add(AnalysisCard(
          type: AnalysisCardType.success,
          icon: '✅',
          title: AppLocalizations.of(context)!.caloriesGoodTitle ?? '熱量攝取適當',
          message: AppLocalizations.of(context)!.caloriesGoodMessage ?? '今日熱量攝取在合理範圍內，繼續保持均衡飲食。',
        ));
      }
    } else {
      // 本週/本月分析
      final l10n = AppLocalizations.of(context)!;
      final periodName = _selectedPeriod == 'week' ? (l10n.thisWeek ?? '本週') : (l10n.thisMonth ?? '本月');
      if (avgCalorieRatio < 0.7) {
        cards.add(AnalysisCard(
          type: AnalysisCardType.warning,
          icon: '⚠️',
          title: '${periodName}${l10n.avgCaloriesLow ?? '平均熱量不足'}',
          message: '${l10n.avgDailyIntake ?? '平均每日攝取'} ${avgDailyCalories.toInt()} ${l10n.kcal ?? '大卡'}，${l10n.belowRecommended ?? '低於建議值'}。${l10n.increaseNutrientDenseFoods ?? '建議增加營養密度高的食物攝取'}。',
        ));
      } else if (avgCalorieRatio > 1.2) {
        cards.add(AnalysisCard(
          type: AnalysisCardType.danger,
          icon: '🚨',
          title: '${periodName}${l10n.avgCaloriesHigh ?? '平均熱量過量'}',
          message: '${l10n.avgDailyIntake ?? '平均每日攝取'} ${avgDailyCalories.toInt()} ${l10n.kcal ?? '大卡'}，${l10n.exceedsRecommended ?? '超過建議值'}。${l10n.controlPortions ?? '建議控制食物份量和選擇'}。',
        ));
      } else {
        cards.add(AnalysisCard(
          type: AnalysisCardType.success,
          icon: '✅',
          title: '${periodName}${l10n.caloriesControlGood ?? '熱量控制良好'}',
          message: '${l10n.avgDailyIntake ?? '平均每日攝取'} ${avgDailyCalories.toInt()} ${l10n.kcal ?? '大卡'}，${l10n.withinRange ?? '在合理範圍內'}。${l10n.keepItUp ?? '繼續保持'}！',
        ));
      }
    }
    
    // 營養素比例分析
    final totalMacros = nutrition.carbs + nutrition.protein + nutrition.fat;
    if (totalMacros > 0) {
      final carbsPercent = (nutrition.carbs / totalMacros) * 100;
      final proteinPercent = (nutrition.protein / totalMacros) * 100;
      final fatPercent = (nutrition.fat / totalMacros) * 100;
      
      if (carbsPercent > 60) {
        cards.add(AnalysisCard(
          type: AnalysisCardType.info,
          icon: '🥩',
          title: AppLocalizations.of(context)!.proteinLowTitle,
          message: AppLocalizations.of(context)!.proteinLowMessage,
        ));
      }
      
      if (proteinPercent < 15) {
        cards.add(AnalysisCard(
          type: AnalysisCardType.warning,
          icon: '🍟',
          title: AppLocalizations.of(context)!.fatHighTitle,
          message: AppLocalizations.of(context)!.fatHighMessage,
        ));
      }
      
      if (fatPercent > 35) {
        final l10n = AppLocalizations.of(context)!;
        cards.add(AnalysisCard(
          type: AnalysisCardType.warning,
          icon: '🫒',
          title: l10n.fatHighTitle ?? '脂肪攝取偏高',
          message: l10n.fatHighMessage ?? '建議減少油炸食品，選擇堅果、魚油等健康脂肪來源。',
        ));
      }
    }
    
    // 鈉攝取分析
    const dailySodiumLimit = 6000.0; // 6g = 6000mg
    final sodiumLimit = _selectedPeriod == 'today' ? dailySodiumLimit :
                        (_selectedPeriod == 'week' ? dailySodiumLimit * 7 : dailySodiumLimit * 31);
    final avgDailySodium = nutrition.sodium / periodDays;
    
    if (nutrition.sodium > sodiumLimit || avgDailySodium > dailySodiumLimit) {
      final l10n = AppLocalizations.of(context)!;
      final periodName = _selectedPeriod == 'week' ? (l10n.thisWeek ?? '本週') : (l10n.thisMonth ?? '本月');
      final message = _selectedPeriod == 'today'
          ? (l10n.sodiumHighTodayMessage ?? '今日鈉攝取量超過建議值，建議選擇低鈉食品。')
          : '${periodName}${l10n.avgDailySodiumIntake ?? '平均每日鈉攝取'} ${(avgDailySodium / 1000).toStringAsFixed(1)}g，${l10n.exceedsRecommended ?? '超過建議值'}。${l10n.chooseLowSodiumFoods ?? '建議選擇低鈉食品'}。';
      
      cards.add(AnalysisCard(
        type: AnalysisCardType.danger,
        icon: '🧂',
        title: l10n.sodiumHighTitle ?? '鈉攝取過高',
        message: message,
      ));
    }
    
    // 膳食纖維分析
    const dailyFiberTarget = 25.0; // 25g
    final fiberTarget = _selectedPeriod == 'today' ? dailyFiberTarget :
                        (_selectedPeriod == 'week' ? dailyFiberTarget * 7 : dailyFiberTarget * 31);
    final avgDailyFiber = nutrition.fiber / periodDays;
    
    if (nutrition.fiber < fiberTarget || avgDailyFiber < dailyFiberTarget) {
      final l10n = AppLocalizations.of(context)!;
      final periodName = _selectedPeriod == 'week' ? (l10n.thisWeek ?? '本週') : (l10n.thisMonth ?? '本月');
      final message = _selectedPeriod == 'today'
          ? (l10n.fiberLowTodayMessage ?? '今日膳食纖維攝取不足，建議增加蔬果攝取。')
          : '${periodName}${l10n.avgDailyFiberIntake ?? '平均每日膳食纖維'} ${avgDailyFiber.toStringAsFixed(0)}g，${l10n.increaseVegetableFruit ?? '建議增加蔬果攝取'}。';
      
      cards.add(AnalysisCard(
        type: AnalysisCardType.info,
        icon: '🥬',
        title: l10n.fiberLowTitle ?? '膳食纖維不足',
        message: message,
      ));
    }
    
    return cards;
  }

  /// 獲取活動程度的多語言顯示名稱
  String _getActivityLevelDisplayName(BuildContext context, String activityLevel) {
    final l10n = AppLocalizations.of(context)!;
    switch (activityLevel) {
      case 'sedentary':
        return l10n.activitySedentary;
      case 'light':
        return l10n.activityLight;
      case 'moderate':
        return l10n.activityModerate;
      case 'active':
        return l10n.activityHigh;
      case 'very_active':
        return l10n.activityExtreme;
      default:
        return l10n.activityModerate;
    }
  }

  /// 獲取當前周期的天數
  int _getPeriodDays() {
    switch (_selectedPeriod) {
      case 'today':
        return 1;
      case 'week':
        return 7;
      case 'month':
        final now = DateTime.now();
        return DateTime(now.year, now.month + 1, 0).day;
      default:
        return 1;
    }
  }
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.advancedAnalysisFeature),
        content: Text(AppLocalizations.of(context)!.unlockPremiumAnalysis),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MembershipScreen()),
              );
            },
            child: Text(AppLocalizations.of(context)!.upgradeToPremium),
          ),
        ],
      ),
    );
  }
}


/// 分析卡片
class AnalysisCard {
  final AnalysisCardType type;
  final String icon;
  final String title;
  final String message;

  const AnalysisCard({
    required this.type,
    required this.icon,
    required this.title,
    required this.message,
  });
}
