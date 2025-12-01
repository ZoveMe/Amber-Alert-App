// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
//
// class FirebaseMsg {
//   final FirebaseMessaging msgService = FirebaseMessaging.instance;
//
//   Future<void> initFCM() async {
//     // Request notification permissions
//     await msgService.requestPermission();
//
//     // Get the device token for testing or backend use
//     final token = await msgService.getToken();
//     debugPrint("📱 FCM Token: $token");
//
//     // Listen for foreground and background messages
//     FirebaseMessaging.onMessage.listen(handleNotification);
//     FirebaseMessaging.onBackgroundMessage(handleNotification);
//   }
//
//   /// Handles notifications in foreground/background
//   static Future<void> handleNotification(RemoteMessage msg) async {
//     if (msg.notification != null) {
//       debugPrint("📩 Notification: ${msg.notification!.title}");
//       debugPrint("📝 Body: ${msg.notification!.body}");
//     }
//
//     if (msg.data.isNotEmpty) {
//       debugPrint("📦 Data: ${msg.data}");
//     }
//   }
// }
