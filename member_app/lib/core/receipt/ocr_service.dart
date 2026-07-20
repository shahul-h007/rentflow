import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Extracts raw text from an image file using Google ML Kit
  Future<String> extractText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Extract the full raw text
      return recognizedText.text;
    } catch (e) {
      if (e.toString().contains('MissingPluginException') || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Fallback mock string for desktop debugging
        return '''
          MOCK RESTAURANT
          Date: 2026-07-20
          Chicken Biryani x 2 240.00
          Mutton Curry 1 150.00
          Roti 4 40.00
          GST 21.50
          TOTAL 451.50
        ''';
      }
      throw Exception('Failed to extract text from image: $e');
    }
  }
  
  /// Disposes the text recognizer to free up resources
  void dispose() {
    _textRecognizer.close();
  }
}
