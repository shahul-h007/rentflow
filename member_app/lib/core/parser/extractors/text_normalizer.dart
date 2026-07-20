class TextNormalizer {
  /// Cleans the raw OCR text:
  /// - Converts tabs to spaces
  /// - Removes duplicate spaces
  /// - Trims whitespace
  /// - Removes empty lines
  static String normalize(String rawText) {
    if (rawText.isEmpty) return '';

    final lines = rawText.split('\n');
    final cleanedLines = <String>[];

    for (var line in lines) {
      // Replace tabs with spaces
      var cleaned = line.replaceAll('\t', ' ');
      // Replace multiple spaces with a single space
      cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
      // Trim
      cleaned = cleaned.trim();
      
      if (cleaned.isNotEmpty) {
        cleanedLines.add(cleaned);
      }
    }

    return cleanedLines.join('\n');
  }
}
