import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ScannerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return null;
    return _compressImage(File(photo.path));
  }

  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return _compressImage(File(image.path));
  }

  Future<File> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp|.png|.jpeg'));
    
    // If not a standard image, just return
    if (lastIndex == -1) return file;
    
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_compressed.jpg";

    try {
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 80,
        minWidth: 1920,
        minHeight: 1920,
      );
      return result != null ? File(result.path) : file;
    } catch (e) {
      // Fallback for unsupported platforms like Windows
      return file;
    }
  }
}
