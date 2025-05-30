import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_app/custom/components/video_player.dart';
import 'package:dotted_app/models/post.dart';
import 'package:dotted_app/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class PostTile extends StatelessWidget {
  final Post post;

  const PostTile({super.key, required this.post});

  Future<File> writeBlobToTempFile(Uint8List blob, String extension) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/temp_image.$extension';
    final file = File(filePath);
    await file.writeAsBytes(blob);
    return file;
  }

  Future<void> playAudio(Uint8List blob) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = await File('${tempDir.path}/audio.mp3');

    await tempFile.writeAsBytes(blob, flush: true);

    final player = AudioPlayer();
    await player.setFilePath(tempFile.path);
    player.play();
  }

  String getText(Uint8List blob) {
    return String.fromCharCodes(blob);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: switch (post.type) {
          MediaType.image =>
            post.value != null
                ? Image.memory(post.value!, height: 400, width: 400)
                : Text("No image available"),

          MediaType.audio =>
            post.value != null
                ? Center(
                  child: IconButton(
                    onPressed: () {
                      playAudio(post.value!);
                    },
                    icon: Icon(Icons.play_arrow),
                    color: Colors.black,
                  ),
                )
                : Text("No audio available"),
          MediaType.video => PostVideoPlayer(post: post),
          MediaType.text =>
            post.value != null
                ? Center(child: Text(getText(post.value!)))
                : Text("No text available"),
        },
      ),
    );
  }
}
