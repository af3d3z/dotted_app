import 'dart:convert';
import 'package:dotted_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_app/custom/global.dart';

class UserService {
  // shows a toast with the message specified
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // gets the user info from the API, needs the userId to fetch it
  Future<User> getUser(String userId) async {
    User user;
    final uri = Uri.parse("${API_URL}api/users/$userId");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body == null || body is! Map<String, dynamic>) {
        throw Exception("Invalid response format.");
      }

      user = User.fromJson(body);
    } else {
      throw Exception("Could not load posts.");
    }

    return user;
  }

  // sends a request to the server to edit the user
  Future<bool> editUser(User user) async {
    bool modified = false;
    final uri = Uri.parse("${API_URL}api/users");
    final response = await http.put(uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()));

    if (response.statusCode == 204) {
      modified = true;
      showToast("User info edited successfully");
    } else if (response.body.isNotEmpty) {
      final body = jsonDecode(response.body);
      showToast(body['msg']);
    } else {
      showToast("Unexpected error with empty response.");
    }

    return modified;
  }

  // loads the user profile info
  Future<User?> loadUserInfo(BuildContext context, String? userId) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      showToast("You are not logged in.");
      Navigator.pushReplacementNamed(context, 'splash_screen');
      return null;
    }

    try {
      final result = await getUser(userId ?? firebaseUser.uid);
      return result;
    } catch (e) {
      showToast("An error occurred: $e");
      Navigator.pushReplacementNamed(context, 'home_screen');
      return null;
    }
  }
}
