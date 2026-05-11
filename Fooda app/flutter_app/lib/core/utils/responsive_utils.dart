import 'package:flutter/material.dart';

/// 響應式設計工具類
class ResponsiveUtils {
  /// 獲取設備類型
  static DeviceType getDeviceType(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    
    // 針對 iPhone 12 (390x844) 和類似尺寸進行優化
    if (height <= 667) {
      return DeviceType.small; // iPhone SE, iPhone 8
    } else if (height <= 812) {
      return DeviceType.medium; // iPhone 12 mini, iPhone X
    } else if (height <= 896 && width <= 414) {
      return DeviceType.large; // iPhone 12 (390x844), iPhone 11
    } else {
      return DeviceType.extraLarge; // iPhone 12 Pro Max, iPad
    }
  }
  
  /// 獲取響應式間距
  static double getSpacing(BuildContext context, SpacingType type) {
    final deviceType = getDeviceType(context);
    
    switch (type) {
      case SpacingType.tiny:
        return deviceType == DeviceType.small ? 4.0 : 6.0;
      case SpacingType.small:
        return deviceType == DeviceType.small ? 8.0 : 12.0;
      case SpacingType.medium:
        return deviceType == DeviceType.small ? 16.0 : 20.0;
      case SpacingType.large:
        return deviceType == DeviceType.small ? 24.0 : 32.0;
      case SpacingType.extraLarge:
        return deviceType == DeviceType.small ? 32.0 : 48.0;
    }
  }
  
  /// 獲取響應式字體大小
  static double getFontSize(BuildContext context, FontSizeType type) {
    final deviceType = getDeviceType(context);
    final scaleFactor = _getFontScaleFactor(deviceType);
    
    switch (type) {
      case FontSizeType.small:
        return 12.0 * scaleFactor;
      case FontSizeType.body:
        return 16.0 * scaleFactor;
      case FontSizeType.subtitle:
        return 18.0 * scaleFactor;
      case FontSizeType.title:
        return 24.0 * scaleFactor;
      case FontSizeType.headline:
        return 32.0 * scaleFactor;
    }
  }
  
  /// 獲取響應式圖標大小
  static double getIconSize(BuildContext context, IconSizeType type) {
    final deviceType = getDeviceType(context);
    final scaleFactor = _getIconScaleFactor(deviceType);
    
    switch (type) {
      case IconSizeType.small:
        return 16.0 * scaleFactor;
      case IconSizeType.medium:
        return 24.0 * scaleFactor;
      case IconSizeType.large:
        return 32.0 * scaleFactor;
      case IconSizeType.extraLarge:
        return 48.0 * scaleFactor;
      case IconSizeType.huge:
        return 80.0 * scaleFactor;
    }
  }
  
  /// 獲取安全內邊距
  static EdgeInsets getSafePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.small:
        return const EdgeInsets.all(16.0);
      case DeviceType.medium:
        return const EdgeInsets.all(20.0);
      case DeviceType.large:
        return const EdgeInsets.all(24.0);
      case DeviceType.extraLarge:
        return const EdgeInsets.all(28.0);
    }
  }
  
  /// 獲取按鈕高度
  static double getButtonHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.small:
        return 44.0;
      case DeviceType.medium:
        return 48.0;
      case DeviceType.large:
        return 52.0;
      case DeviceType.extraLarge:
        return 56.0;
    }
  }
  
  static double _getFontScaleFactor(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.small:
        return 0.85; // 更小的縮放以適應小螢幕
      case DeviceType.medium:
        return 0.9; // 稍微縮小以避免文字截斷
      case DeviceType.large:
        return 0.95; // iPhone 12 優化
      case DeviceType.extraLarge:
        return 1.0;
    }
  }
  
  static double _getIconScaleFactor(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.small:
        return 0.8;
      case DeviceType.medium:
        return 0.9;
      case DeviceType.large:
        return 1.0;
      case DeviceType.extraLarge:
        return 1.1;
    }
  }
}

enum DeviceType { small, medium, large, extraLarge }
enum SpacingType { tiny, small, medium, large, extraLarge }
enum FontSizeType { small, body, subtitle, title, headline }
enum IconSizeType { small, medium, large, extraLarge, huge }