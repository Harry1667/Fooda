import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../app_config.dart';

/// AI 服務類 - 乾淨版本
/// Flutter 直接調用 Gemini API 和 USDA API
class AiService {
  /// 分析食物圖片
  static Future<AiAnalysisResult> analyzeFood({
    required Uint8List imageBytes,
    String language = 'zh-TW',
  }) async {
    try {
      print('🤖 開始 AI 分析，直接調用 Gemini API...');
      
      // 將圖片轉換為 base64
      final base64Image = base64Encode(imageBytes);
      print('📷 圖片已轉換為 base64，大小: ${base64Image.length} 字符');
      
      // 構建請求體
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': _getPrompt(language)},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.2,
          'maxOutputTokens': 1024,
          'responseMimeType': 'application/json'
        }
      };

      print('🌐 發送請求到 Gemini API...');
      
      // 發送請求到 Gemini API
      final response = await http.post(
        Uri.parse('${AppConfig.geminiApiUrl}?key=${AppConfig.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('📡 Gemini API 響應狀態: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          throw Exception('Gemini API 沒有返回識別結果');
        }
        
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        print('🔍 識別結果: $content');
        
        // 清理 JSON 字符串
        String cleanContent = content.trim();
        if (cleanContent.startsWith('```json')) {
          cleanContent = cleanContent.substring(7);
        }
        if (cleanContent.endsWith('```')) {
          cleanContent = cleanContent.substring(0, cleanContent.length - 3);
        }
        cleanContent = cleanContent.trim();
        
        final analysisData = jsonDecode(cleanContent);
        print('✅ 解析成功，識別到 ${analysisData['foods']?.length ?? 0} 個食物');
        
        return AiAnalysisResult.fromJson(analysisData);
      } else {
        throw Exception('Gemini API 錯誤 (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('💥 AI 分析失敗: $e');
      throw Exception('AI 分析失敗: $e');
    }
  }

  /// 查詢營養數據
  static Future<AiNutritionData> getNutritionData({
    required String foodName,
    required double weightInGrams,
  }) async {
    try {
      print('🥗 查詢營養數據: $foodName (${weightInGrams}g)');
      
      // 清理食物名稱
      final cleanFoodName = foodName.trim().toLowerCase();
      final encodedFoodName = Uri.encodeComponent(cleanFoodName);
      
      // 搜索食物
      final searchUrl = 'https://api.nal.usda.gov/fdc/v1/foods/search?api_key=${AppConfig.usdaApiKey}&query=$encodedFoodName&pageSize=5';
      
      final searchResponse = await http.get(Uri.parse(searchUrl)).timeout(const Duration(seconds: 15));

      if (searchResponse.statusCode == 200) {
        final searchData = jsonDecode(searchResponse.body);
        final foods = searchData['foods'] as List;
        
        if (foods.isEmpty) {
          print('⚠️ 找不到食物: $foodName，使用預設數據');
          return _getDefaultNutritionData(weightInGrams);
        }

        // 選擇最佳匹配的食物
        final bestMatch = foods[0];
        final foodId = bestMatch['fdcId'];
        
        // 獲取詳細營養數據
        final detailUrl = 'https://api.nal.usda.gov/fdc/v1/food/$foodId?api_key=${AppConfig.usdaApiKey}';
        final detailResponse = await http.get(Uri.parse(detailUrl)).timeout(const Duration(seconds: 15));

        if (detailResponse.statusCode == 200) {
          final detailData = jsonDecode(detailResponse.body);
          return AiNutritionData.fromUsda(detailData, weightInGrams);
        }
      }
      
      return _getDefaultNutritionData(weightInGrams);
    } catch (e) {
      print('💥 營養數據查詢失敗: $e');
      return _getDefaultNutritionData(weightInGrams);
    }
  }

  /// 獲取提示詞
  static String _getPrompt(String language) {
    return '''
請仔細分析這張圖片中的食物，並以標準JSON格式返回結果。

返回格式：
{
  "foods": [
    {
      "name": "食物中文名稱",
      "name_en": "simple english food name",
      "weight_grams": 100,
      "confidence": 0.85
    }
  ]
}
''';
  }

  /// 獲取預設營養數據
  static AiNutritionData _getDefaultNutritionData(double weightInGrams) {
    final ratio = weightInGrams / 100;
    return AiNutritionData(
      calories: 150 * ratio,
      carbs: 20 * ratio,
      protein: 8 * ratio,
      fat: 5 * ratio,
      sodium: 0.3 * ratio,
      fiber: 2 * ratio,
    );
  }
}

/// AI 分析結果模型
class AiAnalysisResult {
  final List<AiFoodItem> foods;

  AiAnalysisResult({required this.foods});

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    final foodsJson = json['foods'] as List? ?? [];
    final foods = foodsJson.map((food) => AiFoodItem.fromJson(food)).toList();
    return AiAnalysisResult(foods: foods);
  }
}

/// AI 食物項目模型
class AiFoodItem {
  final String name;
  final String nameEn;
  final double weightGrams;
  final double confidence;
  AiNutritionData? nutritionData;

  AiFoodItem({
    required this.name,
    required this.nameEn,
    required this.weightGrams,
    required this.confidence,
    this.nutritionData,
  });

  factory AiFoodItem.fromJson(Map<String, dynamic> json) {
    return AiFoodItem(
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      weightGrams: (json['weight_grams'] ?? 0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  AiFoodItem copyWith({
    String? name,
    String? nameEn,
    double? weightGrams,
    double? confidence,
    AiNutritionData? nutritionData,
  }) {
    return AiFoodItem(
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      weightGrams: weightGrams ?? this.weightGrams,
      confidence: confidence ?? this.confidence,
      nutritionData: nutritionData ?? this.nutritionData,
    );
  }
}

/// AI 營養數據模型
class AiNutritionData {
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final double sodium;
  final double fiber;

  AiNutritionData({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.sodium,
    required this.fiber,
  });

  factory AiNutritionData.fromUsda(Map<String, dynamic> usdaData, double weightInGrams) {
    final nutrients = usdaData['foodNutrients'] as List? ?? [];
    
    const nutrientIds = {
      208: 'calories',
      205: 'carbs',
      203: 'protein',
      204: 'fat',
      307: 'sodium',
      291: 'fiber',
    };

    final nutritionMap = <String, double>{
      'calories': 0.0,
      'carbs': 0.0,
      'protein': 0.0,
      'fat': 0.0,
      'sodium': 0.0,
      'fiber': 0.0,
    };

    for (final nutrient in nutrients) {
      try {
        final nutrientInfo = nutrient['nutrient'];
        if (nutrientInfo == null) continue;
        
        final nutrientId = nutrientInfo['id'];
        final amount = nutrient['amount'];
        
        if (nutrientId != null && amount != null && nutrientIds.containsKey(nutrientId)) {
          final value = (amount is num) ? amount.toDouble() : 0.0;
          final key = nutrientIds[nutrientId]!;
          nutritionMap[key] = (value * weightInGrams / 100);
        }
      } catch (e) {
        continue;
      }
    }

    return AiNutritionData(
      calories: nutritionMap['calories']!,
      carbs: nutritionMap['carbs']!,
      protein: nutritionMap['protein']!,
      fat: nutritionMap['fat']!,
      sodium: nutritionMap['sodium']! / 1000,
      fiber: nutritionMap['fiber']!,
    );
  }

  AiNutritionData scaleByWeight(double newWeightGrams, double originalWeightGrams) {
    final ratio = newWeightGrams / originalWeightGrams;
    return AiNutritionData(
      calories: calories * ratio,
      carbs: carbs * ratio,
      protein: protein * ratio,
      fat: fat * ratio,
      sodium: sodium * ratio,
      fiber: fiber * ratio,
    );
  }
}