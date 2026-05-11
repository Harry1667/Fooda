import 'dart:convert';

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../app_config.dart';

/// AI 服務類
/// Flutter 直接調用 Gemini API 和 USDA API
class AiService {
  /// 分析食物圖片
  /// 直接調用 Gemini API
  static Future<AiAnalysisResult> analyzeFood({
    required Uint8List imageBytes,
    String language = 'zh-TW',
  }) async {
    try {
      print('🤖 開始 AI 分析，直接調用 Gemini API...');
      
      // 將圖片轉換為 base64
      final base64Image = base64Encode(imageBytes);
      print('📷 圖片已轉換為 base64，大小: ${base64Image.length} 字符');
      
      // 根據語言生成提示詞
      final prompt = _generatePrompt(language);
      print('💬 使用提示詞語言: $language');
      
      // 構建請求體
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
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
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('📡 Gemini API 響應狀態: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📄 API 響應數據: $data');
        
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          throw Exception('Gemini API 沒有返回識別結果');
        }
        
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        print('🔍 識別結果: $content');
        
        // 清理 JSON 字符串（移除可能的 markdown 格式）
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
        final errorBody = response.body;
        print('❌ Gemini API 錯誤: ${response.statusCode}, 響應: $errorBody');
        throw Exception('Gemini API 錯誤 (${response.statusCode}): $errorBody');
      }
    } catch (e) {
      print('💥 AI 分析失敗: $e');
      throw Exception('AI 分析失敗: $e');
    }
  }

  /// 查詢營養數據
  /// 直接調用 USDA API
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
      print('🔍 搜索 URL: $searchUrl');
      
      final searchResponse = await http.get(
        Uri.parse(searchUrl),
      ).timeout(const Duration(seconds: 15));

      print('📡 USDA 搜索響應狀態: ${searchResponse.statusCode}');

      if (searchResponse.statusCode == 200) {
        final searchData = jsonDecode(searchResponse.body);
        final foods = searchData['foods'] as List;
        
        print('🔍 找到 ${foods.length} 個匹配的食物');
        
        if (foods.isEmpty) {
          // 嘗試使用預設營養數據
          print('⚠️ 找不到食物: $foodName，使用預設數據');
          return _getDefaultNutritionData(weightInGrams);
        }

        // 選擇最佳匹配的食物（通常是第一個）
        final bestMatch = foods[0];
        final foodId = bestMatch['fdcId'];
        
        print('✅ 選擇食物: ${bestMatch['description']} (ID: $foodId)');
        
        // 獲取詳細營養數據
        final detailUrl = 'https://api.nal.usda.gov/fdc/v1/food/$foodId?api_key=${AppConfig.usdaApiKey}';
        final detailResponse = await http.get(
          Uri.parse(detailUrl),
        ).timeout(const Duration(seconds: 15));

        print('📡 USDA 詳細響應狀態: ${detailResponse.statusCode}');

        if (detailResponse.statusCode == 200) {
          final detailData = jsonDecode(detailResponse.body);
          final nutritionData = AiNutritionData.fromUsda(detailData, weightInGrams);
          print('✅ 營養數據獲取成功');
          return nutritionData;
        } else {
          print('❌ 獲取詳細營養數據失敗: ${detailResponse.statusCode}');
          return _getDefaultNutritionData(weightInGrams);
        }
      } else {
        print('❌ USDA 搜索失敗: ${searchResponse.statusCode}');
        return _getDefaultNutritionData(weightInGrams);
      }
    } catch (e) {
      print('💥 營養數據查詢失敗: $e');
      // 返回預設營養數據而不是拋出異常
      return _getDefaultNutritionData(weightInGrams);
    }
  }

  /// 獲取預設營養數據（當 USDA 查詢失敗時使用）
  static AiNutritionData _getDefaultNutritionData(double weightInGrams) {
    // 基於平均食物的營養密度估算
    final ratio = weightInGrams / 100; // 每100g的比例
    
    return AiNutritionData(
      calories: 150 * ratio, // 平均每100g約150卡路里
      carbs: 20 * ratio,     // 平均每100g約20g碳水
      protein: 8 * ratio,    // 平均每100g約8g蛋白質
      fat: 5 * ratio,        // 平均每100g約5g脂肪
      sodium: 0.3 * ratio,   // 平均每100g約300mg鈉
      fiber: 2 * ratio,      // 平均每100g約2g膳食纖維
    );
  }

  /// 生成多語言提示詞
  static String _generatePrompt(String language) {
    switch (language) {
      case 'zh-CN':
        return '''
请作为一位专业的营养師，仔细分析这张图片中的食物。
请识别所有可见的食物项目，并非常准确地估算每个食物的重量（克）。

重要分析步骤：
1. 观察容器大小：首先判断盘子、碗或杯子的大小（标准/大/小）。
2. 观察食物体积：注意食物的堆叠高度和密度。不要只看表面积。
3. 估算重量：结合体积和食物密度进行估算。

参考标准（请严格对照）：
- 米饭/面食：
  - 一平碗米饭：约 150-180g
  - 一满碗米饭：约 200-250g
  - 一盘意大利面：约 200-250g
- 肉类/蛋白质：
  - 手掌大小的肉排：约 100-120g
  - 一只鸡腿：约 100-120g
  - 一颗鸡蛋：约 50-60g
- 蔬菜/水果：
  - 一拳头大小的水果：约 150-200g
  - 一份烫青菜（熟）：约 100-150g
  - 一份生菜沙拉（蓬松）：约 80-100g

返回格式（纯JSON）：
{
  "foods": [
    {
      "name": "食物中文名称",
      "name_en": "simple english food name (for database search)",
      "weight_grams": 150,
      "confidence": 0.9
    }
  ]
}
''';
      case 'en-US':
        return '''
Act as a professional nutritionist and carefully analyze the food in this image.
Identify all visible food items and accurately estimate the weight (in grams) of each.

Analysis Steps:
1. Container Size: First, assess the size of the plate, bowl, or cup (standard/large/small).
2. Food Volume: Pay attention to the stacking height and density of the food, not just the surface area.
3. Weight Estimation: Combine volume and food density for the estimate.

Reference Standards (Please follow strictly):
- Rice/Noodles:
  - Level bowl of rice: ~150-180g
  - Heaping bowl of rice: ~200-250g
  - Plate of pasta: ~200-250g
- Meat/Protein:
  - Palm-sized steak/chop: ~100-120g
  - One chicken drumstick: ~100-120g
  - One egg: ~50-60g
- Vegetables/Fruits:
  - Fist-sized fruit: ~150-200g
  - Cooked leafy greens (serving): ~100-150g
  - Salad greens (fluffy): ~80-100g

Return Format (Pure JSON):
{
  "foods": [
    {
      "name": "Food Name",
      "name_en": "simple english food name",
      "weight_grams": 150,
      "confidence": 0.9
    }
  ]
}
''';
      case 'ja-JP':
        return '''
プロの栄養士として、この画像の食事を分析してください。
見えるすべての食品を特定し、それぞれの重量（グラム）を正確に推定してください。

分析ステップ：
1. 器のサイズ：まず、皿や茶碗の大きさ（標準/大/小）を判断します。
2. 食品の体積：表面積だけでなく、盛り付けの高さや密度に注意してください。
3. 重量の推定：体積と食品の密度を考慮して計算します。

参考基準（厳密に参照してください）：
- ご飯・麺類：
  - ご飯（小盛り）：約 100-120g
  - ご飯（普通盛り）：約 150-180g
  - ご飯（大盛り）：約 200-250g
- 肉・タンパク質：
  - 手のひらサイズの肉：約 100-120g
  - 卵1個：約 50-60g
- 野菜・果物：
  - 握りこぶし大の果物：約 150-200g
  - 温野菜（1人前）：約 100-150g
  - サラダ（1人前）：約 80-100g

返却フォーマット（純粋なJSONのみ）：
{
  "foods": [
    {
      "name": "食品名（日本語）",
      "name_en": "English food name",
      "weight_grams": 150,
      "confidence": 0.9
    }
  ]
}
''';
      default: // zh-TW
        return '''
請作為一位專業的營養師，仔細分析這張圖片中的食物。
請識別所有可見的食物項目，並非常準確地估算每個食物的重量（克）。

重要分析步驟：
1. 觀察容器大小：首先判斷盤子、碗或杯子的大小（標準/大/小）。
2. 觀察食物體積：注意食物的堆疊高度和密度。不要只看表面積。
3. 估算重量：結合體積和食物密度進行估算。

參考標準（請嚴格對照）：
- 米飯/麵食：
  - 一平碗白飯：約 150-180g
  - 一滿碗白飯：約 200-250g
  - 一盤義大利麵：約 200-250g
- 肉類/蛋白質：
  - 手掌大小的肉排：約 100-120g
  - 一隻雞腿：約 100-120g
  - 一顆雞蛋：約 50-60g
- 蔬菜/水果：
  - 一拳頭大小的水果：約 150-200g
  - 一份燙青菜（熟）：約 100-150g
  - 一份生菜沙拉（蓬鬆）：約 80-100g

返回格式（純JSON）：
{
  "foods": [
    {
      "name": "食物中文名稱",
      "name_en": "simple english food name (for database search)",
      "weight_grams": 150,
      "confidence": 0.9
    }
  ]
}
''';
    }
  }
}

/// AI 分析結果模型
class AiAnalysisResult {
  final List<AiFoodItem> foods;

  AiAnalysisResult({required this.foods});

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    final foodsJson = json['foods'] as List;
    final foods = foodsJson.map((food) => AiFoodItem.fromJson(food)).toList();
    return AiAnalysisResult(foods: foods);
  }

  /// 從 PHP API 響應創建分析結果
  factory AiAnalysisResult.fromPhpApi(Map<String, dynamic> data) {
    final foodsJson = data['foods'] as List? ?? [];
    final foods = foodsJson.map((food) => AiFoodItem.fromPhpApi(food)).toList();
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

  /// 從 PHP API 響應創建食物項目
  factory AiFoodItem.fromPhpApi(Map<String, dynamic> json) {
    return AiFoodItem(
      name: json['name'] ?? json['name_zh'] ?? '',
      nameEn: json['name_en'] ?? json['name'] ?? '',
      weightGrams: (json['weight_grams'] ?? json['weight'] ?? 0).toDouble(),
      confidence: (json['confidence'] ?? 0.8).toDouble(),
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

  /// 從 PHP API 響應創建營養數據
  factory AiNutritionData.fromPhpApi(Map<String, dynamic> nutrition, double weightInGrams) {
    return AiNutritionData(
      calories: (nutrition['calories'] ?? 0).toDouble(),
      carbs: (nutrition['carbs'] ?? nutrition['carbohydrates'] ?? 0).toDouble(),
      protein: (nutrition['protein'] ?? 0).toDouble(),
      fat: (nutrition['fat'] ?? nutrition['total_fat'] ?? 0).toDouble(),
      sodium: (nutrition['sodium'] ?? 0).toDouble() / 1000, // 轉換為克
      fiber: (nutrition['fiber'] ?? nutrition['dietary_fiber'] ?? 0).toDouble(),
    );
  }

  factory AiNutritionData.fromUsda(Map<String, dynamic> usdaData, double weightInGrams) {
    final nutrients = usdaData['foodNutrients'] as List? ?? [];
    
    print('🧮 解析 USDA 營養數據，共 ${nutrients.length} 個營養素');
    
    // 營養素ID對照表
    const nutrientIds = {
      208: 'calories',    // Energy (kcal)
      205: 'carbs',       // Carbohydrate
      203: 'protein',     // Protein
      204: 'fat',         // Total lipid (fat)
      307: 'sodium',      // Sodium
      291: 'fiber',       // Fiber, total dietary
    };

    final nutritionMap = <String, double>{
      'calories': 0.0,
      'carbs': 0.0,
      'protein': 0.0,
      'fat': 0.0,
      'sodium': 0.0,
      'fiber': 0.0,
    };

    // 解析營養素數據
    for (final nutrient in nutrients) {
      try {
        final nutrientInfo = nutrient['nutrient'];
        if (nutrientInfo == null) continue;
        
        final nutrientId = nutrientInfo['id'];
        final amount = nutrient['amount'];
        
        if (nutrientId != null && amount != null && nutrientIds.containsKey(nutrientId)) {
          final value = (amount is num) ? amount.toDouble() : 0.0;
          final key = nutrientIds[nutrientId]!;
          
          // 將每100g的數值轉換為實際重量的數值
          nutritionMap[key] = (value * weightInGrams / 100);
          
          print('📊 ${nutrientInfo['name']}: ${value} -> ${nutritionMap[key]}');
        }
      } catch (e) {
        print('⚠️ 解析營養素時出錯: $e');
        continue;
      }
    }

    // 如果所有營養素都是0，使用預設值
    if (nutritionMap.values.every((value) => value == 0.0)) {
      print('⚠️ 所有營養素為0，使用預設值');
      final ratio = weightInGrams / 100;
      nutritionMap['calories'] = 150 * ratio;
      nutritionMap['carbs'] = 20 * ratio;
      nutritionMap['protein'] = 8 * ratio;
      nutritionMap['fat'] = 5 * ratio;
      nutritionMap['sodium'] = 0.3 * ratio;
      nutritionMap['fiber'] = 2 * ratio;
    }

    return AiNutritionData(
      calories: nutritionMap['calories']!,
      carbs: nutritionMap['carbs']!,
      protein: nutritionMap['protein']!,
      fat: nutritionMap['fat']!,
      sodium: nutritionMap['sodium']! / 1000, // 轉換為克
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