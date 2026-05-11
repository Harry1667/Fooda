import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 簡潔版手動輸入頁面
/// 快速添加食物和營養資訊
class SimpleManualInputScreen extends StatefulWidget {
  const SimpleManualInputScreen({super.key});

  @override
  State<SimpleManualInputScreen> createState() => _SimpleManualInputScreenState();
}

class _SimpleManualInputScreenState extends State<SimpleManualInputScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 表單控制器
  final _foodNameController = TextEditingController();
  final _portionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  
  @override
  void dispose() {
    _foodNameController.dispose();
    _portionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text(
          '✏️ 手動輸入',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 表單內容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 說明卡片
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                '快速記錄您吃的食物和營養資訊',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 食物名稱
                      Text(
                        '食物名稱 *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _foodNameController,
                        decoration: InputDecoration(
                          hintText: '例如：雞胸肉、白飯、蘋果',
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
                            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '請輸入食物名稱';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 份量
                      const Text(
                        '份量',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _portionController,
                        decoration: InputDecoration(
                          hintText: '例如：150g、1 碗、1 份',
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
                            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 營養資訊標題
                      const Text(
                        '營養資訊（選填）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '填寫您知道的營養資訊，不清楚可以留空',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 營養資訊網格
                      Row(
                        children: [
                          Expanded(
                            child: _buildNutritionField(
                              label: '熱量',
                              controller: _caloriesController,
                              hint: 'kcal',
                              icon: '🔥',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildNutritionField(
                              label: '蛋白質',
                              controller: _proteinController,
                              hint: 'g',
                              icon: '🥩',
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildNutritionField(
                              label: '碳水',
                              controller: _carbsController,
                              hint: 'g',
                              icon: '🍚',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildNutritionField(
                              label: '脂肪',
                              controller: _fatController,
                              hint: 'g',
                              icon: '🥑',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 底部按鈕
            Container(
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
                    // 取消按鈕
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 保存按鈕
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _saveMeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '保存記錄',
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
            ),
          ],
        ),
      ),
    );
  }
  
  /// 構建營養資訊輸入欄位
  Widget _buildNutritionField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
          ],
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
        ),
      ],
    );
  }
  
  /// 保存餐點
  void _saveMeal() {
    if (_formKey.currentState!.validate()) {
      // 準備數據
      final mealData = {
        'name': _foodNameController.text,
        'portion': _portionController.text.isNotEmpty ? _portionController.text : '-',
        'calories': _caloriesController.text.isNotEmpty ? int.parse(_caloriesController.text) : 0,
        'protein': _proteinController.text.isNotEmpty ? double.parse(_proteinController.text) : 0.0,
        'carbs': _carbsController.text.isNotEmpty ? double.parse(_carbsController.text) : 0.0,
        'fat': _fatController.text.isNotEmpty ? double.parse(_fatController.text) : 0.0,
      };
      
      // 返回首頁並顯示成功訊息
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 已添加「${mealData['name']}」到今日記錄'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

