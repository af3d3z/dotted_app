import 'package:dotted_app/custom/components/post_tile.dart';
import 'package:dotted_app/models/post.dart';
import 'package:flutter/material.dart';

class PostPreviewModal extends StatelessWidget {
  final Post post;

  const PostPreviewModal({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return PostTile(post: post);
  }
}
