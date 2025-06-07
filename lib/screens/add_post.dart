import 'package:dotted_app/custom/button.dart';
import 'package:dotted_app/services/post_service.dart';
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
  PostService _postService = PostService();
  final textField = TextEditingController();

  switch (mediaSelected) {
    case MediaType.image:
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DottedMainBtn(
            text: "Select an image",
            onPressed: () {
              _postService.uploadFile(FileType.image);
            },
          ),
          SizedBox(height: 10),
        ],
      );
    case MediaType.video:
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DottedMainBtn(
            text: "Select video",
            onPressed: () {
              _postService.uploadFile(FileType.video);
            },
          ),
        ],
      );
    case MediaType.audio:
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DottedMainBtn(
            text: "Select audio file",
            onPressed: () {
              _postService.uploadFile(FileType.audio);
            },
          ),
        ],
      );
    case MediaType.text:
      return Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            width: 310,
            child: TextField(
              minLines: 6,
              maxLength: 120,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              controller: textField,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Write your post here.",
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DottedMainBtn(
                text: "Reset",
                onPressed: () {
                  textField.clear();
                },
                minWidth: 150,
              ),
              SizedBox(width: 10),
              DottedMainBtn(
                text: "Confirm",
                onPressed: () {
                  _postService.uploadText(textField.text);
                  textField.clear();
                },
                minWidth: 150,
              ),
            ],
          ),
        ],
      );
    case null:
      return Text("No post type was selected.");
  }
}
