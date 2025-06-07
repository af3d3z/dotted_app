import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:dotted_app/custom/button.dart';
import 'package:dotted_app/custom/global.dart';
import 'package:dotted_app/screens/login_screen.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  File? _image;
  bool _gotPhoto = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _gotPhoto = true;
      });
    }
  }

  Future<void> _registerUser() async {
    try {
      // Firebase Auth registration
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception("Firebase user is null.");

      final compressedImg = await compressImage(_image);

      // Send to API
      final response = await http.post(
        Uri.parse("${API_URL}api/users"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': firebaseUser.uid,
          'email': _emailController.text.trim(),
          'username': _usernameController.text.trim(),
          'img': compressedImg,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['msg'] ?? "Registered successfully"),
          ),
        );

        _firestore.collection("users").doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      } else {
        throw Exception("API error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Registration failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

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
                  onPressed:
                      () => Navigator.pushNamed(context, 'splash_screen'),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Register",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 40),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_gotPhoto)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.verified, color: Colors.black),
                    SizedBox(width: 5),
                    Text("Image uploaded!"),
                  ],
                ),
              const SizedBox(height: 10),
              DottedMainBtn(
                text: "Select your profile picture",
                onPressed: _pickImage,
              ),
              const SizedBox(height: 30),
              DottedMainBtn(text: "Register", onPressed: _registerUser),
              const SizedBox(height: 12),
              DottedMainBtn(
                text: "Already have an account?",
                onPressed: () {
                  Navigator.pushNamed(context, 'login_screen');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
