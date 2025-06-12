import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_app/custom/global.dart';
import 'package:dotted_app/models/post.dart';
import 'package:dotted_app/services/user_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PostService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // gets the bytes from an image to convert them to a formal Uint8List so it dosesn't fail when uploading or showing images
  static Uint8List getImageBytes(Uint8List? rawImage) {
    if (rawImage != null) {
      return Uint8List.fromList(List<int>.from(rawImage));
    }
    return Uint8List(0);
  }

  // returns all the posts from a specific user
  Future<List<Post>> getPosts(String userId) async {
    List<Post> posts;
    final uri = Uri.parse("${API_URL}api/posts/$userId");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = response.body.trim();

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

  // sends a request to the server to mark the post as deleted (the post will continue to exist but it will be hidden to users)
  Future<void> deletePost(int postId) async {
    final uri = Uri.parse("${API_URL}api/posts/$postId");
    final request = await http.delete(uri);

    final jsonResponse = jsonDecode(request.body.trim());
    UserService.showToast(jsonResponse['msg']);
  }

  // sends a request to the server to edit the posts with a text type
  Future<void> editPost(int postId, String text) async {
    File textFile = await createTextFile(text);
    final uri = Uri.parse("${API_URL}api/posts");
    final request = http.MultipartRequest('PUT', uri)
      ..fields['postId'] = postId.toString()
      ..files.add(await http.MultipartFile.fromPath('value', textFile.path));

    final response = await request.send();
    final responseString = await response.stream.bytesToString();
    final decoded = jsonDecode(responseString);
    UserService.showToast(decoded['msg']);
  }

  // this is used because we can't send the text as a blob directly, we can only send the file
  Future<File> createTextFile(String text) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/temp_post.txt');
    return file.writeAsString(text);
  }

  // sends the text to the server as it if was a file
  Future<void> uploadText(String text) async {
    File file = await createTextFile(text);

    final uri = Uri.parse("${API_URL}api/posts");

    final request = http.MultipartRequest('POST', uri)
      ..fields['userId'] = _auth.currentUser!.uid
      ..fields['type'] = 'text'
      ..files.add(await http.MultipartFile.fromPath('value', file.path));

    final response = await request.send();
    final respString = await response.stream.bytesToString();
    final decoded = jsonDecode(respString);

    UserService.showToast(decoded['msg']);
  }

  // uploads a post to the server
  Future<void> uploadFile(FileType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      File? file = type == FileType.video
          ? await compressVideo(File(result.files.single.path!))
          : File(result.files.single.path!);

      final uri = Uri.parse("${API_URL}api/posts");

      final request = http.MultipartRequest('POST', uri)
        ..fields['userId'] = _auth.currentUser!.uid
        ..fields['type'] = type.name
        ..files.add(
          await http.MultipartFile.fromPath('value', file!.path),
        );

      final response = await request.send();

      final respString = await response.stream.bytesToString();
      final decoded = jsonDecode(respString);

      UserService.showToast(decoded['msg']);
    }
  }
}
