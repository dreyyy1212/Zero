import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotiHandler {
  NotiHandler._();

  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> requestPermission() async {
    await Permission.notification.request();
  }

  static void configNotificationSetting(BuildContext context) async {
    tz.initializeTimeZones();
    if (await Permission.notification.isGranted) {
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        // onDidReceiveLocalNotification:
        //     (int id, String? title, String? body, String? payload) async {
        //   didReceiveLocalNotificationStream.add(
        //     ReceivedNotification(
        //       id: id,
        //       title: title,
        //       body: body,
        //       payload: payload,
        //     ),
        //   );
        // },
        // notificationCategories: darwinNotificationCategories,
      );

      const initializationSettings = InitializationSettings(
          android: AndroidInitializationSettings('app_icon'),
          iOS: initializationSettingsDarwin);
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );
      _scheduleWeeklySundayNotification(); 
    }
  
  }

  static Future<void> _scheduleWeeklySundayNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Remember to sync',
        'Remember to sync if you did not sync this week',
        _nextInstanceOfMondayTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('zero_app_weekly_notification_id',
              'zero_app_weekly_notification_name',
              channelDescription: 'zero_app_weekly_notification_des'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
            
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  static tz.TZDateTime _nextInstanceOfMondayTenAM() {
    tz.TZDateTime scheduledDate = _nextInstanceOfTenAM();
    while (scheduledDate.weekday != DateTime.sunday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
