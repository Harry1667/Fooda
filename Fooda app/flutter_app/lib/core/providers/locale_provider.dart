import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier with WidgetsBindingObserver {
  static const String _localeKey = 'selected_language';
  
  // 支援的語言
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // 英文
    Locale('zh', 'TW'), // 繁體中文
    Locale('zh', 'CN'), // 簡體中文
    Locale('ja', ''), // 日文
    Locale('ko', ''), // 韓文
  ];
  
  // 語言選項資訊
  static const Map<String, LanguageOption> languageOptions = {
    'en': LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
      locale: Locale('en', ''),
    ),
    'zh_TW': LanguageOption(
      code: 'zh_TW',
      name: 'Traditional Chinese',
      nativeName: '繁體中文',
      flag: '🇹🇼',
      locale: Locale('zh', 'TW'),
    ),
    'zh_CN': LanguageOption(
      code: 'zh_CN',
      name: 'Simplified Chinese',
      nativeName: 'Simplified Chinese',
      flag: '🇨🇳',
      locale: Locale('zh', 'CN'),
    ),
    'ja': LanguageOption(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      flag: '🇯🇵',
      locale: Locale('ja', ''),
    ),
    'ko': LanguageOption(
      code: 'ko',
      name: 'Korean',
      nativeName: '한국어',
      flag: '🇰🇷',
      locale: Locale('ko', ''),
    ),
  };
  
  Locale? _locale; // 預設為 null，表示跟隨系統
  
  Locale? get locale => _locale;
  
  String get currentLanguageCode {
    if (_locale == null) return 'system';
    
    if (_locale!.countryCode != null && _locale!.countryCode!.isNotEmpty) {
      return '${_locale!.languageCode}_${_locale!.countryCode}';
    }
    return _locale!.languageCode;
  }
  
  LanguageOption get currentLanguageOption {
    if (_locale == null) {
       // 如果是跟隨系統，我們需要獲取當前系統語言並返回對應的選項
       // 如果系統語言不支援，則返回繁體中文作為 fallback
       try {
         final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
         final supportedLocale = getSupportedLocale(systemLocale);
         
         // 查找對應的 LanguageOption
         for (final option in languageOptions.values) {
           if (option.locale.languageCode == supportedLocale.languageCode &&
               option.locale.countryCode == supportedLocale.countryCode) {
             return option;
           }
         }
       } catch (e) {
         print('🌐 [LocaleProvider] Error getting system locale option: $e');
       }
       
       return languageOptions['zh_TW']!; 
    }
    return languageOptions[currentLanguageCode] ?? languageOptions['zh_TW']!;
  }
  
  LocaleProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    print('🌐 [LocaleProvider] System locales changed: $locales');
    
    // 如果當前是跟隨系統模式 (_locale == null)，通知監聽者更新
    if (_locale == null) {
      print('🌐 [LocaleProvider] Following system, notifying listeners to update UI');
      notifyListeners();
    }
  }
  
  /// 初始化語言設定
  Future<void> initialize() async {
    // 不再從 SharedPreferences 讀取，每次啟動都跟隨系統
    _locale = null;
    
    print('🌐 [LocaleProvider] Initializing... Defaulting to system (null)');
    
    // 打印系統語言
    try {
      final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
      print('🌐 [LocaleProvider] System locales: $systemLocales');
    } catch (e) {
      print('🌐 [LocaleProvider] Could not get system locales: $e');
    }
    
    notifyListeners();
  }
  
  /// 設定語言
  Future<void> setLocale(String? languageCode) async {
    print('🌐 [LocaleProvider] setLocale called with: $languageCode');

    // 不再保存到 SharedPreferences，僅在本次 Session 有效
    if (languageCode == null) {
      _locale = null;
      print('🌐 [LocaleProvider] Cleared locale settings, now following system');
    } else {
      if (!languageOptions.containsKey(languageCode)) {
        print('🌐 [LocaleProvider] Invalid language code: $languageCode');
        return;
      }
      
      final languageOption = languageOptions[languageCode]!;
      _locale = languageOption.locale;
      print('🌐 [LocaleProvider] Set locale to: $_locale');
    }
    
    notifyListeners();
  }
  
  /// 根據 Locale 設定語言
  Future<void> setLocaleByLocale(Locale locale) async {
    String languageCode;
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      languageCode = '${locale.languageCode}_${locale.countryCode}';
    } else {
      languageCode = locale.languageCode;
    }
    
    await setLocale(languageCode);
  }
  
  /// 檢查是否支援指定語言
  bool isSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) => 
      supportedLocale.languageCode == locale.languageCode &&
      supportedLocale.countryCode == locale.countryCode
    );
  }
  
  /// 獲取系統語言對應的支援語言
  Locale getSupportedLocale(Locale? systemLocale) {
    if (systemLocale == null) return supportedLocales.first;
    
    // 完全匹配（語言碼 + 國家碼）
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode &&
          supportedLocale.countryCode == systemLocale.countryCode) {
        return supportedLocale;
      }
    }
    
    // 部分匹配（僅語言碼）
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        return supportedLocale;
      }
    }
    
    // 預設語言
    return supportedLocales.first;
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final Locale locale;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.locale,
  });
}