import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/services/ai_analysis_service.dart';
import '../../core/models/meal_model.dart';
import '../../features/meals/providers/meal_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../features/membership/providers/membership_provider.dart';
import '../../features/membership/membership_screen.dart';
/// AI 智能上傳頁面
/// 對應 PHP 版本的 AI 智能上傳功能
class AiUploadScreen extends StatefulWidget {
  const AiUploadScreen({super.key});

  @override
  State<AiUploadScreen> createState() => _AiUploadScreenState();
}

class _AiUploadScreenState extends State<AiUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isAnalyzing = false;
  bool _analysisComplete = false;
  List<Map<String, dynamic>> _recognizedItems = [];
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    // 獲取螢幕尺寸並計算響應式參數
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final padding = isSmallScreen ? 12.0 : 16.0;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 主要內容區域
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 說明區域
                    _buildInstructionCard(isSmallScreen, padding),
                    
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    
                    // 上傳按鈕或圖片預覽
                    if (_selectedImage == null) ...[
                      _buildUploadButton(isSmallScreen),
                    ] else ...[
                      _buildImagePreview(isSmallScreen),
                    ],
                    
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    
                    // 分析狀態
                    if (_isAnalyzing) _buildAnalyzingStatus(isSmallScreen),
                    if (_analysisComplete && !_isAnalyzing && _recognizedItems.isNotEmpty)
                      _buildRecognitionResults(isSmallScreen),
                    if (_errorMessage != null) _buildErrorMessage(isSmallScreen),
                    
                    SizedBox(height: isSmallScreen ? 16 : 24),
                  ],
                ),
              ),
            ),
            
            // 底部操作按鈕
            if (_selectedImage != null && !_isAnalyzing)
              _buildActionButtons(isSmallScreen),
          ],
        ),
      ),
    );
  }

  /// 說明卡片
  Widget _buildInstructionCard(bool isSmallScreen, double padding) {
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final smallFontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : const Color(0xFFBAE6FD)
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI 智能識別說明',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Theme.of(context).colorScheme.primary : const Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            '• 上傳清晰的食物照片\n'
            '• AI 將自動識別食物種類和份量\n'
            '• 提供詳細的營養成分資訊\n'
            '• 支援多種食物同時識別',
            style: TextStyle(
              fontSize: smallFontSize,
              color: isDark ? Theme.of(context).colorScheme.onSurface.withOpacity(0.9) : const Color(0xFF1E40AF),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// 上傳按鈕
  Widget _buildUploadButton(bool isSmallScreen) {
    final height = isSmallScreen ? 220.0 : 300.0;
    final iconSize = isSmallScreen ? 50.0 : 60.0;
    final fontSize = isSmallScreen ? 16.0 : 18.0;
    final smallFontSize = isSmallScreen ? 12.0 : 14.0;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: isDark ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : const Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload,
                size: iconSize,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              '點擊上傳食物照片',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '支援 JPG、PNG、WebP 格式',
              style: TextStyle(
                fontSize: smallFontSize,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 圖片預覽
  Widget _buildImagePreview(bool isSmallScreen) {
    final height = isSmallScreen ? 200.0 : 300.0;
    final fontSize = isSmallScreen ? 11.0 : 13.0;
    
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImage!,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '已選擇：${_selectedImage!.path.split('/').last}',
                style: TextStyle(
                  fontSize: fontSize,
                  color: const Color(0xFF6B7280),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.refresh, size: isSmallScreen ? 16 : 18),
              label: Text(
                '重新選擇',
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 分析中狀態
  Widget _buildAnalyzingStatus(bool isSmallScreen) {
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final smallFontSize = isSmallScreen ? 11.0 : 13.0;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: isSmallScreen ? 20 : 24,
            height: isSmallScreen ? 20 : 24,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6)),
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 正在識別中...',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Theme.of(context).colorScheme.primary : const Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '請稍候，這可能需要幾秒鐘',
                  style: TextStyle(
                    fontSize: smallFontSize,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 識別結果
  Widget _buildRecognitionResults(bool isSmallScreen) {
    final fontSize = isSmallScreen ? 16.0 : 18.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 成功標題
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: const Color(0xFF10B981),
                  size: iconSize,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '識別成功！',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          const Divider(),
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // 識別到的食物列表
          ...List.generate(_recognizedItems.length, (index) {
            final item = _recognizedItems[index];
            return _buildFoodItemCard(item, index + 1, isSmallScreen);
          }),
        ],
      ),
    );
  }

  /// 食物項目卡片
  Widget _buildFoodItemCard(Map<String, dynamic> item, int index, bool isSmallScreen) {
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final smallFontSize = isSmallScreen ? 11.0 : 13.0;
    final circleSize = isSmallScreen ? 24.0 : 28.0;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 食物名稱
          Row(
            children: [
              Container(
                width: circleSize,
                height: circleSize,
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
                      item['name'] ?? '未知食物',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          const Divider(height: 1),
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          // 營養資訊
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildNutritionItem(
                label: '份量',
                value: item['portion'] ?? '-',
                icon: '📏',
                isSmall: isSmallScreen,
              ),
              _buildNutritionItem(
                label: '熱量',
                value: '${item['calories'] ?? 0} kcal',
                icon: '🔥',
                isSmall: isSmallScreen,
              ),
              _buildNutritionItem(
                label: '蛋白質',
                value: '${item['protein'] ?? 0}g',
                icon: '🥩',
                isSmall: isSmallScreen,
              ),
              _buildNutritionItem(
                label: '碳水',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: isDark ? Border.all(color: Theme.of(context).dividerColor) : null,
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
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 錯誤訊息
  Widget _buildErrorMessage(bool isSmallScreen) {
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    final smallFontSize = isSmallScreen ? 11.0 : 13.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: const Color(0xFFDC2626),
                size: iconSize,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '識別失敗',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 顯示完整的錯誤信息，支持多行和換行
          SelectableText(
            _errorMessage!,
            style: TextStyle(
              fontSize: smallFontSize,
              color: const Color(0xFFDC2626),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          // 重試按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _reset,
              icon: Icon(Icons.refresh, size: isSmallScreen ? 16 : 18),
              label: const Text('重新選擇圖片'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 底部操作按鈕
  Widget _buildActionButtons(bool isSmallScreen) {
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '重新上傳',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _analysisComplete ? _saveAndContinue : _analyzeImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _analysisComplete ? '保存並繼續' : '開始識別',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 選擇圖片
  void _pickImage() async {
    // 檢查 AI 配額
    final membership = Provider.of<MembershipProvider>(context, listen: false);
    if (!membership.canUseAi) {
      _showUpgradeDialog();
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _analysisComplete = false;
        _recognizedItems = [];
        _errorMessage = null;
      });
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('已用完本月免費額度'),
        content: const Text('免費版每月最多可使用 10 次 AI 識別。請下個月再試或升級 Premium 以解鎖無限次數。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MembershipScreen()),
              );
            },
            child: const Text('升級 Premium'),
          ),
        ],
      ),
    );
  }

  void _analyzeImage() async {
    if (_selectedImage == null) return;

    // 再次檢查配額 (防止繞過)
    final membership = Provider.of<MembershipProvider>(context, listen: false);
    if (!membership.canUseAi) {
      _showUpgradeDialog();
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      // 獲取當前語言設置
      final localeProvider = context.read<LocaleProvider>();
      final currentLanguage = _getLanguageCodeForAI(localeProvider.currentLanguageCode);
      print('🌐 使用語言: $currentLanguage');
      
      // 🔥 直接使用 Gemini API，不需要 PHP 服務器
      final result = await AiAnalysisService.analyzeImageDirect(
        imageFile: _selectedImage!,
        language: currentLanguage,
      );

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });

      if (result['success'] == true && result['items'] != null) {
        // 扣除配額
        final membership = Provider.of<MembershipProvider>(context, listen: false);
        await membership.consumeAiQuota();
        
        setState(() {
          _analysisComplete = true;
          _recognizedItems = List<Map<String, dynamic>>.from(result['items']);
        });
      } else {
        // 獲取詳細錯誤信息
        String errorMsg = result['error'] ?? '識別失敗，請重試';
        
        // 打印完整錯誤信息以便調試
        print('❌ AI 識別失敗');
        print('錯誤信息: $errorMsg');
        print('完整回應: $result');
        
        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } catch (e, stackTrace) {
      if (!mounted) return;

      print('❌ AI 分析異常');
      print('錯誤: $e');
      print('堆疊: $stackTrace');
      
      setState(() {
        _isAnalyzing = false;
        _errorMessage = '發生錯誤：$e';
      });
    }
  }

  /// 重置
  void _reset() {
    setState(() {
      _selectedImage = null;
      _analysisComplete = false;
      _recognizedItems = [];
      _errorMessage = null;
    });
  }

  /// 保存並繼續
  Future<void> _saveAndContinue() async {
    if (_recognizedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ 沒有識別到食物'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    
    // 將 AI 識別結果轉換為 FoodItem 列表
    final List<FoodItem> foods = _recognizedItems.map((item) {
      // 解析份量（假設格式為 "150g"）
      final portionStr = item['portion'] ?? '100g';
      final grams = double.tryParse(portionStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 100.0;
      
      return FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: item['name'] ?? '未知食物',
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
    final meal = MealRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: mealName,
      type: mealType,
      dateTime: now,
      foods: foods,
      nutrition: nutritionSummary,
      imageUrl: _selectedImage?.path,
      notes: 'AI 智能識別（上傳照片）',
    );
    
    // 保存到 Provider
    final success = await mealProvider.addMeal(meal);
    
    if (!context.mounted) return;
    
    if (success) {
      // 返回首頁
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 已添加到今日記錄'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ 保存失敗，請重試'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
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
