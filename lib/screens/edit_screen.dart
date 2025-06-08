import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_app/custom/button.dart';
import 'package:dotted_app/models/user.dart';
import 'package:dotted_app/services/post_service.dart';
import 'package:dotted_app/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreen();
}

class _EditScreen extends State<EditScreen> {
  final UserService _userService = UserService();
  bool isLoading = false;
  late User user;
  Uint8List? img;
  String? usernameTextField;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
    });
  }

  void _loadUserInfo() async {
    final result = await _userService.loadUserInfo(context);

    if (result == null) {
      return;
    }

    setState(() {
      user = result;
      img = user.img;
      usernameTextField = user.username;
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    final bytes = await pickedFile!.readAsBytes();

    setState(() async {
      img = bytes;
      user.img = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: BackButton(),
              ),
              Center(
                child: Text(
                  "Edit profile",
                  style: GoogleFonts.robotoMono(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: (user.img != null)
                    ? CircleAvatar(
                        radius: 80,
                        backgroundImage: MemoryImage(
                          PostService.getImageBytes(img),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 60,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white60,
                        ),
                      ),
              ),
              SizedBox(
                height: 20,
              ),
              DottedMainBtn(text: "Change image", onPressed: _pickImage),
              const SizedBox(
                width: 150,
              ),
              TextField(
                  decoration: InputDecoration(
                    labelText: usernameTextField,
                    border: const OutlineInputBorder(),
                    focusColor: Colors.black,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    usernameTextField = value;
                  })
            ],
          ),
        )),
      );
    }
  }
}
