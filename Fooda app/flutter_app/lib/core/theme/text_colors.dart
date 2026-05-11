import 'package:flutter/material.dart';

/// 統一的文字顏色系統
/// 根據主題模式提供適當的文字顏色
class AppTextColors {
  /// 主要文字顏色 (標題、重要內容)
  static Color primary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.white
        : Colors.black87;
  }

  /// 次要文字顏色 (說明文字、輔助信息)
  static Color secondary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.grey[300]!
        : Colors.grey[700]!;
  }

  /// 提示文字顏色 (placeholder、hint)
  static Color hint(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.grey[500]!
        : Colors.grey[600]!;
  }

  /// 禁用文字顏色
  static Color disabled(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.grey[600]!
        : Colors.grey[400]!;
  }

  /// 反色文字 (在有色背景上的文字)
  static Color onPrimary(BuildContext context) {
    return Colors.white;
  }

  /// 反色文字 (在次要背景上的文字)
  static Color onSecondary(BuildContext context) {
    return Colors.white;
  }

  /// 主要按鈕上的文字顏色
  static Color onPrimaryText(BuildContext context) {
    return Colors.white;
  }

  /// 錯誤文字顏色
  static Color error(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.red[300]!
        : Colors.red[700]!;
  }

  /// 成功文字顏色
  static Color success(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.green[300]!
        : Colors.green[700]!;
  }

  /// 警告文字顏色
  static Color warning(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.orange[300]!
        : Colors.orange[700]!;
  }

  /// 信息文字顏色
  static Color info(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.blue[300]!
        : Colors.blue[700]!;
  }

  /// 卡片上的文字顏色
  static Color onCard(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.white
        : Colors.black87;
  }

  /// 表面上的文字顏色 (AppBar, BottomNavigationBar等)
  static Color onSurface(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// 背景上的文字顏色
  static Color onBackground(BuildContext context) {
    return Theme.of(context).colorScheme.onBackground;
  }
}

/// 擴展方法讓使用更方便
extension BuildContextTextColors on BuildContext {
  /// 主要文字顏色
  Color get primaryText => AppTextColors.primary(this);
  
  /// 次要文字顏色
  Color get secondaryText => AppTextColors.secondary(this);
  
  /// 提示文字顏色
  Color get hintText => AppTextColors.hint(this);
  
  /// 禁用文字顏色
  Color get disabledText => AppTextColors.disabled(this);
  
  /// 錯誤文字顏色
  Color get errorText => AppTextColors.error(this);
  
  /// 成功文字顏色
  Color get successText => AppTextColors.success(this);
  
  /// 警告文字顏色
  Color get warningText => AppTextColors.warning(this);
  
  /// 信息文字顏色
  Color get infoText => AppTextColors.info(this);
  
  /// 卡片上的文字顏色
  Color get onCardText => AppTextColors.onCard(this);
  
  /// 表面上的文字顏色
  Color get onSurfaceText => AppTextColors.onSurface(this);
  
  /// 背景上的文字顏色
  Color get onBackgroundText => AppTextColors.onBackground(this);
  
  /// 主要按鈕上的文字顏色
  Color get onPrimaryText => AppTextColors.onPrimaryText(this);
}