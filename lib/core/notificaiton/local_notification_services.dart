import 'dart:async';
import 'dart:ui';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../session/session_manager.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Payload: ${response.payload}');
      },
    );
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'general_channel_v2',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.max,
      playSound: true,
      priority: Priority.high,
      // sound: RawResourceAndroidNotificationSound('notification'),
      sound: RawResourceAndroidNotificationSound('bell_notification'),
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
       id: 1,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: 'sample_payload',
    );
  }

  static Future<void> showNotificationBigSize(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'general_channel_v26',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.max,
      playSound: true,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        'This is a long notification message that expands.',
        contentTitle: 'New Message',
        summaryText: 'Chat App',
      ),
      // sound: RawResourceAndroidNotificationSound('notification'),
      sound: RawResourceAndroidNotificationSound('bell_notification'),
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 1,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: 'sample_payload',
    );
  }

  static Future<void> showNotificationBigSizeImage(String title, String body, String path) async {
    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'general_channel_v28',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.max,
      color: Color(0xFF2196F3),
      playSound: true,
      priority: Priority.high,
      styleInformation: BigPictureStyleInformation(
        FilePathAndroidBitmap(path),
        contentTitle: 'New Offer',
        summaryText: '50% Discount',
      ),
      // sound: RawResourceAndroidNotificationSound('notification'),
      sound: const RawResourceAndroidNotificationSound('bell_notification'),
    );

    NotificationDetails notificationDetails =
    NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 1,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: 'sample_payload',
    );
  }


  static Future<void> showScheduleNotification(String title, String body, {required DateTime time}) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'general_channel_v6',
      'General Notifications',
      playSound: true,
      channelDescription: 'General app notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('bell_notification'),
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(
      android: androidDetails,
    );

    try {

      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(time, tz.local);

      int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: notificationId,
        title: title,
        body:  body,
        payload: "test_payload",
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:null,
      );

      SessionManager.saveNotification(notificationId.toString(), title, time);

      print("Notification Scheduled");
    } catch (e) {
      print("Schedule Error: $e");
    }

    print("this is good452");
  }


}

