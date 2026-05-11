import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 應用本地化類
/// 對應 PHP 版本的多語言支援系統
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // 通用文字
  String get appName => _getText('app_name');
  String get ok => _getText('ok');
  String get cancel => _getText('cancel');
  String get save => _getText('save');
  String get delete => _getText('delete');
  String get edit => _getText('edit');
  String get confirm => _getText('confirm');
  String get loading => _getText('loading');
  String get error => _getText('error');
  String get success => _getText('success');
  String get retry => _getText('retry');
  String get close => _getText('close');
  String get back => _getText('back');
  String get next => _getText('next');
  String get previous => _getText('previous');
  String get done => _getText('done');
  String get skip => _getText('skip');

  // 底部導航
  String get navHome => _getText('nav_home');
  String get navHistory => _getText('nav_history');
  String get navAnalysis => _getText('nav_analysis');
  String get navProfile => _getText('nav_profile');

  // 首頁
  String get todayNutrition => _getText('today_nutrition');
  String get calorieGoal => _getText('calorie_goal');
  String get calories => _getText('calories');
  String get carbs => _getText('carbs');
  String get protein => _getText('protein');
  String get fat => _getText('fat');
  String get sodium => _getText('sodium');
  String get fiber => _getText('fiber');
  String get activity => _getText('activity');
  String get addMeal => _getText('add_meal');
  String get consecutiveDays => _getText('consecutive_days');

  // 記錄方式
  String get selectRecordMethod => _getText('select_record_method');
  String get aiSmartCamera => _getText('ai_smart_camera');
  String get aiSmartCameraDesc => _getText('ai_smart_camera_desc');
  String get manualInput => _getText('manual_input');
  String get manualInputDesc => _getText('manual_input_desc');
  String get aiSmartUpload => _getText('ai_smart_upload');
  String get aiSmartUploadDesc => _getText('ai_smart_upload_desc');
  String get aiQuotaRemaining => _getText('ai_quota_remaining');
  String get upgradeToUnlock => _getText('upgrade_to_unlock');

  // 餐點類型
  String get breakfast => _getText('breakfast');
  String get morningSnack => _getText('morning_snack');
  String get lunch => _getText('lunch');
  String get afternoonTea => _getText('afternoon_tea');
  String get dinner => _getText('dinner');
  String get lateNight => _getText('late_night');

  // 手動輸入
  String get manualInputMeal => _getText('manual_input_meal');
  String get date => _getText('date');
  String get time => _getText('time');
  String get mealName => _getText('meal_name');
  String get mealType => _getText('meal_type');
  String get foodName => _getText('food_name');
  String get weight => _getText('weight');
  String get grams => _getText('grams');
  String get addFood => _getText('add_food');
  String get searchNutrition => _getText('search_nutrition');

  // 歷史記錄
  String get historyRecords => _getText('history_records');
  String get noRecordsToday => _getText('no_records_today');
  String get noRecordsThisDate => _getText('no_records_this_date');
  String get tapToAddRecord => _getText('tap_to_add_record');

  // 分析頁面
  String get analysis => _getText('analysis');
  String get today => _getText('today');
  String get thisWeek => _getText('this_week');
  String get thisMonth => _getText('this_month');
  String get nutritionAnalysis => _getText('nutrition_analysis');
  String get healthSuggestions => _getText('health_suggestions');
  String get upgradeForAnalysis => _getText('upgrade_for_analysis');
  String get analysisFeaturesPremium => _getText('analysis_features_premium');

  // 個人頁面
  String get profile => _getText('profile');
  String get userLogin => _getText('user_login');
  String get tapToLogin => _getText('tap_to_login');
  String get achievements => _getText('achievements');
  String get viewAll => _getText('view_all');
  String get bodyData => _getText('body_data');
  String get age => _getText('age');
  String get height => _getText('height');
  String get currentWeight => _getText('current_weight');
  String get gender => _getText('gender');
  String get activityLevel => _getText('activity_level');
  String get nutritionGoals => _getText('nutrition_goals');
  String get mealReminders => _getText('meal_reminders');
  String get breakfastReminder => _getText('breakfast_reminder');
  String get lunchReminder => _getText('lunch_reminder');
  String get dinnerReminder => _getText('dinner_reminder');
  String get membershipPlan => _getText('membership_plan');
  String get appSettings => _getText('app_settings');

  // 徽章系統
  String get badges => _getText('badges');
  String get badgeOurMeeting => _getText('badge_our_meeting');
  String get badgeGoodStart => _getText('badge_good_start');
  String get badgeDifficultBeginning => _getText('badge_difficult_beginning');
  String get badgeKeepGoing => _getText('badge_keep_going');
  String get badgeLegendary => _getText('badge_legendary');
  String get badgeEpicRecorder => _getText('badge_epic_recorder');

  // 會員系統
  String get freeMember => _getText('free_member');
  String get premiumMember => _getText('premium_member');
  String get premiumPlus => _getText('premium_plus');
  String get upgrade => _getText('upgrade');
  String get upgradeNow => _getText('upgrade_now');
  String get purchaseCredits => _getText('purchase_credits');
  String get aiRecognitionRemaining => _getText('ai_recognition_remaining');
  String get times => _getText('times');

  // 設定
  String get settings => _getText('settings');
  String get language => _getText('language');
  String get darkMode => _getText('dark_mode');
  String get feedback => _getText('feedback');
  String get privacyPolicy => _getText('privacy_policy');
  String get termsOfService => _getText('terms_of_service');

  // 語言選項
  String get languageTraditionalChinese => _getText('language_traditional_chinese');
  String get languageSimplifiedChinese => _getText('language_simplified_chinese');
  String get languageEnglish => _getText('language_english');
  String get languageJapanese => _getText('language_japanese');

  // 錯誤訊息
  String get errorNetworkConnection => _getText('error_network_connection');
  String get errorAiRecognition => _getText('error_ai_recognition');
  String get errorNutritionQuery => _getText('error_nutrition_query');
  String get errorImageUpload => _getText('error_image_upload');
  String get errorQuotaExceeded => _getText('error_quota_exceeded');

  // 成功訊息
  String get successMealSaved => _getText('success_meal_saved');
  String get successMealUpdated => _getText('success_meal_updated');
  String get successMealDeleted => _getText('success_meal_deleted');
  String get successSettingsSaved => _getText('success_settings_saved');

  /// 獲取本地化文字
  String _getText(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['zh']?[key] ?? 
           key;
  }

  /// 本地化文字數據
  static const Map<String, Map<String, String>> _localizedValues = {
    'zh': {
      // 通用
      'app_name': 'Fooda',
      'ok': '確定',
      'cancel': '取消',
      'save': '保存',
      'delete': '刪除',
      'edit': '編輯',
      'confirm': '確認',
      'loading': '載入中...',
      'error': '錯誤',
      'success': '成功',
      'retry': '重試',
      'close': '關閉',
      'back': '返回',
      'next': '下一步',
      'previous': '上一步',
      'done': '完成',
      'skip': '跳過',

      // 底部導航
      'nav_home': '首頁',
      'nav_history': '歷史記錄',
      'nav_analysis': '分析',
      'nav_profile': '個人',

      // 首頁
      'today_nutrition': '今日營養攝取',
      'calorie_goal': '目標',
      'calories': '熱量',
      'carbs': '碳水',
      'protein': '蛋白質',
      'fat': '脂肪',
      'sodium': '鈉',
      'fiber': '膳食纖維',
      'activity': '活動',
      'add_meal': '添加餐點',
      'consecutive_days': '連續記錄',

      // 記錄方式
      'select_record_method': '選擇記錄方式',
      'ai_smart_camera': 'AI 智能拍照',
      'ai_smart_camera_desc': '拍照後自動識別食物和營養',
      'manual_input': '手動輸入',
      'manual_input_desc': '手動輸入食物資訊，支援基礎營養查詢',
      'ai_smart_upload': 'AI 智能上傳',
      'ai_smart_upload_desc': '上傳照片後自動識別食物和營養',
      'ai_quota_remaining': 'AI識別剩餘',
      'upgrade_to_unlock': '升級至訂閱版解鎖AI識別功能',

      // 餐點類型
      'breakfast': '早餐',
      'morning_snack': '上午點心',
      'lunch': '午餐',
      'afternoon_tea': '下午茶',
      'dinner': '晚餐',
      'late_night': '宵夜',

      // 手動輸入
      'manual_input_meal': '手動輸入餐點',
      'date': '日期',
      'time': '時間',
      'meal_name': '餐點名稱',
      'meal_type': '餐點類型',
      'food_name': '食物名稱',
      'weight': '重量',
      'grams': '克',
      'add_food': '添加食物',
      'search_nutrition': '查詢營養',

      // 歷史記錄
      'history_records': '歷史記錄',
      'no_records_today': '今天尚無記錄',
      'no_records_this_date': '此日期尚無餐飲記錄',
      'tap_to_add_record': '點擊右下角的 + 按鈕開始記錄',

      // 分析頁面
      'analysis': '分析',
      'today': '本日',
      'this_week': '本週',
      'this_month': '本月',
      'nutrition_analysis': '營養分析',
      'health_suggestions': '健康建議',
      'upgrade_for_analysis': '分析功能需要升級',
      'analysis_features_premium': '高級營養分析功能僅限訂閱會員使用',

      // 個人頁面
      'profile': '個人',
      'user_login': '用戶登入',
      'tap_to_login': '點擊登入',
      'achievements': '成就徽章',
      'view_all': '查看全部',
      'body_data': '身體資料',
      'age': '年齡',
      'height': '身高',
      'current_weight': '目前體重',
      'gender': '性別',
      'activity_level': '活動程度',
      'nutrition_goals': '營養目標',
      'meal_reminders': '用餐提醒',
      'breakfast_reminder': '早餐提醒',
      'lunch_reminder': '午餐提醒',
      'dinner_reminder': '晚餐提醒',
      'membership_plan': '會員方案',
      'app_settings': '應用設定',

      // 徽章系統
      'badges': '成就徽章',
      'badge_our_meeting': '我們的相遇',
      'badge_good_start': '好的開始',
      'badge_difficult_beginning': '剛開始總是困難的',
      'badge_keep_going': '繼續堅持',
      'badge_legendary': '你簡直是傳奇',
      'badge_epic_recorder': '史詩記錄者',

      // 會員系統
      'free_member': '免費會員',
      'premium_member': '訂閱會員',
      'premium_plus': '高級訂閱',
      'upgrade': '升級',
      'upgrade_now': '立即升級',
      'purchase_credits': '加購點數',
      'ai_recognition_remaining': 'AI識別剩餘',
      'times': '次',

      // 設定
      'settings': '設定',
      'language': '語言',
      'dark_mode': '深色模式',
      'feedback': '意見回饋',
      'privacy_policy': '隱私權政策',
      'terms_of_service': '服務條款',

      // 語言選項
      'language_traditional_chinese': '繁體中文',
      'language_simplified_chinese': '簡體中文',
      'language_english': 'English',
      'language_japanese': '日本語',

      // 錯誤訊息
      'error_network_connection': '網路連接錯誤',
      'error_ai_recognition': 'AI識別失敗',
      'error_nutrition_query': '營養查詢失敗',
      'error_image_upload': '圖片上傳失敗',
      'error_quota_exceeded': 'AI識別額度已用完',

      // 成功訊息
      'success_meal_saved': '餐點保存成功',
      'success_meal_updated': '餐點更新成功',
      'success_meal_deleted': '餐點刪除成功',
      'success_settings_saved': '設定保存成功',
    },
    'en': {
      // 通用
      'app_name': 'Fooda',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'confirm': 'Confirm',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'retry': 'Retry',
      'close': 'Close',
      'back': 'Back',
      'next': 'Next',
      'previous': 'Previous',
      'done': 'Done',
      'skip': 'Skip',

      // 底部導航
      'nav_home': 'Home',
      'nav_history': 'History',
      'nav_analysis': 'Analysis',
      'nav_profile': 'Profile',

      // 首頁
      'today_nutrition': 'Today\'s Nutrition',
      'calorie_goal': 'Goal',
      'calories': 'Calories',
      'carbs': 'Carbs',
      'protein': 'Protein',
      'fat': 'Fat',
      'sodium': 'Sodium',
      'fiber': 'Fiber',
      'activity': 'Activity',
      'add_meal': 'Add Meal',
      'consecutive_days': 'Streak',

      // 其他英文翻譯...
    },
    // 其他語言...
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en', 'ja'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}