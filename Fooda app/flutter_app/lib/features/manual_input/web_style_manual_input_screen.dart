import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/services/ai_analysis_service.dart';
import '../../core/models/meal_model.dart';
import '../meals/providers/meal_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';

/// 網頁風格的手動輸入頁面
/// 完全對應 firstpage.php 的 manual-overlay
class WebStyleManualInputScreen extends StatefulWidget {
  const WebStyleManualInputScreen({super.key});

  @override
  State<WebStyleManualInputScreen> createState() => _WebStyleManualInputScreenState();
}

class _WebStyleManualInputScreenState extends State<WebStyleManualInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // 表單控制器
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  
  // 選擇項
  String _selectedMealType = 'breakfast';
  final List<String> _selectedTags = [];
  File? _photoFile;
  bool _isAiRecognizing = false;
  String? _aiRecognitionResult;
  
  // 餐點類型 - 將在 build 中動態獲取本地化字串
  Map<String, String> _getMealTypes(BuildContext context) => {
    'breakfast': AppLocalizations.of(context)!.breakfast,
    'morning-snack': AppLocalizations.of(context)!.morningSnack ?? '上午點心',
    'lunch': AppLocalizations.of(context)!.lunch,
    'afternoon-tea': AppLocalizations.of(context)!.afternoonSnack ?? '下午茶',
    'dinner': AppLocalizations.of(context)!.dinner,
    'late-night': AppLocalizations.of(context)!.snack,
  };
  
  // 餐點標籤 - 將在 build 中動態獲取本地化字串
  List<Map<String, String>> _getMealTags(BuildContext context) => [
    {'value': 'home-cooked', 'label': '🏠 ${AppLocalizations.of(context)!.homeCooked ?? '家煮'}'},
    {'value': 'dining-out', 'label': '🍽️ ${AppLocalizations.of(context)!.diningOut ?? '外食'}'},
    {'value': 'takeout', 'label': '🥡 ${AppLocalizations.of(context)!.takeout ?? '外賣'}'},
    {'value': 'dessert', 'label': '🍰 ${AppLocalizations.of(context)!.dessert ?? '甜點'}'},
    {'value': 'beverage', 'label': '🥤 ${AppLocalizations.of(context)!.beverage ?? '飲料'}'},
  ];
  
  @override
  void initState() {
    super.initState();
    // 設置當前日期和時間
    final now = DateTime.now();
    _dateController.text = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _timeController.text = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
  
  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
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
          AppLocalizations.of(context)!.manualInput,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 表單內容（可滾動）
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 日期和時間
                      _buildDateTimeRow(),
                      SizedBox(height: padding),
                      
                      // 餐點名稱
                      _buildTextField(
                        controller: _nameController,
                        label: AppLocalizations.of(context)!.mealName ?? '餐點名稱',
                        hint: '如：雞胸肉沙拉',
                        validator: (value) => value?.isEmpty ?? true ? '請輸入餐點名稱' : null,
                      ),
                      SizedBox(height: padding),
                      
                      // 餐點類型
                      _buildMealTypeDropdown(),
                      SizedBox(height: padding),
                      
                      // AI 智能識別
                      _buildAiAssistSection(),
                      SizedBox(height: padding),
                      
                      // 餐點標籤
                      _buildMealTagsSection(),
                      SizedBox(height: padding),
                      
                      // 備註
                      _buildNotesField(),
                    ],
                  ),
                ),
              ),
            ),
            
            // 底部按鈕
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }
  
  /// 日期和時間行
  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _dateController,
            label: AppLocalizations.of(context)!.date ?? '日期',
            hint: 'YYYY-MM-DD',
            readOnly: true,
            onTap: () => _selectDate(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: _timeController,
            label: AppLocalizations.of(context)!.time ?? '時間',
            hint: 'HH:MM',
            readOnly: true,
            onTap: () => _selectTime(),
          ),
        ),
      ],
    );
  }
  
  /// 通用文本欄位
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }
  
  /// 餐點類型下拉選單
  Widget _buildMealTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '餐點類型',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedMealType,
              isExpanded: true,
              items: _getMealTypes(context).entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMealType = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  
  /// AI 智能識別區域
  Widget _buildAiAssistSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🤖 ',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'AI 智能識別',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // AI 按鈕
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isAiRecognizing ? null : () => _uploadPhotoForAi(),
                  icon: const Icon(Icons.photo_library, size: 16),
                  label: const Text(
                    '上傳識別',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isAiRecognizing ? null : () => _cameraPhotoForAi(),
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: const Text(
                    '拍照識別',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // AI 識別狀態
          if (_isAiRecognizing) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'AI 正在識別食物...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // AI 識別結果
          if (_aiRecognitionResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('✅', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI 成功識別：$_aiRecognitionResult',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '食物名稱已自動填入，您可以進行調整',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
          
          // 照片預覽
          if (_photoFile != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _photoFile!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// 餐點標籤區域
  Widget _buildMealTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '餐點標籤',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getMealTags(context).map((tag) {
            final isSelected = _selectedTags.contains(tag['value']);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag['value']);
                  } else {
                    _selectedTags.add(tag['value']!);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Text(
                  tag['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  /// 備註欄位
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '備註',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '可填寫口味、來源等',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
  
  /// 底部按鈕
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _saveMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '保存',
                  style: TextStyle(
                    fontSize: 16,
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
  
  /// 選擇日期
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }
  
  /// 選擇時間
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }
  
  /// 上傳照片進行 AI 識別
  Future<void> _uploadPhotoForAi() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _performAiRecognition(File(image.path));
    }
  }
  
  /// 拍照進行 AI 識別
  Future<void> _cameraPhotoForAi() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      await _performAiRecognition(File(photo.path));
    }
  }
  
  /// 執行 AI 識別
  Future<void> _performAiRecognition(File imageFile) async {
    setState(() {
      _isAiRecognizing = true;
      _photoFile = imageFile;
      _aiRecognitionResult = null;
    });
    
    try {
      // 獲取當前語言設置
      final localeProvider = context.read<LocaleProvider>();
      final currentLanguage = _getLanguageCodeForAI(localeProvider.currentLanguageCode);
      print('🌐 使用語言: $currentLanguage');
      
      final result = await AiAnalysisService.analyzeImageDirect(
        imageFile: imageFile,
        language: currentLanguage,
      );
      
      if (result['success'] == true && result['items'] != null && result['items'].isNotEmpty) {
        final firstItem = result['items'][0];
        final foodName = firstItem['name'] ?? '';
        
        setState(() {
          _nameController.text = foodName;
          _aiRecognitionResult = foodName;
          _isAiRecognizing = false;
        });
      } else {
        setState(() {
          _isAiRecognizing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? AppLocalizations.of(context)!.aiRecognitionFailed ?? 'AI 識別失敗，請手動輸入'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isAiRecognizing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 識別出現錯誤：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// 保存餐點
  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;
    
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    
    // 解析日期時間
    final dateStr = _dateController.text;
    final timeStr = _timeController.text;
    final dateTimeParts = dateStr.split('-');
    final timeParts = timeStr.split(':');
    
    final dateTime = DateTime(
      int.parse(dateTimeParts[0]),
      int.parse(dateTimeParts[1]),
      int.parse(dateTimeParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    
    // 創建一個簡單的 FoodItem（因為是手動輸入，營養數據可以暫時為0或估算）
    final foodItem = FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      nameEn: _nameController.text,
      grams: 100, // 預設100g
      nutrition: NutritionData(
        // 這裡可以根據食物名稱查詢 USDA 數據庫獲取營養資料
        // 目前使用估算值
        calories: 200,
        carbs: 30,
        protein: 10,
        fat: 5,
        sodium: 300,
        fiber: 2,
      ),
      isAiRecognized: _aiRecognitionResult != null,
    );
    
    // 創建營養總結
    final goals = NutritionData(
      calories: 2000,
      carbs: 250,
      protein: 75,
      fat: 67,
      sodium: 2300,
      fiber: 25,
    );
    
    final nutritionSummary = NutritionSummary.calculate(
      foodItem.nutrition,
      goals,
    );
    
    // 創建餐點記錄
    final meal = MealRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: _selectedMealType,
      dateTime: dateTime,
      foods: [foodItem],
      nutrition: nutritionSummary,
      imageUrl: _photoFile?.path,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );
    
    // 保存到 Provider
    final success = await mealProvider.addMeal(meal);
    
    if (!mounted) return;
    
    if (success) {
      // 返回首頁並顯示成功訊息
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 已添加「${_nameController.text}」到今日記錄'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
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

