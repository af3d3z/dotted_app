import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_app/custom/components/chat_bubble.dart';
import 'package:dotted_app/custom/components/message_textfield.dart';
import 'package:dotted_app/custom/components/user_tile.dart';
import 'package:dotted_app/models/user.dart';
import 'package:dotted_app/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase;
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final User user;

  final TextEditingController _messageController = TextEditingController();
  final _auth = Firebase.FirebaseAuth.instance;
  final ChatService _chatService = ChatService();

  ChatPage({super.key, required this.user});

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(user.id, _messageController.text);

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 75,
        title: UserTile(username: user.username, img: user.img, onTap: () {}),
      ),
      body: Column(
        children: [
          //messages
          Expanded(child: _buildMessageList()),

          //user input
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _auth.currentUser!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(user.id, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // check if the sender is the current user
    bool isCurrentUser = data['senderID'] == _auth.currentUser!.uid;

    Timestamp timestamp = data['timestamp'];
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      timestamp.millisecondsSinceEpoch,
    );

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(message: data["message"], isCurrentUser: isCurrentUser),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              "${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour < 10 ? "0" + dateTime.hour.toString() : dateTime.hour}:${dateTime.minute < 10 ? "0" + dateTime.minute.toString() : dateTime.minute} ",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: isCurrentUser ? TextAlign.end : TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35, right: 17, left: 17),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: MessageTextField(
              hintText: "Send a message",
              obscureText: false,
              controller: _messageController,
            ),
          ),
          const SizedBox(width: 15),
          IconButton(
            onPressed: sendMessage,
            icon: Icon(Icons.arrow_upward, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black,
              iconSize: 35,
            ),
          ),
        ],
      ),
    );
  }
}
