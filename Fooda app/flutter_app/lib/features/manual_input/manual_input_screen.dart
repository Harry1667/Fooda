import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/services/ai_analysis_service.dart';
import '../../features/meals/providers/meal_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/text_colors.dart';
import '../../features/membership/providers/membership_provider.dart';
import '../../features/membership/membership_screen.dart';
/// 手動輸入餐點頁面
/// 完全對應 PHP 版本的 manual-overlay
class ManualInputScreen extends StatefulWidget {
  final Map<String, dynamic>? editingMeal;
  final DateTime? selectedDate;
  final File? initialImageFile;
  
  const ManualInputScreen({
    super.key, 
    this.editingMeal, 
    this.selectedDate,
    this.initialImageFile,
  });

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // 表單欄位控制器
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  
  // 營養素控制器
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _sodiumController;
  late TextEditingController _fiberController;
  
  // 選擇項
  String _selectedMealType = 'breakfast';
  final List<String> _selectedTags = [];
  File? _photoFile;
  String? _photoUrl;
  bool _aiRecognitionSuccess = false;
  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _recognizedItems = [];

  @override
  void initState() {
    super.initState();
    
    // 初始化日期和時間為當前
    final now = DateTime.now();
    _dateController = TextEditingController(
      text: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'
    );
    _timeController = TextEditingController(
      text: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'
    );
    _nameController = TextEditingController();
    _notesController = TextEditingController();
    
    _caloriesController = TextEditingController();
    _proteinController = TextEditingController();
    _carbsController = TextEditingController();
    _fatController = TextEditingController();
    _sodiumController = TextEditingController();
    _fiberController = TextEditingController();
    
    // 如果有傳入初始圖片
    if (widget.initialImageFile != null) {
      _photoFile = widget.initialImageFile;
    }
    
    // 如果是編輯模式，載入現有數據
    if (widget.editingMeal != null) {
      // TODO: 載入編輯數據
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _sodiumController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.manualInputMeal ?? '手動輸入餐點',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            // 表單內容（可滾動）
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 日期
                      _buildFormRow(
                        label: AppLocalizations.of(context)!.date ?? '日期',
                        child: _buildDateField(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 時間
                      _buildFormRow(
                        label: AppLocalizations.of(context)!.time ?? '時間',
                        child: _buildTimeField(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 餐點名稱
                      _buildFormRow(
                        label: AppLocalizations.of(context)!.mealName ?? '餐點名稱',
                        child: _buildNameField(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 餐點類型
                      _buildFormRow(
                        label: AppLocalizations.of(context)!.mealType ?? '餐點類型',
                        child: _buildMealTypeDropdown(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 🤖 AI 智能識別 / 照片上傳
                      _buildFormRow(
                        label: AppLocalizations.of(context)!.photoAndRecognition ?? 'Photo & Recognition',
                        child: _buildAiAssistArea(),
                      ),
                      
                      const SizedBox(height: 16),

                      // 營養素輸入
                      _buildNutritionFields(),

                      const SizedBox(height: 16),
                      
                      // 餐點標籤
                      _buildFormRow(
                        label: AppLocalizations.of(context)!.mealTags ?? '餐點標籤',
                        child: _buildMealTags(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 備註
                      _buildFormRow(
                        label: AppLocalizations.of(context)!.notes ?? '備註',
                        child: _buildNotesField(),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            
            // 底部操作按鈕（對應 manual-actions）
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// 表單行容器（對應 form-row）
  Widget _buildFormRow({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  /// 日期輸入框
  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        suffixIcon: const Icon(Icons.calendar_today, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) {
          setState(() {
            _dateController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          });
        }
      },
    );
  }

  /// 時間輸入框
  Widget _buildTimeField() {
    return TextFormField(
      controller: _timeController,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        suffixIcon: const Icon(Icons.access_time, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          setState(() {
            _timeController.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          });
        }
      },
    );
  }

  /// 餐點名稱輸入框
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.mealNameHint ?? '如：雞胸肉沙拉',
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.enterMealName ?? 'Please enter meal name';
        }
        return null;
      },
    );
  }

  /// 餐點類型下拉選單
  Widget _buildMealTypeDropdown() {
    final l10n = AppLocalizations.of(context)!;
    final mealTypes = [
      {'value': 'breakfast', 'label': l10n.breakfast},
      {'value': 'morning-snack', 'label': l10n.morningSnack ?? '上午點心'},
      {'value': 'lunch', 'label': l10n.lunch},
      {'value': 'afternoon-tea', 'label': l10n.afternoonTea ?? '下午茶'},
      {'value': 'dinner', 'label': l10n.dinner},
      {'value': 'late-night', 'label': l10n.lateNight ?? '宵夜'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedMealType,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: mealTypes.map((type) {
          return DropdownMenuItem<String>(
            value: type['value'],
            child: Text(type['label']!),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedMealType = value;
            });
          }
        },
      ),
    );
  }

  /// AI 智能識別區域
  Widget _buildAiAssistArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Theme.of(context).colorScheme.surface 
            : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Theme.of(context).dividerColor 
              : const Color(0xFFBAE6FD)
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 操作按鈕
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Text('📁', style: TextStyle(fontSize: 18)),
                  label: Text(AppLocalizations.of(context)!.uploadPhoto ?? '上傳照片'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                    elevation: 0,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.camera),
                  icon: const Text('📷', style: TextStyle(fontSize: 18)),
                  label: Text(AppLocalizations.of(context)!.takePhoto ?? '拍照'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                    elevation: 0,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          // AI 分析按鈕 (只有在有照片且未分析時顯示)
          if ((_photoFile != null || _photoUrl != null) && !_isAnalyzing && !_aiRecognitionSuccess) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _analyzeCurrentPhoto,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('✨ AI 智能分析 (消耗 1 次額度)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
          
          // AI 分析中狀態
          if (_isAnalyzing) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.aiAnalyzing ?? 'AI is analyzing food...',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF1E40AF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // AI 識別成功狀態
          if (_aiRecognitionSuccess && !_isAnalyzing) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('✅', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${AppLocalizations.of(context)!.aiAnalysisComplete ?? 'AI analysis complete'} (${_recognizedItems.length} ${AppLocalizations.of(context)!.foodItems ?? 'food items'})',
                      style: const TextStyle(
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // 照片預覽
          if (_photoFile != null || _photoUrl != null) ...[
            const SizedBox(height: 12),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _photoFile != null
                      ? Image.file(_photoFile!, height: 200, width: double.infinity, fit: BoxFit.cover)
                      : Image.network(_photoUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _photoFile = null;
                        _photoUrl = null;
                        _recognizedItems = [];
                        _aiRecognitionSuccess = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          // 顯示識別到的食物列表 (僅 AI 模式)
          if (_recognizedItems.isNotEmpty && !_isAnalyzing) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.recognitionResults ?? 'Recognition Results'}：',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._recognizedItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Text('🍽️ ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              '${item['name']} (${item['portion']} - ${item['calories']} kcal)',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 餐點標籤選擇器
  Widget _buildMealTags() {
    final tags = [
      {'id': 'home-cooked', 'label': '🏠 ${AppLocalizations.of(context)!.homeCooked ?? 'Home Cooked'}'},
      {'id': 'dining-out', 'label': '🍽️ ${AppLocalizations.of(context)!.diningOut ?? 'Dining Out'}'},
      {'id': 'takeout', 'label': '🥡 ${AppLocalizations.of(context)!.takeout ?? 'Takeout'}'},
      {'id': 'dessert', 'label': '🍰 ${AppLocalizations.of(context)!.dessert ?? 'Dessert'}'},
      {'id': 'beverage', 'label': '🥤 ${AppLocalizations.of(context)!.beverage ?? 'Beverage'}'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        final isSelected = _selectedTags.contains(tag['id']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedTags.remove(tag['id']);
              } else {
                _selectedTags.add(tag['id']!);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
              ),
            ),
            child: Text(
              tag['label']!,
              style: TextStyle(
                color: isSelected ? Colors.white : context.secondaryText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 備註輸入框
  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.notesHint ?? 'You can fill in taste, source, etc.',
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  /// 營養素輸入區塊
  Widget _buildNutritionFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.nutrientsOptional ?? 'Nutrients (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.secondaryText,
            ),
          ),
          const SizedBox(height: 12),
          
          // 熱量
          _buildNutritionInput(
            controller: _caloriesController,
            label: AppLocalizations.of(context)!.calories ?? 'Calories',
            suffix: 'kcal',
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          
          // 碳水
          _buildNutritionInput(
            controller: _carbsController,
            label: AppLocalizations.of(context)!.carbs ?? 'Carbohydrates',
            suffix: 'g',
            icon: Icons.rice_bowl,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          
          // 蛋白質
          _buildNutritionInput(
            controller: _proteinController,
            label: AppLocalizations.of(context)!.protein ?? 'Protein',
            suffix: 'g',
            icon: Icons.fitness_center,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          
          // 脂肪
          _buildNutritionInput(
            controller: _fatController,
            label: AppLocalizations.of(context)!.fat ?? 'Fat',
            suffix: 'g',
            icon: Icons.opacity,
            color: Colors.yellow[700]!,
          ),
          const SizedBox(height: 12),
          
          // 鈉
          _buildNutritionInput(
            controller: _sodiumController,
            label: AppLocalizations.of(context)!.sodium ?? 'Sodium',
            suffix: 'mg',
            icon: Icons.grain,
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
          
          // 膳食纖維
          _buildNutritionInput(
            controller: _fiberController,
            label: AppLocalizations.of(context)!.fiber ?? 'Dietary Fiber',
            suffix: 'g',
            icon: Icons.grass,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  /// 單個營養素輸入框
  Widget _buildNutritionInput({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, size: 18, color: color),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
    );
  }

  /// 底部操作按鈕（對應 manual-actions）
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.cancel ?? 'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.secondaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveManual,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.save ?? 'Save',
                  style: const TextStyle(
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

  void _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _photoFile = File(image.path);
        _photoUrl = null;
        _recognizedItems = [];
        _aiRecognitionSuccess = false;
        _isAnalyzing = false;
      });
    }
  }

  void _analyzeCurrentPhoto() async {
    if (_photoFile == null) return;

    // 檢查配額
    final membership = Provider.of<MembershipProvider>(context, listen: false);
    if (!membership.canUseAi) {
      _showUpgradeDialog();
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });
    
    _analyzeImage();
  }

  void _analyzeImage() async {
    if (_photoFile == null) return;

    // 再次檢查配額 (防止繞過)
    // 注意：這裡保留檢查是為了安全性，但因為 _analyzeCurrentPhoto 已經檢查過了，
    // 這裡主要是防止直接調用 _analyzeImage (雖然現在它是私有的且只被 _analyzeCurrentPhoto 調用)
    final membership = Provider.of<MembershipProvider>(context, listen: false);
    if (!membership.canUseAi) {
      _showUpgradeDialog();
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final localeProvider = context.read<LocaleProvider>();
      final currentLanguage = _getLanguageCodeForAI(localeProvider.currentLanguageCode);
      
      final result = await AiAnalysisService.analyzeImageDirect(
        imageFile: _photoFile!,
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
          _recognizedItems = List<Map<String, dynamic>>.from(result['items']);
          _aiRecognitionSuccess = true;
        });
        
        // 自動填入第一個識別結果
        if (_recognizedItems.isNotEmpty) {
          final firstItem = _recognizedItems[0];
          _nameController.text = firstItem['name'] ?? '';
          _caloriesController.text = (firstItem['calories'] ?? 0).toString();
          _proteinController.text = (firstItem['protein'] ?? 0).toString();
          _carbsController.text = (firstItem['carbs'] ?? 0).toString();
          _fatController.text = (firstItem['fat'] ?? 0).toString();
          _sodiumController.text = (firstItem['sodium'] ?? 0).toString();
          _fiberController.text = (firstItem['fiber'] ?? 0).toString();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? '識別失敗')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('發生錯誤: $e')),
      );
    }
  }

  String _getLanguageCodeForAI(String localeCode) {
    if (localeCode.startsWith('zh')) {
      return localeCode.contains('TW') || localeCode.contains('Hant') 
          ? 'Traditional Chinese' 
          : 'Simplified Chinese';
    } else if (localeCode.startsWith('ja')) {
      return 'Japanese';
    } else if (localeCode.startsWith('ko')) {
      return 'Korean';
    } else {
      return 'English';
    }
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

  /// 保存手動輸入
  void _saveManual() async {
    if (_formKey.currentState!.validate()) {
      // 顯示保存中狀態
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final payload = {
        'date': _dateController.text,
        'time': _timeController.text,
        'name': _nameController.text,
        'mealType': _selectedMealType,
        'photo': _photoFile?.path ?? _photoUrl,
        'tags': _selectedTags,
        'notes': _notesController.text,
        'recognizedItems': _recognizedItems, // 包含AI識別結果
        
        // 營養素數據
        'calories': double.tryParse(_caloriesController.text),
        'protein': double.tryParse(_proteinController.text),
        'carbs': double.tryParse(_carbsController.text),
        'fat': double.tryParse(_fatController.text),
        'sodium': double.tryParse(_sodiumController.text),
        'fiber': double.tryParse(_fiberController.text),
      };
      
      try {
        // 使用統一的數據管理系統保存
        // 改用 MealProvider
        final mealProvider = Provider.of<MealProvider>(context, listen: false);
        final success = await mealProvider.addMealFromManualInput(payload);
        
        // 關閉loading對話框
        if (mounted) Navigator.pop(context);
        
        if (success) {
          // 保存成功
          if (mounted) {
            Navigator.pop(context, true); // 返回true表示保存成功
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${AppLocalizations.of(context)!.mealSavedSuccessfully ?? 'Meal saved successfully'}'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        } else {
          // 保存失敗
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${AppLocalizations.of(context)!.saveFailed ?? 'Save failed'}'),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
        }
      } catch (e) {
        // 關閉loading對話框
        if (mounted) Navigator.pop(context);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${AppLocalizations.of(context)!.saveFailed ?? 'Save failed'}: $e'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }
  }
}