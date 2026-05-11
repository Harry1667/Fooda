import 'package:flutter/material.dart';
import 'text_colors.dart';

/// 應用主題配置
/// 對應 PHP 版本的 CSS 樣式系統
class AppTheme {
  // 主要顏色 - Professional Royal Blue & Slate
  static const Color primaryColor = Color(0xFF2563EB); // Royal Blue 600
  static const Color secondaryColor = Color(0xFF10B981); // Emerald 500
  static const Color accentColor = Color(0xFF8B5CF6); // Violet 500
  
  // 營養素顏色 - 對應 PHP 版本的營養素顏色
  static const Color carbsColor = Color(0xFF3B82F6); // Blue 500
  static const Color proteinColor = Color(0xFFEF4444); // Red 500
  static const Color fatColor = Color(0xFFF97316); // Orange 500
  static const Color sodiumColor = Color(0xFF8B5CF6); // Violet 500
  static const Color fiberColor = Color(0xFFEC4899); // Pink 500
  static const Color caloriesColor = Color(0xFF10B981); // Emerald 500
  
  // 灰階顏色 - Slate (Cool Grey) for professional look
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);
  
  // 狀態顏色
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFDC2626);
  
  // 營養素顏色
  static const Color macroCarbs = Color(0xFF3B82F6);    // 碳水 - 藍色
  static const Color macroProtein = Color(0xFFEF4444);  // 蛋白質 - 紅色
  static const Color macroFat = Color(0xFFF97316);      // 脂肪 - 橘色
  static const Color macroSodium = Color(0xFF8B5CF6);   // 鈉 - 紫色
  static const Color macroFiber = Color(0xFFEC4899);    // 纖維 - 粉色
  static const Color macroCalories = Color(0xFF10B981); // 熱量 - 綠色
  static const Color infoColor = Color(0xFF3B82F6);

  // Semantic Colors
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumGoldDark = Color(0xFFDAA520);
  
  // Alert Colors for Analysis
  static const Color alertSuccess = Color(0xFF22C55E);
  static const Color alertWarning = Color(0xFFF59E0B);
  static const Color alertDanger = Color(0xFFEF4444);
  static const Color alertInfo = Color(0xFF3B82F6);
  
  /// 淺色主題
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // 顏色方案
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        background: grey50,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: grey900,
        onBackground: grey900,
        onError: Colors.white,
      ),
      
      // 應用欄主題
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: grey900,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: grey900,
        ),
      ),
      
      // 底部導航欄主題
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: grey400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // 卡片主題
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // 按鈕主題
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // 文字按鈕主題
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // 邊框按鈕主題
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // 輸入框主題
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: grey400),
      ),
      
      // 文字主題
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: grey900,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: grey900,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: grey900,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: grey900,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: grey900,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: grey900,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: grey900,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: grey700,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: grey500,
        ),
      ),
    );
  }
  
  /// 深色主題 - Lively Dark Mode
  static ThemeData get darkTheme {
    // New Palette
    const background = Color(0xFF0F172A); // Deep Midnight Slate
    const surface = Color(0xFF1E293B); // Lighter Slate
    const primary = Color(0xFF3B82F6); // Vibrant Blue
    const onSurface = Color(0xFFF8FAFC); // Off-White
    const secondaryText = Color(0xFF94A3B8); // Cool Grey

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // 顏色方案 - Lively Midnight
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondaryColor,
        surface: surface,
        background: background,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
        onSurfaceVariant: secondaryText,
        onBackground: onSurface,
        onError: Colors.white,
      ),
      
      scaffoldBackgroundColor: background,
      
      // 應用欄主題
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // 底部導航欄主題
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8, // Added elevation for separation
      ),
      
      // 卡片主題
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4, // Slight elevation for depth
        shadowColor: const Color(0xFF000000).withOpacity(0.3), // Darker shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.05), // Subtle border
            width: 1,
          ),
        ),
      ),
      
      // 按鈕主題
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primary.withOpacity(0.4), // Colored shadow for glow effect
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // 文字按鈕主題
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // 邊框按鈕主題
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // 輸入框主題
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: secondaryText),
      ),
      
      // 文字主題
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: secondaryText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: secondaryText,
        ),
      ),
    );
  }
}

/// 自定義顏色擴展
extension AppColors on ColorScheme {
  Color get carbsColor => AppTheme.carbsColor;
  Color get proteinColor => AppTheme.proteinColor;
  Color get fatColor => AppTheme.fatColor;
  Color get sodiumColor => AppTheme.sodiumColor;
  Color get fiberColor => AppTheme.fiberColor;
  Color get caloriesColor => AppTheme.caloriesColor;
  Color get successColor => AppTheme.successColor;
  Color get warningColor => AppTheme.warningColor;
  Color get infoColor => AppTheme.infoColor;
}