import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // Handle background messages
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (details) async {
        // Handle notification tap
      },
    );

    // Configure FCM
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'loyalty_cards_channel',
      'Loyalty Cards',
      importance: Importance.high,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    await showNotification(
      message.notification?.title ?? '',
      message.notification?.body ?? '',
    );
  }

  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'loyalty_cards_channel',
      'Loyalty Cards',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }
}
