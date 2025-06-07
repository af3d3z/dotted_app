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
  static Uint8List getImageBytes(Uint8List? rawImage) {
    if (rawImage != null) {
      return Uint8List.fromList(List<int>.from(rawImage));
    }
    return Uint8List(0);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // returns all the posts from a specific user
  Future<List<Post>> getPosts(String userId) async {
    List<Post> posts;
    final uri = Uri.parse(API_URL + "api/posts/" + userId);
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

  Future<File> createTextFile(String text) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/temp_post.txt');
    return file.writeAsString(text);
  }

  Future<void> uploadText(String text) async {
    File file = await createTextFile(text);

    final uri = Uri.parse(API_URL + "api/posts");

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['userId'] = _auth.currentUser!.uid
          ..fields['type'] = 'text'
          ..files.add(await http.MultipartFile.fromPath('value', file.path));

    final response = await request.send();
    final respString = await response.stream.bytesToString();
    final decoded = jsonDecode(respString);

    UserService.showToast(decoded);
  }

  // uploads a post to the server
  Future<void> uploadFile(FileType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      File? file =
          type == FileType.video
              ? await compressVideo(File(result.files.single.path!))
              : File(result.files.single.path!);

      final uri = Uri.parse(API_URL + "api/posts");

      final request =
          http.MultipartRequest('POST', uri)
            ..fields['userId'] = _auth.currentUser!.uid
            ..fields['type'] = type.name
            ..files.add(
              await http.MultipartFile.fromPath('value', file!.path!),
            );

      final response = await request.send();

      final respString = await response.stream.bytesToString();
      final decoded = jsonDecode(respString);

      UserService.showToast(decoded['msg']);
    }
  }
}
