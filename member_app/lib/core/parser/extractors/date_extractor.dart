class DateExtractor {
  static final _patterns = [
    // 19/07/2026 or 19-07-2026
    RegExp(r'\b(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})\b'),
    // 2026-07-19
    RegExp(r'\b(\d{4})[\/\-](\d{1,2})[\/\-](\d{1,2})\b'),
    // 19 Jul 2026
    RegExp(r'\b(\d{1,2})\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+(\d{2,4})\b', caseSensitive: false),
    // Jul 19 2026
    RegExp(r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+(\d{1,2}),?\s+(\d{2,4})\b', caseSensitive: false),
  ];

  static String? extract(List<String> lines) {
    for (final line in lines) {
      for (final pattern in _patterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          // Just return the raw match string for V1, we can parse to DateTime later
          return match.group(0); 
        }
      }
    }
    return null;
  }
}
