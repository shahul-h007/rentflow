class TotalExtractor {
  static final _patterns = [
    RegExp(r'(?:grand|net|amount|balance)?\s*total[\s:]*(?:rs\.?|inr|usd|€|£|₹)?\s*([0-9]+\.[0-9]{2})', caseSensitive: false),
    RegExp(r'(?:amount payable|balance due)[\s:]*(?:rs\.?|inr|usd|€|£|₹)?\s*([0-9]+\.[0-9]{2})', caseSensitive: false),
    RegExp(r'^total[\s:]*([0-9]+)$', caseSensitive: false),
  ];

  static double? extract(List<String> lines) {
    double? lastTotal;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      bool foundOnLine = false;

      for (final pattern in _patterns) {
        final match = pattern.firstMatch(line);
        if (match != null && match.groupCount >= 1) {
          final amountStr = match.group(1);
          if (amountStr != null) {
            final parsed = double.tryParse(amountStr.replaceAll(',', ''));
            if (parsed != null) {
              lastTotal = parsed;
              foundOnLine = true;
            }
          }
        }
      }

      // If we saw "total" but no price on the same line, check the next few lines
      if (!foundOnLine && RegExp(r'\btotal\b', caseSensitive: false).hasMatch(line)) {
        for (int j = i + 1; j < i + 3 && j < lines.length; j++) {
           final priceMatch = RegExp(r'^([0-9]+\.[0-9]{2})$').firstMatch(lines[j].trim());
           if (priceMatch != null) {
              final parsed = double.tryParse(priceMatch.group(1)!);
              if (parsed != null && lastTotal == null) {
                 lastTotal = parsed;
                 break;
              }
           }
        }
      }
    }
    return lastTotal;
  }
}
