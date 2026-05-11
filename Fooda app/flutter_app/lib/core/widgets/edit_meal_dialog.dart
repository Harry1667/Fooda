import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_model.dart';
import '../../features/meals/providers/meal_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';

/// 編輯餐點對話框
class EditMealDialog extends StatefulWidget {
  final MealRecord meal;

  const EditMealDialog({super.key, required this.meal});

  @override
  State<EditMealDialog> createState() => _EditMealDialogState();
}

class _EditMealDialogState extends State<EditMealDialog> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late String _selectedType;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meal.name);
    _notesController = TextEditingController(text: widget.meal.notes ?? '');
    _selectedType = widget.meal.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 標題欄
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
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
                  Text(
                    AppLocalizations.of(context)!.editMealRecord,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // 內容區域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 餐點名稱
                    _buildFormField(
                      label: AppLocalizations.of(context)!.mealName,
                      controller: _nameController,
                    ),
                    

                    if (widget.meal.nutrition.total.calories > 0) ...[
                       _buildNutritionGrid(context, widget.meal.nutrition.total),
                       const SizedBox(height: 24),
                       Divider(color: theme.dividerColor),
                       const SizedBox(height: 24),
                    ],

                    if (widget.meal.foods.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildAiAnalysisResult(),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // 餐點類型
                    _buildMealTypeSelector(),
                    
                    const SizedBox(height: 16),
                    
                    // 備註
                    _buildFormField(
                      label: AppLocalizations.of(context)!.notes,
                      controller: _notesController,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            
            // 操作按鈕
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 刪除按鈕
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _deleteMeal,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('🗑️ ${AppLocalizations.of(context)!.delete}'),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 保存按鈕
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveMeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '💾 ${AppLocalizations.of(context)!.save}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeSelector() {
    final theme = Theme.of(context);
    final types = [
      MealType.breakfast,
      MealType.morningSnack,
      MealType.lunch,
      MealType.afternoonTea,
      MealType.dinner,
      MealType.lateNight,
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.mealType,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedType,
          dropdownColor: theme.cardColor,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          items: types.map((type) {
            return DropdownMenuItem<String>(
              value: type.value,
              child: Text(type.getDisplayName(context)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildAiAnalysisResult() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.aiAnalysisResult,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: widget.meal.foods.map((food) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        food.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${food.grams.toInt()}g · ${food.nutrition.calories.toInt()} kcal',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _saveMeal() async {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    
    // 創建更新後的餐點
    final updatedMeal = widget.meal.copyWith(
      name: _nameController.text,
      type: _selectedType,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );
    
    // 保存更新
    final success = await mealProvider.updateMeal(widget.meal.id, updatedMeal);
    
    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.recordUpdated),
            backgroundColor: const Color(0xFF27AE60),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.updateFailedRetry),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _deleteMeal() async {
    // 顯示確認對話框
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDelete),
        content: Text(AppLocalizations.of(context)!.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      final mealProvider = Provider.of<MealProvider>(context, listen: false);
      final success = await mealProvider.deleteMeal(widget.meal.id);
      
      if (mounted) {
        Navigator.pop(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.recordDeleted),
              backgroundColor: const Color(0xFF27AE60),
            ),
          );
        }
      }
    }
  }
  Widget _buildNutritionGrid(BuildContext context, NutritionData nutrition) {
    // Calculate progress (assuming 2000 kcal for daily goal context, or just show raw data)
    // Since this is a single meal, progress relative to daily goal might be confusing if not labeled 'of daily goal'
    // But for visual consistency with Home Screen, we can just show the circle with calorie count.
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circle
        _buildCircularProgress(context, nutrition.calories.toInt()),
        
        const SizedBox(width: 24),
        
        // Grid
        Expanded(
          child: Column(
            children: [
              _buildMacroItem(context, AppLocalizations.of(context)!.carbs, '${nutrition.carbs.toStringAsFixed(0)}g', AppTheme.macroCarbs, Icons.rice_bowl),
              const SizedBox(height: 8),
              _buildMacroItem(context, AppLocalizations.of(context)!.protein, '${nutrition.protein.toStringAsFixed(0)}g', AppTheme.macroProtein, Icons.fitness_center),
              const SizedBox(height: 8),
              _buildMacroItem(context, AppLocalizations.of(context)!.fat, '${nutrition.fat.toStringAsFixed(0)}g', AppTheme.macroFat, Icons.opacity),
              const SizedBox(height: 8),
              _buildMacroItem(context, AppLocalizations.of(context)!.sodium, '${nutrition.sodium.toStringAsFixed(0)}mg', AppTheme.macroSodium, Icons.grain),
              const SizedBox(height: 8),
              _buildMacroItem(context, AppLocalizations.of(context)!.fiber, '${nutrition.fiber.toStringAsFixed(0)}g', AppTheme.macroFiber, Icons.grass),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularProgress(BuildContext context, int calories) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.calories,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 1.0, 
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              // We don't show specific progress % for single meal, just the full circle decoration
              // Or we could show % of 600-800kcal (meal goal)? 
              // For now, just a full colored ring or partial ring? 
              // Let's use a full secondary ring to look "active"
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 1.0, 
                  strokeWidth: 8,
                   valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.secondary.withOpacity(0.5),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    calories.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem(BuildContext context, String label, String value, Color color, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

