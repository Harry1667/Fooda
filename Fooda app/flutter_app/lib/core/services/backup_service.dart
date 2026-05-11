import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Fixed import placement
import 'package:flutter/foundation.dart'; // Added for compute
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../features/meals/providers/meal_provider.dart';
import 'package:image/image.dart' as img;

class BackupService {
  static const String _backupVersion = '1.1'; // Bump version for new format
  // CloudKit integration removed
  // static const platform = MethodChannel('com.fooda.cloudkit');

  /// 導出數據並分享
  static Future<bool> exportData(BuildContext context) async {
    try {
      final backupData = await _collectData();
      final String jsonString = jsonEncode(backupData);

      final directory = await getTemporaryDirectory();
      final String timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final String fileName = 'calhub_backup_$timestamp.json';
      final File file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Fooda Backup Data',
        text: 'Here is your Fooda backup file. ($timestamp)',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      print('❌ 備份失敗: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('備份失敗: $e')),
        );
      }
      return false;
    }
  }

  /// 從文件導入數據
  static Future<bool> importData(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return false;

      final File file = File(result.files.single.path!);
      final String jsonString = await file.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      return await _restoreData(context, backupData);
    } catch (e) {
      print('❌ 還原失敗: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('還原失敗: $e')),
        );
      }
      return false;
    }
  }

  // --- 私有輔助方法 ---

  /// 收集數據 (包含圖片轉 Base64)
  static Future<Map<String, dynamic>> _collectData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 處理餐點記錄 (圖片轉 Base64)
    final String? mealRecordsJson = prefs.getString('meal_records');
    List<dynamic> processedMeals = [];
    if (mealRecordsJson != null) {
      final List<dynamic> meals = jsonDecode(mealRecordsJson);
      processedMeals = await _processMealsForExport(meals);
    }

    return {
      'meta': {
        'version': _backupVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Platform.operatingSystem,
      },
      'data': {
        'meal_records': processedMeals,
        'body_data': prefs.getString('body_data'),
        'fooda_darkMode': prefs.getBool('fooda_darkMode'),
        'tutorial_completed': prefs.getBool('tutorial_completed'),
        
        // Profile Data
        'profile_userName': prefs.getString('profile_userName'),
        'profile_height': prefs.getInt('profile_height'),
        'profile_weight': prefs.getInt('profile_weight'),
        'profile_age': prefs.getInt('profile_age'),
        'profile_gender': prefs.getString('profile_gender'),
        'profile_activityLevel': prefs.getString('profile_activityLevel'),
        
        // Nutrition Goals
        'profile_caloriesGoal': prefs.getDouble('profile_caloriesGoal'),
        'profile_carbsGoal': prefs.getDouble('profile_carbsGoal'),
        'profile_proteinGoal': prefs.getDouble('profile_proteinGoal'),
        'profile_fatGoal': prefs.getDouble('profile_fatGoal'),
        'profile_sodiumGoal': prefs.getDouble('profile_sodiumGoal'),
        'profile_fiberGoal': prefs.getDouble('profile_fiberGoal'),
        
        // Notifications
        'profile_breakfastTime': prefs.getString('profile_breakfastTime'),
        'profile_lunchTime': prefs.getString('profile_lunchTime'),
        'profile_dinnerTime': prefs.getString('profile_dinnerTime'),
        'profile_notificationsEnabled': prefs.getBool('profile_notificationsEnabled'),
      }
    };
  }

  /// 還原數據 (包含 Base64 轉圖片 & 智能合併)
  static Future<bool> _restoreData(BuildContext context, Map<String, dynamic> backupData) async {
    if (!backupData.containsKey('meta') || !backupData.containsKey('data')) {
      throw Exception('無效的備份檔案格式');
    }

    final Map<String, dynamic> data = backupData['data'];
    final prefs = await SharedPreferences.getInstance();

    // 1. 餐點記錄 (智能合併 & 圖片還原)
    if (data['meal_records'] != null) {
      final List<dynamic> importedMeals = data['meal_records'];
      
      // 處理圖片還原
      final List<dynamic> mealsWithImages = await _processMealsForImport(importedMeals);
      
      // 智能合併
      final String? currentMealsJson = prefs.getString('meal_records');
      List<dynamic> currentMeals = [];
      if (currentMealsJson != null) {
        currentMeals = jsonDecode(currentMealsJson);
      }
      
      final List<dynamic> mergedMeals = _mergeMeals(currentMeals, mealsWithImages);
      await prefs.setString('meal_records', jsonEncode(mergedMeals));
    }
    
    // 2. 其他數據 (直接覆蓋，因為通常是用戶設定)
    if (data['body_data'] != null) {
      await prefs.setString('body_data', data['body_data']);
    }
    if (data['fooda_darkMode'] != null) {
      await prefs.setBool('fooda_darkMode', data['fooda_darkMode']);
    }
    if (data['tutorial_completed'] != null) {
      await prefs.setBool('tutorial_completed', data['tutorial_completed']);
    }

    // Restore Profile Data
    if (data['profile_userName'] != null) await prefs.setString('profile_userName', data['profile_userName']);
    if (data['profile_height'] != null) await prefs.setInt('profile_height', data['profile_height']);
    if (data['profile_weight'] != null) await prefs.setInt('profile_weight', data['profile_weight']);
    if (data['profile_age'] != null) await prefs.setInt('profile_age', data['profile_age']);
    if (data['profile_gender'] != null) await prefs.setString('profile_gender', data['profile_gender']);
    if (data['profile_activityLevel'] != null) await prefs.setString('profile_activityLevel', data['profile_activityLevel']);

    // Restore Nutrition Goals
    if (data['profile_caloriesGoal'] != null) await prefs.setDouble('profile_caloriesGoal', data['profile_caloriesGoal']);
    if (data['profile_carbsGoal'] != null) await prefs.setDouble('profile_carbsGoal', data['profile_carbsGoal']);
    if (data['profile_proteinGoal'] != null) await prefs.setDouble('profile_proteinGoal', data['profile_proteinGoal']);
    if (data['profile_fatGoal'] != null) await prefs.setDouble('profile_fatGoal', data['profile_fatGoal']);
    if (data['profile_sodiumGoal'] != null) await prefs.setDouble('profile_sodiumGoal', data['profile_sodiumGoal']);
    if (data['profile_fiberGoal'] != null) await prefs.setDouble('profile_fiberGoal', data['profile_fiberGoal']);

    // Restore Notifications
    if (data['profile_breakfastTime'] != null) await prefs.setString('profile_breakfastTime', data['profile_breakfastTime']);
    if (data['profile_lunchTime'] != null) await prefs.setString('profile_lunchTime', data['profile_lunchTime']);
    if (data['profile_dinnerTime'] != null) await prefs.setString('profile_dinnerTime', data['profile_dinnerTime']);
    if (data['profile_notificationsEnabled'] != null) await prefs.setBool('profile_notificationsEnabled', data['profile_notificationsEnabled']);

    // 3. 重新載入 Provider
    if (context.mounted) {
      final mealProvider = Provider.of<MealProvider>(context, listen: false);
      await mealProvider.reloadMeals();
    }

    return true;
  }

  /// 處理導出：將圖片路徑轉換為 Base64 (含壓縮)
  static Future<List<dynamic>> _processMealsForExport(List<dynamic> meals) async {
    final List<dynamic> processed = [];
    
    for (var meal in meals) {
      final Map<String, dynamic> mealMap = Map<String, dynamic>.from(meal);
      
      // 處理主圖
      if (mealMap['imageUrl'] != null) {
        final String path = mealMap['imageUrl'];
        final File imageFile = File(path);
        if (await imageFile.exists()) {
          final compressedBytes = await _compressImage(imageFile);
          if (compressedBytes != null) {
            mealMap['imageBase64'] = base64Encode(compressedBytes);
          }
        }
      }

      // 處理食物圖片
      if (mealMap['foods'] != null) {
        final List<dynamic> foods = [];
        for (var food in mealMap['foods']) {
          final Map<String, dynamic> foodMap = Map<String, dynamic>.from(food);
          if (foodMap['imageUrl'] != null) {
            final String path = foodMap['imageUrl'];
            final File imageFile = File(path);
            if (await imageFile.exists()) {
              final compressedBytes = await _compressImage(imageFile);
              if (compressedBytes != null) {
                foodMap['imageBase64'] = base64Encode(compressedBytes);
              }
            }
          }
          foods.add(foodMap);
        }
        mealMap['foods'] = foods;
      }
      
      processed.add(mealMap);
    }
    return processed;
  }

  /// 壓縮圖片：調整大小並降低品質 (使用 Isolate 後台處理)
  static Future<List<int>?> _compressImage(File file) async {
    return compute(_compressImageTask, file.path);
  }

  /// 處理導入：將 Base64 還原為圖片文件
  static Future<List<dynamic>> _processMealsForImport(List<dynamic> meals) async {
    final directory = await getApplicationDocumentsDirectory();
    final String imagesDir = '${directory.path}/restored_images';
    await Directory(imagesDir).create(recursive: true);

    final List<dynamic> processed = [];

    for (var meal in meals) {
      final Map<String, dynamic> mealMap = Map<String, dynamic>.from(meal);
      
      // 還原主圖
      if (mealMap['imageBase64'] != null) {
        try {
          final String base64 = mealMap['imageBase64'];
          final bytes = base64Decode(base64);
          final String fileName = 'meal_${mealMap['id']}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final File imageFile = File('$imagesDir/$fileName');
          await imageFile.writeAsBytes(bytes);
          
          mealMap['imageUrl'] = imageFile.path;
          mealMap.remove('imageBase64'); // 清理 Base64 數據
        } catch (e) {
          print('Error restoring meal image: $e');
        }
      }

      // 還原食物圖片
      if (mealMap['foods'] != null) {
        final List<dynamic> foods = [];
        for (var food in mealMap['foods']) {
          final Map<String, dynamic> foodMap = Map<String, dynamic>.from(food);
          if (foodMap['imageBase64'] != null) {
            try {
              final String base64 = foodMap['imageBase64'];
              final bytes = base64Decode(base64);
              final String fileName = 'food_${foodMap['id']}_${DateTime.now().millisecondsSinceEpoch}.jpg';
              final File imageFile = File('$imagesDir/$fileName');
              await imageFile.writeAsBytes(bytes);
              
              foodMap['imageUrl'] = imageFile.path;
              foodMap.remove('imageBase64');
            } catch (e) {
              print('Error restoring food image: $e');
            }
          }
          foods.add(foodMap);
        }
        mealMap['foods'] = foods;
      }

      processed.add(mealMap);
    }
    return processed;
  }

  /// 智能合併：以 ID 為鍵，雲端數據優先
  static List<dynamic> _mergeMeals(List<dynamic> local, List<dynamic> cloud) {
    final Map<String, dynamic> mergedMap = {};

    // 1. 先放入本地數據
    for (var meal in local) {
      if (meal['id'] != null) {
        mergedMap[meal['id']] = meal;
      }
    }

    // 2. 放入雲端數據 (會覆蓋相同 ID 的本地數據)
    for (var meal in cloud) {
      if (meal['id'] != null) {
        mergedMap[meal['id']] = meal;
      }
    }

    return mergedMap.values.toList();
  }
}

/// 圖片壓縮任務 (在 Isolate 中運行，必須是頂層函數)
Future<List<int>?> _compressImageTask(String filePath) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) return null;

    // 1. 調整大小 (如果寬度大於 800px)
    var processedImage = image;
    if (processedImage.width > 800) {
      processedImage = img.copyResize(processedImage, width: 800);
    }

    // 2. 壓縮為 JPEG (品質 70%)
    return img.encodeJpg(processedImage, quality: 70);
  } catch (e) {
    print('Image compression failed: $e');
    return null;
  }
}
