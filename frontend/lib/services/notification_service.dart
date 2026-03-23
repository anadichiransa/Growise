import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<void> scheduleVaccineReminder({
    required int id,
    required String childName,
    required String vaccineName,
    required DateTime scheduledDate,
  }) async {
    await _scheduleAt(
      id: id * 10 + 1,
      title: 'Upcoming Vaccine',
      body: ' is due in 7 days for ',
      scheduledDate: scheduledDate.subtract(const Duration(days: 7)),
    );
    await _scheduleAt(
      id: id * 10 + 2,
      title: 'Vaccine Tomorrow',
      body: ' is due TOMORROW for ',
      scheduledDate: scheduledDate.subtract(const Duration(days: 1)),
    );
    await _scheduleAt(
      id: id * 10 + 3,
      title: 'Vaccine Due Today',
      body: '\'s  is due TODAY',
      scheduledDate: scheduledDate,
    );
  }

  static Future<void> _scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'vaccine_reminders',
          'Vaccine Reminders',
          channelDescription: 'Reminders for upcoming vaccinations',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF00E5CC),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
