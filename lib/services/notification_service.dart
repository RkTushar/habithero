import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  static Future showDailyReminder({
    required int id,
    required String title,
    required String body,
    required Time time,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _scheduleDaily(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'daily_channel', 'Daily Notifications',
            importance: Importance.max, priority: Priority.high),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _scheduleDaily(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    return scheduled.isBefore(now)
        ? scheduled.add(Duration(days: 1))
        : scheduled;
  }
}
