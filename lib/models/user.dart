import 'dart:convert';
import 'dart:typed_data';

class User {
  // stores the user identifier
  final String id;
  // stores the username
  String username;
  // stores the email of the user
  final String email;
  // stores a profile image
  Uint8List? img;
  // stores the description of the profile
  String? description;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.img,
    this.description,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      img: json['img'] != null ? base64Decode(json['img']) : null,
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'img': img,
      'description': description
    };
  }
}
