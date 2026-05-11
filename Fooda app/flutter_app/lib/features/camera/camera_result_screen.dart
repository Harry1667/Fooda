import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/models/meal_model.dart';
import '../meals/providers/meal_provider.dart';
import '../../main.dart';
import '../tutorial/tutorial_controller.dart';
import '../../l10n/app_localizations.dart';


/// 相機拍照結果頁面
/// 顯示 AI 識別結果
class CameraResultScreen extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic> analysisResult;
  
  const CameraResultScreen({
    super.key,
    required this.imageFile,
    required this.analysisResult,
  });

  // 獲取識別的食物列表
  List<Map<String, dynamic>> get items {
    if (analysisResult['items'] != null) {
      return List<Map<String, dynamic>>.from(analysisResult['items']);
    }
    return [];
  }

  @override
  State<CameraResultScreen> createState() => _CameraResultScreenState();
}

class _CameraResultScreenState extends State<CameraResultScreen> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
  }

  /// 保存 AI 識別結果為餐點記錄
  Future<void> _saveMealRecord(BuildContext context) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final mealProvider = Provider.of<MealProvider>(context, listen: false);
      
      // 將 AI 識別結果轉換為 FoodItem 列表
      final List<FoodItem> foods = widget.items.map((item) {
        // 解析份量（假設格式為 "150g"）
        final portionStr = item['portion'] ?? '100g';
        final grams = double.tryParse(portionStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 100.0;
        
        return FoodItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: item['name'] ?? AppLocalizations.of(context)!.unknownError,
          nameEn: item['englishName'] ?? item['name'] ?? 'Unknown',
          grams: grams,
          nutrition: NutritionData(
            calories: (item['calories'] ?? 0).toDouble(),
            carbs: (item['carbs'] ?? 0).toDouble(),
            protein: (item['protein'] ?? 0).toDouble(),
            fat: (item['fat'] ?? 0).toDouble(),
            sodium: (item['sodium'] ?? 0).toDouble(),
            fiber: (item['fiber'] ?? 0).toDouble(),
          ),
          isAiRecognized: true,
        );
      }).toList();
      
      // 計算營養總和
      final totalNutrition = foods.fold<NutritionData>(
        NutritionData.empty(),
        (total, food) => total + food.nutrition,
      );
      
      // 創建 NutritionSummary
      final goals = NutritionData(
        calories: 2000,
        carbs: 250,
        protein: 75,
        fat: 67,
        sodium: 2300,
        fiber: 25,
      );
      
      final nutritionSummary = NutritionSummary.calculate(totalNutrition, goals);
      
      // 生成餐點名稱（使用第一個食物名稱，或組合多個）
      String mealName;
      if (foods.length == 1) {
        mealName = foods[0].name;
      } else if (foods.length <= 3) {
        // Use comma for joins ensuring international friendly
        mealName = foods.map((f) => f.name).join(', ');
      } else {
        // "Burger and 3 others" style
        // Since we don't have a complex formatting key, stick to "Item1, Item2..." or simple truncation
        // Or "Item1..."
        mealName = foods.take(2).map((f) => f.name).join(', ') + '...';
      }
      
      // 根據當前時間判斷餐食類型
      final now = DateTime.now();
      String mealType = 'lunch';
      if (now.hour >= 6 && now.hour < 10) {
        mealType = 'breakfast';
      } else if (now.hour >= 10 && now.hour < 12) {
        mealType = 'morning-snack';
      } else if (now.hour >= 12 && now.hour < 15) {
        mealType = 'lunch';
      } else if (now.hour >= 15 && now.hour < 18) {
        mealType = 'afternoon-tea';
      } else if (now.hour >= 18 && now.hour < 22) {
        mealType = 'dinner';
      } else {
        mealType = 'late-night';
      }
      
      // 創建 MealRecord
      final meal = MealRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: mealName,
        type: mealType,
        dateTime: now,
        foods: foods,
        nutrition: nutritionSummary,
        imageUrl: widget.imageFile.path,
        notes: AppLocalizations.of(context)!.aiRecognition ?? 'AI Recognition',
      );
      
      // 保存到 Provider
      final success = await mealProvider.addMeal(meal);
      
      if (!context.mounted) return;
      
      if (success) {
        // 檢查是否在教學模式
        final tutorialController = FoodaApp.tutorialController;
        final isInTutorial = tutorialController.isTutorialActive && 
                             tutorialController.currentSession == TutorialSession.galleryAction;
        
        // 返回首頁
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        // 如果在教學模式，啟動步驟 12
        if (isInTutorial) {
          tutorialController.log('📝 準備啟動步驟 12：展示記錄');
          // 延遲啟動，確保首頁已經完全渲染
          Future.delayed(const Duration(milliseconds: 1200), () {
            // 使用全局 navigatorKey 獲取 context，因為當前頁面已被 pop
            final globalContext = FoodaApp.navigatorKey.currentContext;
            
            if (globalContext != null && globalContext.mounted) {
              tutorialController.log('📝 延遲結束，啟動步驟 12 (Show Record)');
              tutorialController.startFinalTutorial(globalContext);
            } else {
              tutorialController.log('⚠️ 延遲結束，Context 無效 (Global)，無法啟動步驟 12');
            }
          });
        } else {
          // 非教學模式，顯示正常提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${AppLocalizations.of(context)!.mealSavedSuccessfully ?? 'Meal saved successfully'}'),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${AppLocalizations.of(context)!.saveFailed ?? 'Save failed'}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${AppLocalizations.of(context)!.saveFailed ?? 'Error'}: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // 獲取螢幕尺寸
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final padding = isSmallScreen ? 12.0 : 16.0;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          '📸 ${AppLocalizations.of(context)!.photoAndRecognition ?? 'AI Camera'}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 照片預覽
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        widget.imageFile,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: padding + 4),
                    
                    // 成功標題
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Color(0xFF10B981),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.aiRecognitionSuccess ?? 'Recognition Success!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: padding),
                    
                    // 識別到的食物列表
                    ...List.generate(widget.items.length, (index) {
                      final item = widget.items[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: padding - 4),
                        child: _buildFoodItemCard(item, index + 1, isSmallScreen),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            // 底部按鈕
            Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.retry ?? 'Retry',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: _isSaving ? Colors.grey : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : () => _saveMealRecord(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          disabledBackgroundColor: const Color(0xFF3B82F6).withOpacity(0.6),
                          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.save ?? 'Save',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 食物項目卡片
  Widget _buildFoodItemCard(Map<String, dynamic> item, int index, bool isSmallScreen) {
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final smallFontSize = isSmallScreen ? 11.0 : 13.0;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 食物名稱
          Row(
            children: [
              Container(
                width: isSmallScreen ? 24 : 28,
                height: isSmallScreen ? 24 : 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? AppLocalizations.of(context)!.unknownError, // Fallback to generic error or keep english default if implied
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    if (item['englishName'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item['englishName'],
                        style: TextStyle(
                          fontSize: smallFontSize,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          // 營養資訊
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildNutritionItem(
                label: AppLocalizations.of(context)!.quantity ?? 'Quantity',
                value: item['portion'] ?? '-',
                icon: '📏',
                isSmall: isSmallScreen,
              ),
              _buildNutritionItem(
                label: AppLocalizations.of(context)!.calories ?? 'Calories',
                value: '${item['calories'] ?? 0} kcal',
                icon: '🔥',
                isSmall: isSmallScreen,
              ),
              _buildNutritionItem(
                label: AppLocalizations.of(context)!.protein ?? 'Protein',
                value: '${item['protein'] ?? 0}g',
                icon: '🥩',
                isSmall: isSmallScreen,
              ),
              _buildNutritionItem(
                label: AppLocalizations.of(context)!.carbs ?? 'Carbs',
                value: '${item['carbs'] ?? 0}g',
                icon: '🍚',
                isSmall: isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 營養項目
  Widget _buildNutritionItem({
    required String label,
    required String value,
    required String icon,
    required bool isSmall,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: isSmall ? 14 : 16)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isSmall ? 10 : 11,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmall ? 11 : 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

