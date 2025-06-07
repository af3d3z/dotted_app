import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_app/models/message.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.indigo : Colors.teal,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Column(
        children: [
          Text(message, style: TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }
}
