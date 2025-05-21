import 'dart:io';

enum MediaType { video, audio, text, image }

class Post {
  final int? postId;
  final String userId;
  final String? pubTime;
  final MediaType type;
  final File? value;

  Post({
    this.postId,
    required this.userId,
    this.pubTime,
    required this.type,
    required this.value,
  });

  factory Post.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      // Defensive: return null or throw here if you prefer
      throw Exception("Post JSON is null");
    }
    return Post(
      postId: json['postId'] is int ? json['postId'] : null,
      userId: json['userId']?.toString() ?? '',
      pubTime: json['pubTime']?.toString(),
      type: MediaType.values.firstWhere(
        (e) => e.toString() == 'MediaType.' + (json['type'] ?? 'text'),
        orElse: () => MediaType.text,
      ),
      value:
          (json['value'] != null && json['value'] is String)
              ? File(json['value'])
              : null,
    );
  }
}
