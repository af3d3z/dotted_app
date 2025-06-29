import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_app/custom/global.dart';
import 'package:dotted_app/models/message.dart';
import 'package:dotted_app/models/user.dart';
import 'package:dotted_app/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:http/http.dart' as http;

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Auth.FirebaseAuth _auth = Auth.FirebaseAuth.instance;

  // gets all the users to show them on the chat screen
  Future<List<User>> getUsers() async {
    List<User> users;

    final uri = Uri.parse("${API_URL}api/users");
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

  // sends a request to the backend so that it sends a notification through the Firebase Cloud Messaging service
  Future<void> sendNotification(
      String fcmToken, String username, String message) async {
    final uri = Uri.parse("${API_URL}api/send-message");

    print('token: $fcmToken username: $username message: $message');

    final response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'fcmToken': fcmToken, 'username': username, 'message': message}));

    if (response.statusCode != 201) {
      final responseData = jsonDecode(response.body);
      UserService.showToast(responseData['msg']);
    }
  }

  // sends a message from a user to another
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

  // gets the FCM token of a certain user
  Future<String?> getFcmToken(String userId) async =>
      (await FirebaseFirestore.instance.collection('users').doc(userId).get())
          .get('fcmToken');

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
