import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  final AwesomeNotifications _notifications = AwesomeNotifications();

  Future<void> initialize() async {
    await _notifications.initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'medication_channel',
          channelName: 'Medication Reminders',
          channelDescription: 'Channel for medication reminder notifications',
          importance: NotificationImportance.High,
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          playSound: true,
          enableVibration: true,
        )
      ],
    );

    await _requestPermission();
  }

  Future<void> _requestPermission() async {
    await _notifications.requestPermissionToSendNotifications();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    await _notifications.createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'medication_channel',
        title: title,
        body: body,
      ),
      schedule: NotificationCalendar(
        hour: time.hour,
        minute: time.minute,
        repeats: true,
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
