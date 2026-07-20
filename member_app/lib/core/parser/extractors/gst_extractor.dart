class GSTExtractor {
  static final _patterns = [
    RegExp(r'\b(?:gst|cgst|sgst|vat|tax)\b.*?(?:rs\.?|inr|usd|€|£|₹)?\s*([0-9]+\.[0-9]{2})$', caseSensitive: false),
  ];

  /// Returns the sum of all matching tax lines (e.g. CGST + SGST)
  static double extract(List<String> lines) {
    double totalTax = 0.0;
    
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
              totalTax += parsed;
              foundOnLine = true;
              break; 
            }
          }
        }
      }

      if (!foundOnLine && RegExp(r'\b(?:gst|cgst|sgst|vat|tax)\b', caseSensitive: false).hasMatch(line)) {
        for (int j = i + 1; j < i + 3 && j < lines.length; j++) {
           final priceMatch = RegExp(r'^([0-9]+\.[0-9]{2})$').firstMatch(lines[j].trim());
           if (priceMatch != null) {
              final parsed = double.tryParse(priceMatch.group(1)!);
              if (parsed != null) {
                 totalTax += parsed;
                 break;
              }
           }
        }
      }
    }
    return totalTax;
  }
}
