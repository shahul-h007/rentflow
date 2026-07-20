class ReceiptNumberExtractor {
  static final _patterns = [
    RegExp(r'(?:bill|invoice|receipt|order|token)[\s\w]*(?:no|#|num)[\s:]*([a-zA-Z0-9\-]+)', caseSensitive: false),
    RegExp(r'^#\s*([a-zA-Z0-9\-]+)$'), // Just a # followed by ID
  ];

  static String? extract(List<String> lines) {
    for (final line in lines) {
      for (final pattern in _patterns) {
        final match = pattern.firstMatch(line);
        if (match != null && match.groupCount >= 1) {
          final id = match.group(1)?.trim();
          if (id != null && id.isNotEmpty) {
            return id;
          }
        }
      }
    }
    return null;
  }
}
