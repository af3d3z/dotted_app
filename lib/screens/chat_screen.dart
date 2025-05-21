import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _CreateState();
}

class _CreateState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("Chats"));
  }
}
