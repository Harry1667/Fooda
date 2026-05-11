import 'dart:io';
import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import 'edit_meal_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';

/// 營養記錄卡片組件
/// 完全對應 web 端的 meal-record-card 樣式
class MealRecordCard extends StatelessWidget {
  final MealRecord meal;
  final VoidCallback? onTap;
  final bool showWarning;

  const MealRecordCard({
    super.key,
    required this.meal,
    this.onTap,
    this.showWarning = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左側：餐點名稱 + 縮略圖 (30%)
            Expanded(
              flex: 3,
              child: _buildMealLeft(context),
            ),
            
            const SizedBox(width: 12),
            
            // 右側：營養素 + 警告 (70%)
            Expanded(
              flex: 7,
              child: _buildMealRight(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 左側：餐點名稱 + 縮略圖
  Widget _buildMealLeft(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 餐點名稱
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            meal.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(height: 6),
        
        // 縮略圖（更緊湊的正方形）
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: meal.imageUrl != null
                ? _buildImage(meal.imageUrl!)
                : _buildPlaceholderImage(),
          ),
        ),
      ],
    );
  }

  /// 構建圖片 Widget（支持網絡和本地路徑）
  Widget _buildImage(String imagePath) {
    // 判斷是網絡路徑還是本地路徑
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // 網絡圖片
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      // 本地文件
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('🔴 圖片載入失敗: $imagePath');
            print('🔴 錯誤: $error');
            return _buildPlaceholderImage();
          },
        );
      } else {
        print('🔴 圖片文件不存在: $imagePath');
        return _buildPlaceholderImage();
      }
    }
  }

  /// 佔位圖
  Widget _buildPlaceholderImage() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.restaurant,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        );
      },
    );
  }

  /// 右側：營養素 + 警告
  Widget _buildMealRight(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 營養素
        _buildMacrosDisplay(context),
        
        if (showWarning) ...[
          const SizedBox(height: 8),
          // 健康警告
          _buildWarning(context),
        ],
      ],
    );
  }

  /// 營養素顯示（兩欄佈局）
  Widget _buildMacrosDisplay(BuildContext context) {
    final nutrition = meal.nutrition.total;
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左欄：碳水、蛋白質、脂肪
        Expanded(
          child: Column(
            children: [
              _buildMacroRow(l10n.carbs, '${nutrition.carbs.toStringAsFixed(1)}g', AppTheme.macroCarbs),
              const SizedBox(height: 5),
              _buildMacroRow(l10n.protein, '${nutrition.protein.toStringAsFixed(1)}g', AppTheme.macroProtein),
              const SizedBox(height: 5),
              _buildMacroRow(l10n.fat, '${nutrition.fat.toStringAsFixed(1)}g', AppTheme.macroFat),
            ],
          ),
        ),
        
        const SizedBox(width: 8),
        
        // 右欄：鈉、纖維、熱量
        Expanded(
          child: Column(
            children: [
              _buildMacroRow(l10n.sodium, '${(nutrition.sodium).toStringAsFixed(1)}mg', AppTheme.macroSodium),
              const SizedBox(height: 5),
              _buildMacroRow(l10n.fiber, '${nutrition.fiber.toStringAsFixed(1)}g', AppTheme.macroFiber),
              const SizedBox(height: 5),
              _buildMacroRow(l10n.calories, '${nutrition.calories.toInt()}kcal', AppTheme.macroCalories),
            ],
          ),
        ),
      ],
    );
  }

  /// 單個營養素行
  Widget _buildMacroRow(String label, String value, Color color) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // 色點
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              
              const SizedBox(width: 4),
              
              // 標籤和數值（使用 Expanded 代替 Flexible）
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 標籤
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 4),
                    
                    // 數值
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 健康警告
  Widget _buildWarning(BuildContext context) {
    final warning = _generateFoodWarning(context, meal.name);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(
            color: AppTheme.errorColor,
            width: 3,
          ),
        ),
      ),
      child: Text(
        warning,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.errorColor,
          height: 1.3,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// 根據食物名稱生成健康注意事項
  String _generateFoodWarning(BuildContext context, String foodName) {
    if (foodName.contains(RegExp(r'炸|油炸|酥脆|Fried'))) {
      return AppLocalizations.of(context)!.warningFried ?? '💛 Fried food, consume in moderation.';
    } else if (foodName.contains(RegExp(r'甜|糖|蛋糕|餅乾|Sugar|Cake|Cookie'))) {
      return AppLocalizations.of(context)!.warningSugar ?? '🍯 High sugar/fat, enjoy in moderation.';
    } else if (foodName.contains(RegExp(r'肉|牛|豬|雞|Meat|Beef|Pork|Chicken'))) {
      return AppLocalizations.of(context)!.warningProtein ?? '🍖 Protein rich, pair with veggies.';
    } else if (foodName.contains(RegExp(r'菜|沙拉|蔬|Salad|Veg'))) {
      return AppLocalizations.of(context)!.warningVeg ?? '🥗 Vitamin/Fiber rich, excellent choice.';
    }
    
    return AppLocalizations.of(context)!.warningBalanced ?? '🌟 Balanced diet, healthy living.';
  }
}

