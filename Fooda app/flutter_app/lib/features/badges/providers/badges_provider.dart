import 'package:flutter/foundation.dart';

/// 徽章系統提供者
class BadgesProvider extends ChangeNotifier {
  int _consecutiveDays = 0;
  final List<String> _unlockedBadges = [];

  int get consecutiveDays => _consecutiveDays;
  List<String> get unlockedBadges => _unlockedBadges;

  /// 更新連續記錄天數
  void updateConsecutiveDays(int days) {
    _consecutiveDays = days;
    _checkBadges();
    notifyListeners();
  }

  /// 檢查並解鎖徽章
  void _checkBadges() {
    if (_consecutiveDays >= 1 && !_unlockedBadges.contains('first_meal')) {
      _unlockedBadges.add('first_meal');
    }
    if (_consecutiveDays >= 3 && !_unlockedBadges.contains('three_days')) {
      _unlockedBadges.add('three_days');
    }
    if (_consecutiveDays >= 7 && !_unlockedBadges.contains('one_week')) {
      _unlockedBadges.add('one_week');
    }
    if (_consecutiveDays >= 30 && !_unlockedBadges.contains('one_month')) {
      _unlockedBadges.add('one_month');
    }
    if (_consecutiveDays >= 90 && !_unlockedBadges.contains('three_months')) {
      _unlockedBadges.add('three_months');
    }
    if (_consecutiveDays >= 365 && !_unlockedBadges.contains('one_year')) {
      _unlockedBadges.add('one_year');
    }
  }

  /// 重置徽章
  void resetBadges() {
    _consecutiveDays = 0;
    _unlockedBadges.clear();
    notifyListeners();
  }
}
