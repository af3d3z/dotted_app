library globals;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';


const String API_URL="http://10.0.2.2:8000/";


Future<Uint8List?> compressImage(File? file, {int quality = 50}) async {
  if (file != null) {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality, 
      format: CompressFormat.jpeg, 
    );

  return result;
  }
}
