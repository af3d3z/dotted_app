import 'package:dotted_app/custom/login_provider_btn.dart';
import 'package:dotted_app/screens/google_signin.dart';
import 'package:flutter/material.dart';
import 'package:dotted_app/custom/google_sign_in.dart';
import 'package:dotted_app/custom/button.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String err = "";

  @override
  void initState() {
    super.initState();

    // Setup animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -100,
      end: 200,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned(
                top: _animation.value,
                left: MediaQuery.of(context).size.width / 2 - 25,
                child: Icon(Icons.water_drop, color: Colors.black, size: 50),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Dotted",
                      style: GoogleFonts.robotoMono(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8), // spacing between the two texts
                    Text(
                      "Where the dots make up your net.",
                      style: GoogleFonts.roboto(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80), // <- Adjust here!
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(err, style: TextStyle(color: Colors.red)),
                      ProviderLoginBtn(
                        text: "Sign in",
                        img: Image.asset('assets/google.png'),
                        onPressed: () async {
                          try {
                            final user =
                                await GoogleAuthService().signInWithGoogle();
                            print(user.toString());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CompleteProfilePage(
                                      email: user.user!.email!,
                                    ),
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              err = e.toString();
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12),
                      DottedMainBtn(
                        text: "Login",
                        onPressed: () {
                          Navigator.pushNamed(context, 'login_screen');
                        },
                      ),
                      SizedBox(height: 12),
                      DottedMainBtn(
                        text: "Register",
                        onPressed: () {
                          Navigator.pushNamed(context, 'registration_screen');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
