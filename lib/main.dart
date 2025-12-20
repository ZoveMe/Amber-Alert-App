import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'screens/home.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// REQUIRED – background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

/// Create Android notification channel
Future<void> _setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'amber_alerts',
    'Amber Alerts',
    description: 'Critical missing person alerts',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

/// Init local notifications
Future<void> _initLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

/// Foreground notifications
void _listenForForegroundMessages() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title ?? 'Amber Alert',
      notification.body ?? 'Missing person alert',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'amber_alerts',
          'Amber Alerts',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  });
}

/// Request permission + topics
Future<void> _initFCM() async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final token = await messaging.getToken();
  debugPrint('📱 FCM TOKEN: $token');

  await messaging.subscribeToTopic('alerts_all');
  await messaging.subscribeToTopic('alerts_high');
  await messaging.subscribeToTopic('alerts_medium');
  await messaging.subscribeToTopic('alerts_low');

  debugPrint('✅ Subscribed to FCM topics');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  await _initLocalNotifications();
  await _setupNotificationChannel();
  _listenForForegroundMessages();
  await _initFCM();

  await Hive.initFlutter();
  await Hive.openBox('alertsCache');

  runApp(const AmberApp());
}

class AmberApp extends StatelessWidget {
  const AmberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amber Alert Macedonia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB71C1C),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
