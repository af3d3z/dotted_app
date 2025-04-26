import 'package:dotted_app/screens/homescreen.dart';
import 'package:dotted_app/screens/login.dart';
import 'package:dotted_app/screens/register.dart';
import 'package:dotted_app/screens/splashscreen.dart';
import 'package:dotted_app/screens/welcomescreen.dart';
import 'package:dotted_app/custom/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      initialRoute: 'splash_screen',
      home: AuthWrapper(),
      routes: {
        'splash_screen': (context) => SplashScreen(),
        'welcome_screen': (context) => WelcomeScreen(),
        'registration_screen': (context) => Register(),
        'login_screen': (context) => Login(),
        'home_screen': (context) => Homescreen(),
      },
    );
  }
}
