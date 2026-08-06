import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ✅ إضافة @pragma للـ background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("📨 إشعار في الخلفية: ${message.notification?.title}");
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      // طلب الإذن
      await _fcm.requestPermission(alert: true, badge: true, sound: true);

      // إعداد الإشعارات المحلية
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      const settings = InitializationSettings(android: android, iOS: ios);
      await _local.initialize(settings);

      // استقبال الإشعارات في الخلفية
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // استقبال الإشعارات في المقدمة
      FirebaseMessaging.onMessage.listen(_showLocalNotification);

      // استقبال الإشعارات عند النقر
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint("📱 تم النقر على الإشعار: ${message.notification?.title}");
      });

      debugPrint("✅ NotificationService initialized");
    } catch (e) {
      debugPrint("⚠️ NotificationService init error: $e");
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel',
          'بيتك عندنا',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          channelShowBadge: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _local.show(
        DateTime.now().millisecond,
        message.notification?.title ?? 'إشعار جديد',
        message.notification?.body ?? '',
        details,
      );
    } catch (e) {
      debugPrint("⚠️ Error showing notification: $e");
    }
  }

  // جلب التوكن
  static Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint("⚠️ Error getting token: $e");
      return null;
    }
  }
}
