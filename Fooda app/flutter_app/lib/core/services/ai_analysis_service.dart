import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../app_config.dart';
import '../env_config.dart';

/// AI 分析服務
/// 對應 PHP 版本的 api/analyze.php
class AiAnalysisService {
  /// 分析食物照片（使用 Gemini AI）
  /// 
  /// [imageFile] - 要分析的圖片文件
  /// [language] - 語言設定（默認 zh-TW）
  /// 
  /// 返回識別結果：
  /// ```dart
  /// {
  ///   'success': true,
  ///   'items': [
  ///     {
  ///       'name': '雞胸肉',
  ///       'englishName': 'Chicken Breast',
  ///       'portion': '150g',
  ///       'calories': 165,
  ///       'carbs': 0,
  ///       'protein': 31,
  ///       'fat': 3.6,
  ///       ...
  ///     }
  ///   ]
  /// }
  /// ```
  static Future<Map<String, dynamic>> analyzeImage({
    required File imageFile,
    String language = 'zh-TW',
  }) async {
    try {
      print('🚀 開始 AI 圖片分析...');
      print('📁 圖片路徑: ${imageFile.path}');
      print('📏 圖片大小: ${await imageFile.length()} bytes');

      // 檢查文件是否存在
      if (!await imageFile.exists()) {
        return {
          'success': false,
          'error': '圖片文件不存在',
          'code': 'FILE_NOT_FOUND',
        };
      }

      // 檢查文件大小（最大 10MB）
      final fileSize = await imageFile.length();
      if (fileSize > AppConfig.maxUploadSize) {
        return {
          'success': false,
          'error': '圖片文件過大，請選擇小於 10MB 的圖片',
          'code': 'FILE_TOO_LARGE',
        };
      }

      // 檢查文件類型
      final fileName = imageFile.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      print('📝 文件名稱: $fileName');
      print('📋 文件擴展名: $fileExtension');
      
      // 檢查是否為支持的格式
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(fileExtension)) {
        print('⚠️ 警告: 不支持的文件格式 .$fileExtension');
        
        // 如果是 HEIC，提示用戶
        if (fileExtension == 'heic' || fileExtension == 'heif') {
          return {
            'success': false,
            'error': '不支持 HEIC 格式，請在相冊中將圖片轉換為 JPEG 格式後再上傳',
            'code': 'UNSUPPORTED_FORMAT',
          };
        }
      }

      // 使用環境自適應配置
      final apiUrl = EnvConfig.analyzeApiUrl;
      
      if (kDebugMode) {
        print('🔧 環境: ${EnvConfig.environmentName}');
        print('🌐 API URL: $apiUrl');
      }

      // 準備 multipart 請求（對應 PHP 的 $_FILES['photo']）
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(apiUrl),
      );

      // 添加圖片文件
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
        ),
      );

      // 添加語言參數
      request.fields['language'] = language;

      print('📡 發送請求到: $apiUrl');
      print('🌐 語言設定: $language');
      print('📝 文件名稱: ${imageFile.path.split('/').last}');
      print('📏 文件大小: ${fileSize} bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)');

      // 發送請求
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📊 HTTP 狀態碼: ${response.statusCode}');
      print('📋 回應內容: ${response.body}');

      // 檢查 HTTP 狀態碼
      if (response.statusCode != 200) {
        print('❌ API 請求失敗！');
        print('錯誤碼: ${response.statusCode}');
        print('錯誤內容: ${response.body}');
        
        // 嘗試解析後端錯誤信息
        String errorMessage = 'API 請求失敗 (${response.statusCode})';
        try {
          final errorData = json.decode(response.body);
          if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          // 無法解析 JSON，使用原始內容
          if (response.body.isNotEmpty && response.body.length < 200) {
            errorMessage = response.body;
          }
        }
        
        return {
          'success': false,
          'error': errorMessage,
          'code': 'HTTP_ERROR',
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }

      // 解析 JSON 回應
      final Map<String, dynamic> result = json.decode(response.body);

      print('✅ API 回應解析成功');
      print('🎯 識別結果: ${result['success']}');
      if (result['success'] == true && result['items'] != null) {
        print('📦 識別食物數量: ${result['items'].length}');
      }

      return result;
    } catch (e, stackTrace) {
      print('❌ AI 分析失敗: $e');
      print('📚 堆疊追蹤: $stackTrace');
      
      return {
        'success': false,
        'error': '分析失敗: $e',
        'code': 'EXCEPTION',
      };
    }
  }

  /// 直接使用 Gemini API 分析圖片（不通過 PHP）
  /// 
  /// 這個方法適用於 Flutter app 直接連接 Gemini API 的場景
  static Future<Map<String, dynamic>> analyzeImageDirect({
    required File imageFile,
    String language = 'zh-TW',
  }) async {
    try {
      print('🚀 開始直接 Gemini API 分析...');
      print('📁 圖片路徑: ${imageFile.path}');

      // 讀取圖片並轉換為 Base64
      final imageBytes = await imageFile.readAsBytes();
      final imageSizeKB = (imageBytes.length / 1024).toStringAsFixed(2);
      print('📏 圖片大小: ${imageBytes.length} bytes ($imageSizeKB KB)');
      
      // 檢查圖片是否太大（建議小於 4MB）
      if (imageBytes.length > 4 * 1024 * 1024) {
        print('⚠️ 警告：圖片較大 ($imageSizeKB KB)，可能影響處理速度');
      }
      
      final base64Image = base64Encode(imageBytes);
      final base64SizeKB = (base64Image.length / 1024).toStringAsFixed(2);
      print('📦 Base64 大小: ${base64Image.length} 字符 ($base64SizeKB KB)');

      // 準備請求體（對應 PHP 的 Gemini API 請求）
      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': _getAnalysisPrompt(language),
              },
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
            ],
          },
        ],
        'generationConfig': AppConfig.geminiConfig,
      };

      // 發送請求到 Gemini API
      final response = await http.post(
        Uri.parse('${AppConfig.geminiApiUrl}?key=${AppConfig.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('📊 Gemini HTTP 狀態碼: ${response.statusCode}');
      print('📋 完整回應: ${response.body}');

      if (response.statusCode != 200) {
        print('❌ API 請求失敗！');
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error']?['message'] ?? 'Gemini API 請求失敗',
          'code': 'GEMINI_ERROR',
        };
      }

      // 解析 Gemini 回應
      final geminiResponse = json.decode(response.body);
      print('🔍 解析的回應: $geminiResponse');
      
      // 提取 JSON 內容（對應 PHP 的解析邏輯）
      if (geminiResponse['candidates'] == null || 
          geminiResponse['candidates'].isEmpty) {
        print('❌ 沒有候選結果');
        return {
          'success': false,
          'error': 'Gemini 未返回識別結果',
          'code': 'NO_CANDIDATES',
        };
      }

      // 安全地提取內容
      final candidate = geminiResponse['candidates'][0];
      print('🔍 候選結果: $candidate');
      
      // 檢查 finishReason（可能被安全過濾器阻擋）
      final finishReason = candidate['finishReason'];
      print('🏁 finishReason: $finishReason');
      
      if (finishReason != null && finishReason != 'STOP') {
        print('⚠️ 內容被過濾或處理異常: $finishReason');
        
        String errorMsg = 'Gemini 處理異常';
        if (finishReason == 'SAFETY') {
          errorMsg = '內容被安全過濾器阻擋，請嘗試其他照片';
        } else if (finishReason == 'MAX_TOKENS') {
          errorMsg = '回應內容過長，已截斷';
        } else if (finishReason == 'RECITATION') {
          errorMsg = '內容涉及版權問題';
        }
        
        return {
          'success': false,
          'error': errorMsg,
          'code': 'BLOCKED_BY_FILTER',
          'finishReason': finishReason,
        };
      }
      
      if (candidate['content'] == null) {
        print('❌ content 為 null');
        return {
          'success': false,
          'error': 'Gemini 回應格式錯誤：content 為空',
          'code': 'INVALID_RESPONSE',
        };
      }
      
      final content = candidate['content'];
      print('🔍 內容: $content');
      
      if (content['parts'] == null || content['parts'].isEmpty) {
        print('❌ parts 為 null 或空');
        return {
          'success': false,
          'error': 'Gemini 回應格式錯誤：parts 為空',
          'code': 'INVALID_RESPONSE',
        };
      }
      
      final text = content['parts'][0]['text'];
      print('📝 提取的文本: $text');

      if (text == null || text.isEmpty) {
        print('❌ text 為 null 或空');
        return {
          'success': false,
          'error': 'Gemini 未返回文本內容',
          'code': 'NO_TEXT',
        };
      }

      // 解析 JSON（Gemini 可能返回 ```json...``` 格式）
      String jsonText = text.trim();
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();
      
      print('🔍 清理後的 JSON: $jsonText');

      final items = json.decode(jsonText);
      print('✅ 解析成功，項目數量: ${items is List ? items.length : 0}');

      return {
        'success': true,
        'items': items,
      };
    } catch (e, stackTrace) {
      print('❌ Gemini 直接分析失敗: $e');
      print('📚 堆疊追蹤: $stackTrace');
      
      return {
        'success': false,
        'error': '分析失敗: $e',
        'code': 'EXCEPTION',
      };
    }
  }

  /// 獲取 AI 分析提示詞（改進版，包含詳細的重量估算指南）
  static String _getAnalysisPrompt(String language) {
    // 根據語言返回不同的提示詞
    switch (language) {
      case 'zh-CN':
        return '''
仔细识别图片中的食物，返回 JSON 数组。

重量估算参考标准：
- 一碗白米饭：200-250克
- 鸡胸肉一份：100-150克  
- 一颗鸡蛋：50-60克
- 一个苹果：150-200克
- 一片吐司：30-40克
- 一杯牛奶：240克
- 蔬菜一份：80-100克

请根据照片中食物的大小、容器大小、堆叠高度准确估算重量。

格式：
[{"name":"食物名(简体中文)","englishName":"English Name","portion":"准确克数g","calories":卡路里数值,"carbs":碳水数值,"protein":蛋白质数值,"fat":脂肪数值,"fiber":纤维数值,"sodium":钠数值,"sugar":糖数值}]

要求：
1. 只返回 JSON 数组，不要其他文字
2. portion 必须是准确的克数，例如 "220g"、"130g"
3. "name" 字段必须使用简体中文
4. 无法识别返回 []
''';
      
      case 'en-US':
        return '''
Carefully identify foods in the image, return JSON array.

Weight estimation reference standards:
- Bowl of rice: 200-250 grams
- Chicken breast: 100-150 grams
- One egg: 50-60 grams
- One apple: 150-200 grams
- One slice of toast: 30-40 grams
- One cup of milk: 240 grams
- Vegetable serving: 80-100 grams

Estimate weight accurately based on food size, container size, and stacking height in the photo.

Format:
[{"name":"Food Name (in English)","englishName":"English Name","portion":"accurate weight in g","calories":calorie_value,"carbs":carb_value,"protein":protein_value,"fat":fat_value,"fiber":fiber_value,"sodium":sodium_value,"sugar":sugar_value}]

Requirements:
1. Return only JSON array, no other text
2. portion must be accurate weight, e.g., "220g", "130g"
3. "name" field MUST be in English
4. Return [] if unable to identify
''';
      
      case 'ja':
        return '''
画像を注意深く識別し、JSON配列を返してください。

重量推定の参考基準：
- ご飯一杯：200-250g
- 鶏胸肉一人前：100-150g
- 卵一個：50-60g
- リンゴ一個：150-200g
- 食パン一枚：30-40g
- 牛乳一杯：240g
- 野菜一人前：80-100g

写真の食品の大きさ、容器の大きさ、積み重ねの高さを基に、重量を正確に推定してください。

フォーマット：
[{"name":"食品名(日本語)","englishName":"English Name","portion":"正確なグラム数g","calories":カロリー数値,"carbs":炭水化物数値,"protein":タンパク質数値,"fat":脂質数値,"fiber":食物繊維数値,"sodium":ナトリウム数値,"sugar":糖質数値}]

要件：
1. JSON配列のみを返し、他の文字は含めないでください
2. portionは正確なグラム数である必要があります（例："220g"、"130g"）
3. "name"フィールドは必ず日本語で記入してください
4. 識別できない場合は [] を返してください
''';

      case 'ko':
        return '''
이미지의 음식을 주의 깊게 식별하고 JSON 배열을 반환하십시오.

중량 추정 참조 표준:
- 밥 한 공기: 200-250g
- 닭가슴살 1인분: 100-150g
- 계란 1개: 50-60g
- 사과 1개: 150-200g
- 식빵 1장: 30-40g
- 우유 1컵: 240g
- 채소 1인분: 80-100g

사진 속 음식의 크기, 용기 크기, 쌓인 높이를 기준으로 무게를 정확하게 추정하십시오.

형식:
[{"name":"음식명(한국어)","englishName":"English Name","portion":"정확한 그램 수g","calories":칼로리 수치,"carbs":탄수화물 수치,"protein":단백질 수치,"fat":지방 수치,"fiber":식이섬유 수치,"sodium":나트륨 수치,"sugar":당류 수치}]

요구 사항:
1. JSON 배열만 반환하고 다른 텍스트는 포함하지 마십시오
2. portion은 정확한 그램 수여야 합니다 (예: "220g", "130g")
3. "name" 필드는 반드시 한국어로 작성하십시오
4. 식별할 수 없는 경우 []를 반환하십시오
''';
      
      default: // zh-TW
        return '''
仔細識別圖片中的食物，返回 JSON 陣列。

重量估算參考標準：
- 一碗白飯：200-250克
- 雞胸肉一份：100-150克
- 一顆雞蛋：50-60克
- 一個蘋果：150-200克
- 一片吐司：30-40克
- 一杯牛奶：240克
- 蔬菜一份：80-100克

請根據照片中食物的大小、容器大小、堆疊高度準確估算重量。

格式：
[{"name":"食物名(繁體中文)","englishName":"English Name","portion":"準確克數g","calories":卡路里數值,"carbs":碳水數值,"protein":蛋白質數值,"fat":脂肪數值,"fiber":纖維數值,"sodium":鈉數值,"sugar":糖數值}]

要求：
1. 只返回 JSON 陣列，不要其他文字
2. portion 必須是準確的克數，例如 "220g"、"130g"
3. "name" 欄位必須使用繁體中文
4. 無法識別返回 []
''';
    }
  }

  /// 獲取 USDA 營養數據（對應 PHP 的 api/nutrition.php）
  static Future<Map<String, dynamic>> getUsdaNutrition({
    required String foodName,
  }) async {
    try {
      print('🔍 查詢 USDA 營養數據: $foodName');

      final url = Uri.parse(
        '${AppConfig.nutritionApiUrl}?foodName=${Uri.encodeComponent(foodName)}',
      );

      print('📡 發送請求到: $url');

      final response = await http.get(url);

      print('📊 HTTP 狀態碼: ${response.statusCode}');
      print('📋 回應內容: ${response.body}');

      if (response.statusCode != 200) {
        return {
          'success': false,
          'error': 'USDA API 請求失敗 (${response.statusCode})',
          'code': 'HTTP_ERROR',
        };
      }

      final Map<String, dynamic> result = json.decode(response.body);
      return result;
    } catch (e, stackTrace) {
      print('❌ USDA 查詢失敗: $e');
      print('📚 堆疊追蹤: $stackTrace');
      
      return {
        'success': false,
        'error': '查詢失敗: $e',
        'code': 'EXCEPTION',
      };
    }
  }
}


