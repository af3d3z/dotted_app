import 'dart:convert';
import 'dart:io';

import 'package:dotted_app/custom/button.dart';
import 'package:dotted_app/custom/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CompleteProfilePage extends StatefulWidget {
  final String email;
  const CompleteProfilePage({super.key, required this.email});

  @override
  _CompleteProfilePage createState() => _CompleteProfilePage();
}

class _CompleteProfilePage extends State<CompleteProfilePage> {
  String username = "";
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

  Future<void> completeProfile(String email) async {
    Uri apiUrl = Uri.parse("${API_URL}api/store-user-data");
    String? uid = user?.uid;
    String? idToken = await user?.getIdToken();
    final compressedImg = await compressImage(_image);

    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken'
        },
        body: jsonEncode(<String, dynamic>{
          'id': uid,
          'email': email,
          'username': username,
          'img': compressedImg,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(responseData['msg'])));
        Navigator.pushNamed(context, 'home_screen');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("An error ocurred: ${jsonDecode(response.body)['msg']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile completion failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const Text(
                "Complete your profile",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 40),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  focusColor: Colors.black,
                ),
                keyboardType: TextInputType.name,
                onChanged: (value) {
                  username = value;
                },
              ),
              SizedBox(height: 20),
              Visibility(
                visible: gotPhoto,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: Colors.black),
                    SizedBox(width: 5),
                    Text("Image uploaded!"),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              DottedMainBtn(
                text: "Select your profile picture",
                onPressed: _pickImage,
              ),
              const SizedBox(height: 20),
              DottedMainBtn(
                text: "Save",
                onPressed: () {
                  completeProfile(widget.email);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
