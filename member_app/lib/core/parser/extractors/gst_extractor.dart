class GSTExtractor {
  static final _patterns = [
    RegExp(r'(?:gst|cgst|sgst|vat|tax)[\s:]*(?:rs\.?|inr|usd|€|£|₹)?\s*([0-9]+\.[0-9]{2})', caseSensitive: false),
  ];

  /// Returns the sum of all matching tax lines (e.g. CGST + SGST)
  static double extract(List<String> lines) {
    double totalTax = 0.0;
    
    for (final line in lines) {
      for (final pattern in _patterns) {
        final match = pattern.firstMatch(line);
        if (match != null && match.groupCount >= 1) {
          final amountStr = match.group(1);
          if (amountStr != null) {
            final parsed = double.tryParse(amountStr.replaceAll(',', ''));
            if (parsed != null) {
              totalTax += parsed;
              break; // Don't match multiple patterns on the same line
            }
          }
        }
      }
    }
    return totalTax;
  }
}
