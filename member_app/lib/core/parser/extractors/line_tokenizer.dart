class LineTokenizer {
  /// Splits normalized OCR text into an ordered list of lines.
  static List<String> tokenize(String normalizedText) {
    if (normalizedText.isEmpty) return [];
    return normalizedText.split('\n');
  }
}
