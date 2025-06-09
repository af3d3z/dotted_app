import 'package:dotted_app/screens/chat_screen.dart';
import 'package:dotted_app/screens/edit_screen.dart';
import 'package:dotted_app/screens/login_screen.dart';
import 'package:dotted_app/screens/register_screen.dart';
import 'package:dotted_app/custom/global.dart';
import 'package:dotted_app/screens/splash_screen.dart';
import 'package:dotted_app/custom/auth_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'home_screen',
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
