import 'dart:convert';
import 'dart:io';

import 'package:dotted_app/models/user_posts.dart';
import 'package:dotted_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:dotted_app/custom/global.dart';

class UserService {
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // returns a user posts
  Future<UserPosts> getUserPosts(String userId) async {
    UserPosts userPosts;
    final uri = Uri.parse(API_URL + "api/user-posts/" + userId);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print("Response body: ${body}");

      if (body == null || body is! Map<String, dynamic>) {
        throw Exception("Invalid response format.");
      }

      userPosts = UserPosts.fromJson(body);
    } else {
      throw Exception("Could not load posts.");
    }

    return userPosts;
  }

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

  // uploads a post to the server
  Future<void> uploadFile(FileType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      final uri = Uri.parse(API_URL + "api/posts");

      final request =
          http.MultipartRequest('POST', uri)
            ..fields['userId'] = _auth.currentUser!.uid
            ..fields['type'] = type.name
            ..files.add(await http.MultipartFile.fromPath('value', file.path!));

      final response = await request.send();

      final respString = await response.stream.bytesToString();
      final decoded = jsonDecode(respString);

      showToast(decoded['msg']);
    }
  }
}
