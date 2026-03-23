import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  // ── Keep existing methods above ────────────────────────────────

  static Future<void> scheduleVaccineReminder({
    required int id,
    required String childName,
    required String vaccineName,
    required DateTime scheduledDate,
  }) async {
    // 7 days before
    await _scheduleNotification(
      id: id * 10 + 1,
      title: '💉 Upcoming Vaccine',
      body: '$vaccineName due in 7 days for $childName',
      when: scheduledDate.subtract(const Duration(days: 7)),
    );
    // 1 day before
    await _scheduleNotification(
      id: id * 10 + 2,
      title: '⚠️ Vaccine Tomorrow',
      body: '$vaccineName due TOMORROW for $childName',
      when: scheduledDate.subtract(const Duration(days: 1)),
    );
    // Day of
    await _scheduleNotification(
      id: id * 10 + 3,
      title: '🔔 Vaccine Due Today',
      body: '$childName\'s $vaccineName is due TODAY',
      when: scheduledDate,
    );
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if (when.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      const NotificationDetails(
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