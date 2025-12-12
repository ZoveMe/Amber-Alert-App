import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/home.dart';

/// Background handler for Firebase Push Notifications
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('🔔 Background message received: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---- 🔥 Initialize Firebase ----
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background push notification handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ---- 🗂 Initialize Hive local storage ----
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

      // ---- APP THEME ----
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF570F0F), // deep amber/red
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      // ---- MAIN SCREEN ----
      home: const HomeScreen(),
    );
  }
}
