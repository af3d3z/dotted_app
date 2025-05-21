import 'package:dotted_app/custom/button.dart';
import 'package:dotted_app/services/user_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dotted_app/models/post.dart';
import 'package:google_fonts/google_fonts.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPost();
}

class _AddPost extends State<AddPost> {
  List<MediaType> mediaTypes = MediaType.values;

  MediaType? mediaSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text(
                "Add a new post",
                style: GoogleFonts.robotoMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: DropdownMenu(
                  hintText: "Type of post",
                  width: 300,
                  onSelected: (MediaType? mediaType) {
                    setState(() {
                      mediaSelected = mediaType;
                    });
                  },
                  dropdownMenuEntries: [
                    for (var mediaType in mediaTypes)
                      DropdownMenuEntry(
                        value: mediaType,
                        label: mediaType.name,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(child: _buildMediaForm(mediaSelected)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildMediaForm(MediaType? mediaSelected) {
  UserService _userService = UserService();

  switch (mediaSelected) {
    case MediaType.image:
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DottedMainBtn(
            text: "Select image",
            onPressed: () {
              _userService.uploadFile(FileType.image);
            },
          ),
        ],
      );
    case MediaType.video:
      return Container();
    case MediaType.audio:
      return Container();
    case MediaType.text:
      return Container();
    case null:
      return Text("No post type was selected.");
  }
}
