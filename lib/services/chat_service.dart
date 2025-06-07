import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_app/custom/global.dart';
import 'package:dotted_app/models/message.dart';
import 'package:dotted_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:http/http.dart' as http;

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Auth.FirebaseAuth _auth = Auth.FirebaseAuth.instance;

  Future<List<User>> getUsers() async {
    List<User> users;

    final uri = Uri.parse(API_URL + "api/users");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = response.body.trim();

      if (body.isEmpty || body == "{}") {
        users = [];
      } else {
        final decoded = jsonDecode(body);
        users = List<User>.from(decoded.map((model) => User.fromJson(model)));
      }
    } else {
      throw Exception("Could not load posts");
    }

    return users;
  }

  Future<void> sendMessage(String receiverID, message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserID,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // we build a chatroom id for the conversation (sorted to ensure uniquenesss)
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // get messages from firestore
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
