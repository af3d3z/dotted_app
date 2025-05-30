import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dotted_app/custom/global.dart';
import 'package:dotted_app/models/post.dart';
import 'package:http/http.dart' as http;

class PostService {
  static Uint8List getImageBytes(Uint8List? rawImage) {
    if (rawImage != null) {
      return Uint8List.fromList(List<int>.from(rawImage));
    }
    return Uint8List(0);
  }

  // returns all the posts from a specific user
  Future<List<Post>> getPosts(String userId) async {
    List<Post> posts;
    final uri = Uri.parse(API_URL + "api/posts/" + userId);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = response.body.trim();
      print("Response body: ${body}");

      if (body.isEmpty || body == "{}") {
        posts = [];
      } else {
        final decoded = jsonDecode(body);
        posts = List<Post>.from(decoded.map((model) => Post.fromJson(model)));
      }
    } else {
      throw Exception("Could not load posts.");
    }

    return posts;
  }
}
