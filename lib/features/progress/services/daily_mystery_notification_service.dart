import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class DailyMysteryNotificationService {
  static final _instance = FlutterLocalNotificationsPlugin();

  static FlutterLocalNotificationsPlugin get instance => _instance;

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _instance.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null) {
          // Route to daily mystery screen
        }
      },
    );
  }

  static Future<void> scheduleDailyNotifications() async {
    // Morning notification: 7:00 AM
    await _scheduleMorningNotification();
    // Evening notification: 6:00 PM (18:00)
    await _scheduleEveningNotification();
  }

  static Future<void> _scheduleMorningNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      7, // 7:00 AM
    );

    // If the time has already passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _instance.zonedSchedule(
      0,
      '📿 今日のふしぎ',
      'おはよう！今日のふしぎを引こう',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_mystery_morning',
          '今日のふしぎ（朝）',
          channelDescription: '毎朝7時のふしぎ配信',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'daily_mystery_open',
    );
  }

  static Future<void> _scheduleEveningNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18, // 6:00 PM
    );

    // If the time has already passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _instance.zonedSchedule(
      1,
      '🎉 答えの時間',
      '今日のふしぎの答えが出ました。確認しよう！',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_mystery_evening',
          '今日のふしぎ（夜）',
          channelDescription: '毎晩18時の答え配信',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'daily_mystery_answer',
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _instance.cancelAll();
  }

  static Future<void> cancelMorningNotification() async {
    await _instance.cancel(0);
  }

  static Future<void> cancelEveningNotification() async {
    await _instance.cancel(1);
  }
}
