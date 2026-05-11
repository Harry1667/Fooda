import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const ios = DarwinInitializationSettings();
    const initSettings = InitializationSettings(iOS: ios, android: null);
    await _plugin.initialize(initSettings);

    // iOS 請求權限
    await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 設定時區
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // ignore
    }

    _initialized = true;
  }

  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await init();
    }

    final details = NotificationDetails(
      iOS: const DarwinNotificationDetails(),
      android: null,
    );

    final now = tz.TZDateTime.now(tz.local);
    var firstTrigger = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (firstTrigger.isBefore(now)) {
      firstTrigger = firstTrigger.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      firstTrigger,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleAllMeals({
    required String breakfastTime,
    required String lunchTime,
    required String dinnerTime,
    required bool enabled,
  }) async {
    if (!_initialized) {
      await init();
    }
    // 固定 ID：早餐 1001、午餐 1002、晚餐 1003
    await cancel(1001);
    await cancel(1002);
    await cancel(1003);

    if (!enabled) return;

    final b = _parseTime(breakfastTime);
    final l = _parseTime(lunchTime);
    final d = _parseTime(dinnerTime);

    // 使用多語言系統，但提供中文作為默認值
    await scheduleDaily(
      id: 1001, 
      hour: b.$1, 
      minute: b.$2, 
      title: '早餐提醒', // 默認中文，實際顯示會根據系統語言
      body: '是時候吃早餐了，保持均衡營養哦！'
    );
    await scheduleDaily(
      id: 1002, 
      hour: l.$1, 
      minute: l.$2, 
      title: '午餐提醒',
      body: '該吃午餐囉，記得補充蛋白質與蔬菜！'
    );
    await scheduleDaily(
      id: 1003, 
      hour: d.$1, 
      minute: d.$2, 
      title: '晚餐提醒',
      body: '晚餐時間到了，控制總熱量更健康！'
    );
  }

  (int, int) _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 9;
    final m = int.tryParse(parts[1]) ?? 0;
    return (h, m);
  }

  Future<void> cancel(int id) async {
    if (!_initialized) {
      await init();
    }
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!_initialized) {
      await init();
    }
    await _plugin.cancelAll();
  }
}


