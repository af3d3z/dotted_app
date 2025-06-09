library;

import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';

const String API_URL = "http://10.0.2.2:8000/";

User? user = FirebaseAuth.instance.currentUser;

Future<Uint8List?> compressImage(File? file, {int quality = 30}) async {
  if (file != null) {
    final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        format: CompressFormat.jpeg,
        minHeight: 512,
        minWidth: 512);

    return result;
  }
  return null;
}

Future<File?> compressVideo(File? file, {int quality = 20}) async {
  if (file != null) {
    final result = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.LowQuality,
      deleteOrigin: false,
    );

    return result?.file;
  }
  return null;
}
