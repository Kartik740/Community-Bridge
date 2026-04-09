// lib/core/services/notification_service.dart
// Handles FCM registration, foreground notifications, and tap-to-navigate.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  // Navigation callback — set by the app to handle notification taps.
  static void Function(String taskId)? onTaskNotificationTap;

  /// Initialises notifications — call this after Firebase.initializeApp().
  static Future<void> init() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'community_bridge_tasks',
      'Task Notifications',
      description: 'Notifications for new task assignments',
      importance: Importance.high,
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);

    // Initialise local notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Notification tap when app is in background (but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from a terminated state via notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _routeFromMessage(initial);
    }
  }

  /// Saves the FCM token to Firestore for the given volunteer UID.
  static Future<void> saveToken(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('volunteers')
            .doc(uid)
            .update({'fcmToken': token});
        debugPrint('[FCM] Token saved for $uid');
      }
    } catch (e) {
      debugPrint('[FCM] Error saving token: $e');
    }
  }

  // ─── Private Handlers ──────────────────────────────────────────────────────

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          'community_bridge_tasks',
          'Task Notifications',
          channelDescription: 'Notifications for new task assignments',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['taskId'],
    );
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    _routeFromMessage(message);
  }

  static void _onNotificationTap(NotificationResponse response) {
    final taskId = response.payload;
    if (taskId != null && taskId.isNotEmpty && onTaskNotificationTap != null) {
      onTaskNotificationTap!(taskId);
    }
  }

  static void _routeFromMessage(RemoteMessage message) {
    final taskId = message.data['taskId'] as String?;
    if (taskId != null && taskId.isNotEmpty && onTaskNotificationTap != null) {
      onTaskNotificationTap!(taskId);
    }
  }
}
