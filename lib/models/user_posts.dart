import 'package:dotted_app/models/post.dart';

class UserPosts {
  final List<Post> posts;

  UserPosts({required this.posts});

  factory UserPosts.fromJson(Map<String, dynamic> json) {
    return UserPosts(
      posts: List<Post>.from(json['posts'].map((post) => Post.fromJson(post))),
    );
  }
}
