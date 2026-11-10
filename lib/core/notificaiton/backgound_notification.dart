import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const notificationChannelId = 'general_channel_v7';
const foregroundNotificationId = 888;
const alertNotificationId = 889;

final FlutterLocalNotificationsPlugin localPlugin =
FlutterLocalNotificationsPlugin();

/// ----------------------------------------------------
/// BACKGROUND SERVICE ENTRY POINT
/// ----------------------------------------------------
@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin localPlugin =
  FlutterLocalNotificationsPlugin();

  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  await localPlugin.initialize(settings: initSettings);

  Timer? timer;

  /// STOP EVENT
  service.on("stop").listen((event) {
    print("Stopping background service");

    timer?.cancel();
    service.stopSelf();
  });

  /// PERIODIC TASK
  timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
    print("Background service tick");

    if (service is AndroidServiceInstance) {
      final isForeground = await service.isForegroundService();

      if (!isForeground) return;

      await localPlugin.show(
        id:  alertNotificationId,
       title:  'COOL SERVICE',
        body: 'Running at ${DateTime.now()}',
        notificationDetails:  NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            'Background Service',
            importance: Importance.high,
            priority: Priority.high,
            playSound: false,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });
}

/// ----------------------------------------------------
/// IOS BACKGROUND HANDLER
/// ----------------------------------------------------
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

/// ----------------------------------------------------
/// SERVICE HELPER
/// ----------------------------------------------------
class BackgroundNotificationHelper {
  static final FlutterBackgroundService _service =
  FlutterBackgroundService();

  static Future<void> initializeService() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await localPlugin.initialize( settings: initSettings);

    const channel = AndroidNotificationChannel(
      notificationChannelId,
      'Background Service',
      description: 'Service notifications',
      importance: Importance.high,
    );

    await localPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'Service Running',
        initialNotificationContent: 'Background service active',
        foregroundServiceNotificationId: foregroundNotificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  /// START SERVICE
  static Future<void> startService() async {
    if (!(await _service.isRunning())) {
      await _service.startService();
      print("Background service started");
    }
  }

  /// STOP SERVICE
  static Future<void> stopService() async {
    if (await _service.isRunning()) {
      _service.invoke("stop");
      print("Background service stopped");
    }
  }
}