import 'dart:io';

import 'package:dotted_app/models/post.dart';
import 'package:dotted_app/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class PostVideoPlayer extends StatefulWidget {
  final Post post;

  const PostVideoPlayer({Key? key, required this.post}) : super(key: key);

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  VideoPlayerController? _controller;

  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    final tempDir = await getTemporaryDirectory();
    final file = await File(
      '${tempDir.path}/temp_video.mp4',
    ).writeAsBytes(widget.post.value!);

    _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });

    _controller?.addListener(() {
      if (_controller!.value.position >= _controller!.value.duration &&
          !_controller!.value.isPlaying) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;

    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }

    setState(() {
      _isPlaying = _controller!.value.isPlaying;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        if (!_isPlaying)
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              color: Colors.black45,
              child: const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),
      ],
    );
  }
}
