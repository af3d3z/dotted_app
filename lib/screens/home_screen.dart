import 'package:dotted_app/screens/add_post.dart';
import 'package:dotted_app/screens/chat_screen.dart';
import 'package:dotted_app/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final pages = [ChatScreen(), AddPost(), ProfileScreen()];
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[pageIndex],
      bottomNavigationBar: Container(
        height: 70,
        padding: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.black),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    pageIndex = 0;
                  });
                },
                icon:
                    pageIndex == 0
                        ? const Icon(Icons.chat, color: Colors.white, size: 35)
                        : const Icon(Icons.chat, color: Colors.grey, size: 35),
              ),
            ),
            SizedBox(
              height: 50,
              width: 50,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    pageIndex = 1;
                  });
                },
                icon:
                    pageIndex == 1
                        ? const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 35,
                        )
                        : const Icon(
                          Icons.add_circle_outline,
                          color: Colors.grey,
                          size: 35,
                        ),
              ),
            ),
            SizedBox(
              height: 50,
              width: 50,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    pageIndex = 2;
                  });
                },
                icon:
                    pageIndex == 2
                        ? Icon(Icons.person, color: Colors.white, size: 35)
                        : Icon(Icons.person, color: Colors.grey, size: 35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
