import 'package:dotted_app/custom/button.dart';
import 'package:dotted_app/custom/components/post_tile.dart';
import 'package:dotted_app/models/user.dart';
import 'package:dotted_app/models/post.dart';
import 'package:dotted_app/screens/edit_screen.dart';
import 'package:dotted_app/services/post_service.dart';
import 'package:dotted_app/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final result = await _userService.loadUserInfo(context);

    if (result == null) {
      return;
    }

    setState(() {
      user = result;
      isLoading = false;
    });
  }

  void _loadPosts() async {
    final firebaseUser = FirebaseAuth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      if (!mounted) return;
      UserService.showToast("You are not logged in.");
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
      UserService.showToast("An error ocurred: $e");
      Navigator.pushReplacementNamed(context, 'home_screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
              child: CircularProgressIndicator(
            color: Colors.black,
          )));
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
                  child: (user.img != null)
                      ? CircleAvatar(
                          radius: 80,
                          backgroundImage: MemoryImage(
                            PostService.getImageBytes(user.img),
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
                Center(
                    child: DottedMainBtn(
                        text: "Edit",
                        onPressed: () {
                          Navigator.pushNamed(context, 'edit_screen');
                        })),
                SizedBox(height: 20),
                SizedBox(
                  height: 400,
                  child: Builder(
                    builder: (_) {
                      if (arePostsLoading) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(color: Colors.black),
                                SizedBox(height: 10),
                                Text("Fetching posts..."),
                              ],
                            ),
                          ),
                        );
                      } else if (posts.isEmpty) {
                        return Text("There are no posts.");
                      } else {
                        return SafeArea(
                          child: GridView.builder(
                            itemCount: posts.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              return Builder(
                                builder: (context) => GestureDetector(
                                  onTap: () {
                                    print("Tapped");
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Container(
                                        height: 200,
                                        color: Colors.white,
                                        child: Center(
                                          child: Text("modal"),
                                        ),
                                      ),
                                    );
                                  },
                                  child: PostTile(
                                    post: post,
                                    rootPost: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
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
