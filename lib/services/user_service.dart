import 'dart:convert';
import 'dart:io';

import 'package:dotted_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
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
    final uri = Uri.parse(API_URL + "api/users/" + userId);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print("Response body: ${body}");

      if (body == null || body is! Map<String, dynamic>) {
        throw Exception("Invalid response format.");
      }

      user = User.fromJson(body);
    } else {
      throw Exception("Could not load posts.");
    }

    return user;
  }
}
