import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_app/custom/components/chat_bubble.dart';
import 'package:dotted_app/custom/components/message_textfield.dart';
import 'package:dotted_app/custom/components/user_tile.dart';
import 'package:dotted_app/models/user.dart';
import 'package:dotted_app/screens/profile_screen.dart';
import 'package:dotted_app/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase;
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final User user;

  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final _auth = Firebase.FirebaseAuth.instance;
  final ChatService _chatService = ChatService();

  String? _fcmToken;
  late Future<String?> _fcmTokenFuture;

  @override
  void initState() {
    super.initState();
    _fcmTokenFuture = _chatService.getFcmToken(widget.user.id);
  }

  void _sendMessage() async {
    _fcmToken ??= await _fcmTokenFuture;
    print(_fcmToken);

    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.user.id, _messageController.text);

      if (_fcmToken != null && _fcmToken!.isNotEmpty) {
        await _chatService.sendNotification(
            _fcmToken!, widget.user.username, _messageController.text);
      } else {
        print("Could not send notification");
      }

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
        title: UserTile(
            username: widget.user.username,
            img: widget.user.img,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: widget.user.id),
                ),
              );
            }),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _auth.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.user.id, senderID),
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

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          reverse: true,
          itemBuilder: (context, index) {
            DocumentSnapshot doc =
                snapshot.data!.docs[snapshot.data!.docs.length - 1 - index];
            return _buildMessageItem(doc);
          },
        );
      },
    );
  }

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
              "${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour < 10 ? "0${dateTime.hour}" : dateTime.hour}:${dateTime.minute < 10 ? "0${dateTime.minute}" : dateTime.minute} ",
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
            onPressed: _sendMessage,
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
