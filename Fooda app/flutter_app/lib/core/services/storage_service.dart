import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_model.dart';

/// 本地存儲服務
/// 用於保存餐點記錄、用戶數據等
class StorageService {
  static const String _mealRecordsKey = 'meal_records';
  static const String _bodyDataKey = 'body_data';
  static const String _darkModeKey = 'fooda_darkMode';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// 初始化存儲服務
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // ========== 餐點記錄相關 ==========

  /// 獲取所有餐點記錄
  Future<List<MealRecord>> getMealRecords() async {
    try {
      final String? jsonString = _prefs.getString(_mealRecordsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<MealRecord> records = [];
      
      for (final json in jsonList) {
        try {
          if (json is Map<String, dynamic>) {
            records.add(MealRecord.fromJson(json));
          }
        } catch (e) {
          print('⚠️ 跳過損壞的餐點記錄: $e');
        }
      }
      
      return records;
    } catch (e) {
      print('讀取餐點記錄失敗: $e');
      return [];
    }
  }

  /// 保存所有餐點記錄
  Future<bool> saveMealRecords(List<MealRecord> records) async {
    try {
      final jsonList = records.map((record) => record.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs.setString(_mealRecordsKey, jsonString);
    } catch (e) {
      print('保存餐點記錄失敗: $e');
      return false;
    }
  }

  /// 添加單個餐點記錄
  Future<bool> addMealRecord(MealRecord record) async {
    final records = await getMealRecords();
    records.add(record);
    return await saveMealRecords(records);
  }

  /// 更新餐點記錄
  Future<bool> updateMealRecord(String id, MealRecord updatedRecord) async {
    final records = await getMealRecords();
    final index = records.indexWhere((r) => r.id == id);
    
    if (index != -1) {
      records[index] = updatedRecord;
      return await saveMealRecords(records);
    }
    
    return false;
  }

  /// 刪除餐點記錄
  Future<bool> deleteMealRecord(String id) async {
    final records = await getMealRecords();
    records.removeWhere((r) => r.id == id);
    return await saveMealRecords(records);
  }

  /// 清空所有餐點記錄
  Future<bool> clearMealRecords() async {
    return await _prefs.remove(_mealRecordsKey);
  }

  /// 獲取指定日期範圍的餐點記錄
  Future<List<MealRecord>> getMealRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allRecords = await getMealRecords();
    
    return allRecords.where((record) {
      final recordDate = record.dateTime;
      return recordDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          recordDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// 獲取指定日期的餐點記錄
  Future<List<MealRecord>> getMealRecordsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return await getMealRecordsByDateRange(startOfDay, endOfDay);
  }

  // ========== 身體數據相關 ==========

  /// 獲取身體數據
  Future<Map<String, dynamic>?> getBodyData() async {
    try {
      final String? jsonString = _prefs.getString(_bodyDataKey);
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('讀取身體數據失敗: $e');
      return null;
    }
  }

  /// 保存身體數據
  Future<bool> saveBodyData(Map<String, dynamic> data) async {
    try {
      final jsonString = jsonEncode(data);
      return await _prefs.setString(_bodyDataKey, jsonString);
    } catch (e) {
      print('保存身體數據失敗: $e');
      return false;
    }
  }

  /// 清空身體數據
  Future<bool> clearBodyData() async {
    return await _prefs.remove(_bodyDataKey);
  }

  // ========== 應用設置相關 ==========

  /// 獲取深色模式設置
  bool getDarkMode() {
    return _prefs.getBool(_darkModeKey) ?? false;
  }

  /// 設置深色模式
  Future<bool> setDarkMode(bool isDark) async {
    return await _prefs.setBool(_darkModeKey, isDark);
  }

  /// 獲取任意字符串值
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// 設置任意字符串值
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// 獲取任意整數值
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// 設置任意整數值
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// 獲取任意布爾值
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// 設置任意布爾值
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// 刪除指定鍵
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// 清空所有數據
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}

