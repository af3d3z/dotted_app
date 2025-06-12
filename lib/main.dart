import 'package:dotted_app/screens/chat_screen.dart';
import 'package:dotted_app/screens/edit_screen.dart';
import 'package:dotted_app/screens/login_screen.dart';
import 'package:dotted_app/screens/register_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dotted_app/screens/splash_screen.dart';
import 'package:dotted_app/custom/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// manages messages when the app is in the background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) {
    flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'chat_channel_id', 'Chat notifications',
                channelDescription: 'Notifications from chat messages',
                icon: '@mipmap/ic_launcher')));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // asks for notifications permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // sets the notification settings
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
          'chat_channel_id', 'Chat Notifications',
          description: 'Notifications from chat messages',
          importance: Importance.max));

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'chat_channel_id', 'Chat Notifications',
                channelDescription: 'Notifications from chat messages',
                icon: '@mipmap/ic_launcher')));
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // common routes within the app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthWrapper(),
      routes: {
        'splash_screen': (context) => SplashScreen(),
        'registration_screen': (context) => Register(),
        'login_screen': (context) => Login(),
        'home_screen': (context) => HomeScreen(),
        'chat_screen': (context) => ChatScreen(),
        'edit_screen': (context) => EditScreen()
      },
    );
  }
}
