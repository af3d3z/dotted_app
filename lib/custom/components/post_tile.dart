import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_app/custom/components/video_player.dart';
import 'package:dotted_app/models/post.dart';
import 'package:dotted_app/services/post_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final bool rootPost;

  const PostTile({super.key, required this.post, required this.rootPost});

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
      onTap: () {
        print(post.postId);
        if (this.rootPost) {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "Post",
            transitionDuration: Duration(milliseconds: 200),
            pageBuilder: (_, _, ___) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        height: 350,
                        width: 350,
                        child: PostTile(post: post, rootPost: false),
                      ),
                      if (post.type == MediaType.text)
                        SizedBox(
                          width: 350,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 5),
                                Text("Edit"),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 350,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 5),
                              Text("Delete"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: switch (post.type) {
          MediaType.image =>
            post.value != null
                ? Image.memory(post.value!, height: 300, width: 300)
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
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        getText(post.value!),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                )
                : Text("No text available"),
        },
      ),
    );
  }
}
