class MerchantExtractor {
  static final _ignoreKeywords = [
    'gst', 'bill no', 'phone', 'invoice', 'date', 'time', 'cash', 'card', 'return', 'merchant name', 'fssai', 'tax', 'receipt'
  ];

  /// Extracts the merchant name from the top of the receipt.
  /// Typically found in the first 3 lines.
  static String? extract(List<String> lines) {
    // Check up to the first 5 lines (some receipts have address first, but usually name is line 1)
    final checkLimit = lines.length < 5 ? lines.length : 5;

    for (int i = 0; i < checkLimit; i++) {
      final line = lines[i].toLowerCase();
      bool shouldIgnore = false;

      for (var keyword in _ignoreKeywords) {
        if (line.contains(keyword)) {
          shouldIgnore = true;
          break;
        }
      }

      // Also ignore lines that are just numbers (like a phone number)
      if (RegExp(r'^\d+$').hasMatch(line.replaceAll(RegExp(r'[\s\-\+\(\)]'), ''))) {
        shouldIgnore = true;
      }

      if (!shouldIgnore && line.length > 3) {
        return lines[i]; // Return the original case
      }
    }
    return null;
  }
}
