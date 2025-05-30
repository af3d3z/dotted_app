import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

enum MediaType { video, audio, text, image }

class Post {
  final int? postId;
  final String userId;
  final String? pubTime;
  final MediaType type;
  final Uint8List? value;

  Post({
    this.postId,
    required this.userId,
    this.pubTime,
    required this.type,
    required this.value,
  });

  factory Post.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception("Post JSON is null");
    }

    Uint8List? valueBytes;
    if (json['value'] != null && json['value'] is String) {
      try {
        valueBytes = base64Decode(json['value']);
      } catch (e) {
        // Handle invalid base64 string if necessary
        valueBytes = null;
      }
    }

    return Post(
      postId: json['postId'] is int ? json['postId'] : null,
      userId: json['userId']?.toString() ?? '',
      pubTime: json['pubTime']?.toString(),
      type: MediaType.values.firstWhere(
        (e) => e.toString() == 'MediaType.' + (json['type'] ?? 'text'),
        orElse: () => MediaType.text,
      ),
      value: valueBytes,
    );
  }
}
