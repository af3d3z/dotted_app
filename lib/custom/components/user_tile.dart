import 'dart:typed_data';

import 'package:dotted_app/models/user.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String username;
  final Uint8List? img;

  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.username,
    this.img,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white60,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            img != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.memory(img!, height: 50, width: 50),
                )
                : Icon(Icons.person, color: Colors.grey, size: 50),
            const SizedBox(width: 20),
            Text(username, style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
