import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dotted_app/custom/button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_app/custom/global.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  File? _image;
  bool gotPhoto = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        gotPhoto = true;
      });
    }
  }

  Future<void> registerUser() async {
    bool everythingFine = false;
    // first we hash the password using sha512 <3
    var bytesToHash = utf8.encode(passController.text);
    var hashedPass = sha512.convert(bytesToHash);

    final compressedImg = await compressImage(_image);

    try {
      final response = await http.post(
        Uri.parse("${API_URL}users"),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'email': emailController.text,
          'username': usernameController.text,
          'pass': hashedPass.toString(),
          'img': compressedImg,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print(responseData.runtimeType); // Should say: _JsonMap
        print(responseData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(responseData['msg'])));
        everythingFine = true;
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }

    if (everythingFine) {
      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passController.text,
        );
        if (newUser.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
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
                  onPressed: () {
                    Navigator.pushNamed(context, 'splash_screen');
                  },
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
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  focusColor: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  focusColor: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  focusColor: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Visibility(
                visible: gotPhoto,
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.black),
                    SizedBox(width: 5),
                    Text("Image uploaded!"),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ),
              const SizedBox(height: 10),
              DottedMainBtn(
                text: "Select your profile picture",
                onPressed: _pickImage,
              ),
              const SizedBox(height: 30),
              DottedMainBtn(
                onPressed: () async {
                  await registerUser();
                },
                text: "Register",
              ),
              SizedBox(height: 12),
              DottedMainBtn(
                onPressed: () {
                  Navigator.pushNamed(context, 'login_screen');
                },
                text: "Already have an account?",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
