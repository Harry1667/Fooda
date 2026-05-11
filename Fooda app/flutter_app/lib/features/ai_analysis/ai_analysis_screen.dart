import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/ai_service_clean.dart';
import '../../core/theme/app_theme.dart';
import '../membership/providers/membership_provider.dart';
import '../../core/models/meal_model.dart' as meal_models;
import '../meals/providers/meal_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../membership/membership_screen.dart';

// 類型別名，讓代碼更清晰
typedef FoodItem = AiFoodItem;
typedef NutritionData = AiNutritionData;

/// AI 分析結果頁面
/// 顯示食物識別結果和營養數據，支援編輯和選擇保存
class AiAnalysisScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const AiAnalysisScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  bool _isAnalyzing = true;
  String? _error;
  List<FoodItem> _foodItems = [];
  final Map<int, bool> _selectedItems = {};
  final Map<int, TextEditingController> _nameControllers = {};
  final Map<int, double> _weightValues = {};

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  @override
  void dispose() {
    // 釋放文字控制器
    for (final controller in _nameControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 分析圖片
  Future<void> _analyzeImage() async {
    try {
      print('🧠 開始分析圖片...');
      setState(() {
        _isAnalyzing = true;
        _error = null;
      });

      // 初始化並檢查會員權限和額度
      final membershipProvider = context.read<MembershipProvider>();
      
      // 確保 MembershipProvider 已初始化
      print('🔄 檢查會員狀態...');
      // MembershipProvider 已經在應用啟動時初始化
      
      print('👤 檢查會員權限...');
      if (!_checkAiPermission(membershipProvider)) {
        print('❌ 會員權限檢查失敗');
        return;
      }

      print('✅ 會員權限檢查通過');
      
      // 消耗 AI 額度
      print('⚡ 消耗 AI 額度...');
      membershipProvider.consumeAiQuota();

      // 調用 Gemini AI 分析
      print('🤖 調用 Gemini AI 分析...');
      
      // 從 LocaleProvider 獲取當前語言
      final localeProvider = context.read<LocaleProvider>();
      final currentLanguage = _getLanguageCodeForAI(localeProvider.currentLanguageCode);
      print('🌐 使用語言: $currentLanguage');
      
      final analysisResult = await AiService.analyzeFood(
        imageBytes: widget.imageBytes,
        language: currentLanguage,
      );
      print('✅ Gemini AI 分析完成，識別到 ${analysisResult.foods.length} 個食物');

      // 為每個食物項目查詢營養數據
      print('🥗 開始查詢營養數據...');
      for (int i = 0; i < analysisResult.foods.length; i++) {
        final food = analysisResult.foods[i];
        print('🔍 查詢食物 ${i + 1}/${analysisResult.foods.length}: ${food.nameEn}');
        
        try {
          final nutritionData = await AiService.getNutritionData(
            foodName: food.nameEn,
            weightInGrams: food.weightGrams,
          );
          
          analysisResult.foods[i] = food.copyWith(nutritionData: nutritionData);
          print('✅ 營養數據查詢成功: ${food.nameEn}');
        } catch (e) {
          print('⚠️ 獲取營養數據失敗: ${food.nameEn} - $e');
          // 如果營養數據獲取失敗，使用預設值
          analysisResult.foods[i] = food.copyWith(
            nutritionData: NutritionData(
              calories: 0,
              carbs: 0,
              protein: 0,
              fat: 0,
              sodium: 0,
              fiber: 0,
            ),
          );
        }
      }
      print('🎉 所有營養數據查詢完成');

      // 初始化狀態
      print('🔄 更新 UI 狀態...');
      setState(() {
        _foodItems = analysisResult.foods;
        _isAnalyzing = false;
        
        // 初始化選擇狀態和控制器
        for (int i = 0; i < _foodItems.length; i++) {
          _selectedItems[i] = true; // 預設全部選中
          _nameControllers[i] = TextEditingController(text: _foodItems[i].name);
          _weightValues[i] = _foodItems[i].weightGrams;
        }
      });
      print('✅ UI 狀態更新完成，共 ${_foodItems.length} 個食物項目');
    } catch (e) {
      print('💥 分析過程中發生錯誤: $e');
      setState(() {
        _error = e.toString();
        _isAnalyzing = false;
      });
    }
  }

  /// 檢查 AI 權限
  bool _checkAiPermission(MembershipProvider membershipProvider) {
    // 檢查會員狀態和AI使用權限
    print('👤 當前會員等級: ${membershipProvider.tier}');
    
    // 移除 membershipInfo 檢查，直接使用 membershipProvider

    // 檢查是否為免費會員
    if (membershipProvider.isFree) {
      // 免費會員也可以使用，只要有額度
      // 這裡不需要阻止，因為下面的額度檢查會處理
    }

    // 檢查 AI 額度
    if (membershipProvider.remainingAiQuota <= 0 && !membershipProvider.isPremium) {
      _showUpgradeDialog();
      setState(() {
        _isAnalyzing = false;
      });
      return false;
    }

    return true;
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.quotaExceeded ?? 'Monthly Free Quota Exceeded'),
        content: Text(AppLocalizations.of(context)!.quotaExceededDesc ?? 'Free version allows up to 10 AI recognitions per month. Quota resets on the 1st of each month. Upgrade to Premium for unlimited access.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MembershipScreen()),
              );
            },
            child: Text(AppLocalizations.of(context)!.upgradeToPremium ?? 'Upgrade to Premium'),
          ),
        ],
      ),
    );
  }

  /// 更新食物重量
  void _updateFoodWeight(int index, double newWeight) {
    if (index >= _foodItems.length) return;
    
    final food = _foodItems[index];
    if (food.nutritionData == null) return;

    // 重新計算營養數據
    final newNutritionData = food.nutritionData!.scaleByWeight(
      newWeight,
      food.weightGrams,
    );

    setState(() {
      _weightValues[index] = newWeight;
      _foodItems[index] = food.copyWith(
        weightGrams: newWeight,
        nutritionData: newNutritionData,
      );
    });
  }

  /// 更新食物名稱
  Future<void> _updateFoodName(int index, String newName) async {
    if (index >= _foodItems.length || newName.trim().isEmpty) return;

    final food = _foodItems[index];
    
    try {
      // 重新查詢營養數據
      final nutritionData = await AiService.getNutritionData(
        foodName: newName,
        weightInGrams: _weightValues[index] ?? food.weightGrams,
      );

      setState(() {
        _foodItems[index] = food.copyWith(
          name: newName,
          nameEn: newName, // 假設用戶輸入英文名稱
          nutritionData: nutritionData,
        );
      });
    } catch (e) {
      // 如果查詢失敗，只更新名稱
      setState(() {
        _foodItems[index] = food.copyWith(name: newName);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('無法找到 "$newName" 的營養數據')),
      );
    }
  }

  /// 保存選中的食物
  Future<void> _saveSelectedFoods() async {
    final selectedFoods = <FoodItem>[];
    
    for (int i = 0; i < _foodItems.length; i++) {
      if (_selectedItems[i] == true) {
        selectedFoods.add(_foodItems[i]);
      }
    }

    if (selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請至少選擇一個食物項目')),
      );
      return;
    }

    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    
    // 將 AI 識別結果轉換為 meal_models.FoodItem 列表
    final List<meal_models.FoodItem> foods = selectedFoods.map((food) {
      return meal_models.FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: food.name,
        nameEn: food.nameEn,
        grams: food.weightGrams,
        nutrition: meal_models.NutritionData(
          calories: food.nutritionData?.calories ?? 0,
          carbs: food.nutritionData?.carbs ?? 0,
          protein: food.nutritionData?.protein ?? 0,
          fat: food.nutritionData?.fat ?? 0,
          sodium: food.nutritionData?.sodium ?? 0,
          fiber: food.nutritionData?.fiber ?? 0,
        ),
        isAiRecognized: true,
      );
    }).toList();
    
    // 計算營養總和
    final totalNutrition = foods.fold<meal_models.NutritionData>(
      meal_models.NutritionData.empty(),
      (total, food) => total + food.nutrition,
    );
    
    // 創建 NutritionSummary
    final goals = meal_models.NutritionData(
      calories: 2000,
      carbs: 250,
      protein: 75,
      fat: 67,
      sodium: 2300,
      fiber: 25,
    );
    
    final nutritionSummary = meal_models.NutritionSummary.calculate(totalNutrition, goals);
    
    // 生成餐點名稱
    String mealName;
    if (foods.length == 1) {
      mealName = foods[0].name;
    } else if (foods.length <= 3) {
      mealName = foods.map((f) => f.name).join('、');
    } else {
      mealName = '${foods[0].name}等${foods.length}項';
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
    final meal = meal_models.MealRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: mealName,
      type: mealType,
      dateTime: now,
      foods: foods,
      nutrition: nutritionSummary,
      notes: 'AI 智能識別',
    );
    
    // 保存到 Provider
    final success = await mealProvider.addMeal(meal);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 已保存 ${selectedFoods.length} 個食物項目'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // 返回主頁
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ 保存失敗，請重試'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 構建 AI 分析頁面 UI...');
    print('📊 當前狀態: 分析中=$_isAnalyzing, 錯誤=$_error, 食物數量=${_foodItems.length}');
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('AI 分析結果'),
        actions: [
          if (!_isAnalyzing && _error == null && _foodItems.isNotEmpty)
            TextButton(
              onPressed: _saveSelectedFoods,
              child: const Text('保存'),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    print('🏗️ 構建頁面主體...');
    
    if (_isAnalyzing) {
      print('⏳ 顯示載入狀態');
      return _buildLoadingState();
    }

    if (_error != null) {
      print('❌ 顯示錯誤狀態: $_error');
      return _buildErrorState();
    }

    if (_foodItems.isEmpty) {
      print('📭 顯示空狀態');
      return _buildEmptyState();
    }

    print('📋 顯示結果列表，共 ${_foodItems.length} 個項目');
    return _buildResultsList();
  }

  /// 構建載入狀態
  Widget _buildLoadingState() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('AI 正在分析圖片...', style: TextStyle(color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text(
                '這可能需要幾秒鐘時間',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 構建錯誤狀態
  Widget _buildErrorState() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('返回'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 構建空狀態
  Widget _buildEmptyState() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '未識別到任何食物',
                  style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  '請確保圖片中有清晰可見的食物',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('重新拍攝'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 構建結果列表
  Widget _buildResultsList() {
    return Column(
      children: [
        // 圖片預覽
        Container(
          height: 200,
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              widget.imageBytes,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 結果標題
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '識別結果 (${_foodItems.length} 項)',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              Text(
                '選擇要保存的項目',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 食物項目列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _foodItems.length,
            itemBuilder: (context, index) {
              return _buildFoodItem(index);
            },
          ),
        ),
      ],
    );
  }

  /// 構建食物項目
  Widget _buildFoodItem(int index) {
    final food = _foodItems[index];
    final isSelected = _selectedItems[index] ?? true;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題行：選擇框 + 食物名稱 + 置信度
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      _selectedItems[index] = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _nameControllers[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '食物名稱',
                    ),
                    onSubmitted: (value) => _updateFoodName(index, value),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(food.confidence),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(food.confidence * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 重量調整滑桿
            Row(
              children: [
                const Text('重量：'),
                Text(
                  '${(_weightValues[index] ?? food.weightGrams).toInt()}g',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _weightValues[index] ?? food.weightGrams,
                    min: 10,
                    max: 1000,
                    divisions: 99,
                    onChanged: (value) => _updateFoodWeight(index, value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 營養數據網格
            if (food.nutritionData != null)
              _buildNutritionGrid(food.nutritionData!),
          ],
        ),
      ),
    );
  }

  /// 構建營養數據網格
  Widget _buildNutritionGrid(NutritionData nutrition) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  color: AppTheme.caloriesColor,
                  label: '熱量',
                  value: '${nutrition.calories.toInt()} kcal',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutritionItem(
                  color: AppTheme.carbsColor,
                  label: '碳水',
                  value: '${nutrition.carbs.toInt()}g',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutritionItem(
                  color: AppTheme.proteinColor,
                  label: '蛋白質',
                  value: '${nutrition.protein.toInt()}g',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  color: AppTheme.fatColor,
                  label: '脂肪',
                  value: '${nutrition.fat.toInt()}g',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutritionItem(
                  color: AppTheme.sodiumColor,
                  label: '鈉',
                  value: '${(nutrition.sodium * 1000).toInt()}mg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutritionItem(
                  color: AppTheme.fiberColor,
                  label: '膳食纖維',
                  value: '${nutrition.fiber.toInt()}g',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 構建營養素項目
  Widget _buildNutritionItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 獲取置信度顏色
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
  
  /// 將應用語言代碼轉換為 AI 服務使用的語言代碼
  String _getLanguageCodeForAI(String appLanguageCode) {
    switch (appLanguageCode) {
      case 'zh_TW':
        return 'zh-TW';
      case 'zh_CN':
        return 'zh-CN';
      case 'en':
        return 'en-US';
      default:
        return 'zh-TW';
    }
  }
}