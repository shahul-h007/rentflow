import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Extracts raw text from an image file using Google ML Kit
  Future<String> extractText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Extract all TextLines
      List<TextLine> allLines = [];
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          allLines.add(line);
        }
      }

      if (allLines.isEmpty) return "";

      // Sort by vertical position (top Y coordinate)
      allLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

      String stitchedText = '';
      double currentTop = allLines.first.boundingBox.top;
      double currentBottom = allLines.first.boundingBox.bottom;
      List<TextLine> currentLineGroup = [];

      for (var line in allLines) {
        double centerY = line.boundingBox.top + (line.boundingBox.height / 2);
        
        // Check if the line belongs to the current horizontal row
        // We use a tolerance of a few pixels to account for slight skews
        if (centerY >= (currentTop - 10) && centerY <= (currentBottom + 10)) {
          currentLineGroup.add(line);
          if (line.boundingBox.bottom > currentBottom) {
            currentBottom = line.boundingBox.bottom;
          }
          if (line.boundingBox.top < currentTop) {
            currentTop = line.boundingBox.top;
          }
        } else {
          // Sort the row items from left to right
          currentLineGroup.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
          stitchedText += currentLineGroup.map((e) => e.text).join(' ') + '\n';
          
          currentLineGroup = [line];
          currentTop = line.boundingBox.top;
          currentBottom = line.boundingBox.bottom;
        }
      }

      // Add the final group
      if (currentLineGroup.isNotEmpty) {
        currentLineGroup.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
        stitchedText += currentLineGroup.map((e) => e.text).join(' ') + '\n';
      }

      return stitchedText;
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
    try {
      _textRecognizer.close();
    } catch (e) {
      // Ignore on unsupported platforms
    }
  }
}
