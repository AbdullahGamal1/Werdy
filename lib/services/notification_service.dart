import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDailyNotification(
    int id,
    String title,
    String body,
    TimeOfDay time,
  ) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Channel for daily Quran and Adhkar reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Schedule notification at a specific time (not daily)
  Future<void> scheduleNotificationAtTime(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Reminders',
          channelDescription: 'Channel for prayer and goal reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'general',
          'General',
          channelDescription: 'General notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> scheduleWeeklyNotification(
    int id,
    String title,
    String body,
    int weekday, // 1 = Monday, ..., 7 = Sunday (DateTime standard)
    TimeOfDay time,
  ) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Initial check: if today is the target day and time hasn't passed, good.
    // If time passed or wrong day, find next occurrence.
    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      if (scheduledDate.weekday == weekday &&
          scheduledDate.hour == time.hour &&
          scheduledDate.minute == time.minute) {
        // Reset time part if it drifted (unlikely with add days(1) but safe)
        scheduledDate = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          time.hour,
          time.minute,
        );
        break;
      }
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_reminders',
          'Weekly Reminders',
          channelDescription: 'Weekly reminders for Surah Al-Kahf etc.',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> scheduleSmartReminders() async {
    // 1. Al-Kahf on Friday Morning (9:00 AM)
    // DateTime.friday = 5
    await scheduleWeeklyNotification(
      1001,
      'جمعة مباركة',
      'لا تنس قراءة سورة الكهف اليوم لنور ما بين الجمعتين',
      DateTime.friday,
      const TimeOfDay(hour: 9, minute: 0),
    );

    // 2. Al-Mulk Daily Night (10:00 PM)
    await scheduleDailyNotification(
      1002,
      'المنجية من عذاب القبر',
      'حان وقت قراءة سورة الملك، حصن نفسك قبل النوم',
      const TimeOfDay(hour: 22, minute: 0),
    );

    // 3. Morning Adhkar (After Fajr - roughly 5:30 AM fixed for now)
    await scheduleDailyNotification(
      1003,
      'أذكار الصباح',
      'ابدأ يومك بذكر الله',
      const TimeOfDay(hour: 5, minute: 30),
    );

    // 4. Evening Adhkar (After Asr/Maghrib - roughly 5:00 PM)
    await scheduleDailyNotification(
      1004,
      'أذكار المساء',
      'أمسينا وأمسى الملك لله',
      const TimeOfDay(hour: 17, minute: 0),
    );
  }
}
