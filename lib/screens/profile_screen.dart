import 'dart:convert';
import 'dart:typed_data';

import 'package:dotted_app/custom/button.dart';
import 'package:dotted_app/models/user.dart';
import 'package:dotted_app/models/user_posts.dart';
import 'package:dotted_app/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  final FirebaseAuth.FirebaseAuth _auth = FirebaseAuth.FirebaseAuth.instance;
  final UserService _userService = UserService();
  bool isLoading = true;

  //UserPosts? userPosts;

  late User user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
    });
  }

  // void _loadUserPosts() async {
  //   try {
  //     final result = await _userService.getUserPosts(_auth.currentUser!.uid);
  //     if (!mounted) return; // avoid setState if widget disposed

  //     setState(() {
  //       userPosts = result;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     if (!mounted) return;
  //     _userService.showToast("An error occurred: $e");
  //     Navigator.pushNamed(context, 'home_screen');
  //   }
  // }

  void _loadUserInfo() async {
    final firebaseUser = FirebaseAuth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      if (!mounted) return;
      _userService.showToast("You are not logged in.");
      Navigator.pushReplacementNamed(context, 'splash_screen');
      return;
    }

    try {
      final result = await _userService.getUser(firebaseUser.uid);

      if (!mounted) return;

      setState(() {
        user = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _userService.showToast("An error occurred: $e");
      Navigator.pushReplacementNamed(context, 'home_screen');
    }
  }

  Uint8List getImageBytes(Uint8List? rawImage) {
    if (rawImage != null) {
      return Uint8List.fromList(List<int>.from(rawImage));
    }
    return Uint8List(0);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Center(child: CircularProgressIndicator());
    else {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      _auth.signOut();
                      Navigator.pushNamed(context, 'splash_screen');
                    },
                  ),
                ),
                Center(
                  child: Text(
                    "Profile",
                    style: GoogleFonts.robotoMono(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child:
                      (user.img != null)
                          ? CircleAvatar(
                            radius: 80,
                            backgroundImage: MemoryImage(
                              getImageBytes(user.img),
                            ),
                          )
                          : CircleAvatar(radius: 80, child: Icon(Icons.person)),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    user.username,
                    style: GoogleFonts.firaMono(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    user.description == "" ? "No bio yet." : user.description!,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                Center(child: DottedMainBtn(text: "Edit", onPressed: () {})),
                SizedBox(height: 20),
                // Column(
                //   children: [
                //     posts.isEmpty
                //         ? Text("No posts for now...")
                //         : Text("There are posts"),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
