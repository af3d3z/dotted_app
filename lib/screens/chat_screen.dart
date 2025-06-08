import 'package:dotted_app/custom/components/user_tile.dart';
import 'package:dotted_app/models/user.dart';
import 'package:dotted_app/screens/chat_page.dart';
import 'package:dotted_app/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _CreateState();
}

class _CreateState extends State<ChatScreen> {
  final Firebase.FirebaseAuth _auth = Firebase.FirebaseAuth.instance;
  final ChatService _chatService = ChatService();

  Widget _buildUserListItem(User user, BuildContext context) {
    if (_auth.currentUser!.email != user.email) {
      return UserTile(
        username: user.username,
        img: user.img,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatPage(user: user)),
          );
        },
      );
    } else {
      return Container();
    }
  }

  Widget _buildUserList() {
    return FutureBuilder(
      future: _chatService.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("An error ocurred. Try again later...");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(color: Colors.black);
        }

        return ListView(
          children: snapshot.data!
              .map<Widget>(
                (userData) => _buildUserListItem(userData, context),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Chats",
            style: GoogleFonts.robotoMono(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: _buildUserList(),
    );
  }
}
