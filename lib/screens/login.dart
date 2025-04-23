import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_app/custom/button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "";
  String password = "";
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: BackButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'splash_screen');
                  },
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Login",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 40),
              ),
              const SizedBox(height: 40),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email/Username',
                  border: OutlineInputBorder(),
                  focusColor: Colors.black,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  focusColor: Colors.black,
                ),
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
              ),
              const SizedBox(height: 30),
              DottedMainBtn(
                text: "Login",
                onPressed: () async {
                  try {
                    final userCredential = await _auth
                        .signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                    final user = userCredential.user;

                    if (user != null) {
                      final idToken = await user.getIdToken(true);
                      String token = "Bearer $idToken";
                      var apiUrl = Uri.parse(
                        "http://localhost:8080/store-user-data",
                      );

                      final response = await http.get(
                        apiUrl,
                        headers: {'Authorization': token},
                      );

                      print(response.body);
                      Navigator.pushNamed(context, 'home_screen');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login failed: ${e.toString()}')),
                    );
                  }
                },
              ),
              SizedBox(height: 5),
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
    );
  }
}
