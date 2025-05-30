import 'dart:typed_data';
import 'package:dotted_app/custom/button.dart';
import 'package:dotted_app/custom/components/post_tile.dart';
import 'package:dotted_app/models/user.dart';
import 'package:dotted_app/models/post.dart';
import 'package:dotted_app/services/post_service.dart';
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
  final PostService _postService = PostService();
  bool isLoading = true;
  bool arePostsLoading = true;

  late User user;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
      _loadPosts();
    });
  }

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

  void _loadPosts() async {
    final firebaseUser = FirebaseAuth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      if (!mounted) return;
      _userService.showToast("You are not logged in.");
      Navigator.pushReplacementNamed(context, 'splash_screen');
      return;
    }

    try {
      final result = await _postService.getPosts(firebaseUser.uid);
      if (!mounted) return;

      setState(() {
        posts = result;
        arePostsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      print(e);
      _userService.showToast("An error ocurred: $e");
      Navigator.pushReplacementNamed(context, 'home_screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
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
                              PostService.getImageBytes(user.img),
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
                SizedBox(
                  height: 400,
                  child:
                      posts.isEmpty
                          ? Text("There are no posts yet.")
                          : ListView(
                            shrinkWrap: true,
                            children: [
                              for (Post post in posts) PostTile(post: post),
                            ],
                          ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
