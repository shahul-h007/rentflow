class TotalExtractor {
  static final _patterns = [
    RegExp(r'(?:grand|net|amount|balance)?\s*total[\s:]*(?:rs\.?|inr|usd|€|£|₹)?\s*([0-9]+\.[0-9]{2})', caseSensitive: false),
    RegExp(r'(?:amount payable|balance due)[\s:]*(?:rs\.?|inr|usd|€|£|₹)?\s*([0-9]+\.[0-9]{2})', caseSensitive: false),
    RegExp(r'^total[\s:]*([0-9]+)$', caseSensitive: false),
  ];

  /// Should always return the last valid total in the receipt.
  static double? extract(List<String> lines) {
    double? lastTotal;
    
    for (final line in lines) {
      for (final pattern in _patterns) {
        final match = pattern.firstMatch(line);
        if (match != null && match.groupCount >= 1) {
          final amountStr = match.group(1);
          if (amountStr != null) {
            final parsed = double.tryParse(amountStr.replaceAll(',', ''));
            if (parsed != null) {
              lastTotal = parsed;
            }
          }
        }
      }
    }
    return lastTotal;
  }
}
