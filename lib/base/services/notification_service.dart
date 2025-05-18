import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  // static final FlutterLocalNotificationsPlugin _plugin =
  // FlutterLocalNotificationsPlugin();
  //
  // static Future<void> initialize() async {
  //   const AndroidInitializationSettings androidSettings =
  //   AndroidInitializationSettings('@mipmap/ic_launcher');
  //
  //   const InitializationSettings initSettings =
  //   InitializationSettings(android: androidSettings);
  //
  //   await _plugin.initialize(initSettings);
  //
  //   await _requestPermission();
  // }
  //
  // static Future<void> _requestPermission() async {
  //   if (Platform.isAndroid) {
  //     final status = await Permission.notification.status;
  //     if (!status.isGranted) {
  //       final result = await Permission.notification.request();
  //       debugPrint('Android notification permission: $result');
  //     }
  //   } else if (Platform.isIOS) {
  //     final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
  //     final isGranted = await iosPlugin?.requestPermissions(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //     );
  //     debugPrint('iOS permission granted: $isGranted');
  //   }
  // }
  //
  // static Future<void> showNotification({
  //   required int id,
  //   required String title,
  //   required String body,
  // }) async {
  //   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  //     'default_channel_id',
  //     'General Notifications',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //
  //   const NotificationDetails platformDetails =
  //   NotificationDetails(android: androidDetails);
  //
  //   await _plugin.show(id, title, body, platformDetails);
  // }
}
