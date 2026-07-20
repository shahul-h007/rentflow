import 'package:uuid/uuid.dart';
import '../../../features/food_splitter/domain/models/receipt_item.dart';

class ItemExtractor {
  static final _uuid = const Uuid();
  
  static final _ignoreKeywords = [
    'gst', 'cgst', 'sgst', 'vat', 'tax', 'total', 'discount', 
    'cash', 'card', 'change', 'subtotal', 'service', 'delivery'
  ];

  static final _itemPattern = RegExp(
    r'^([a-zA-Z\s\&\.\-]+?)\s+(?:(?:x\s*(\d+))|(?:(\d+)\s*x)|(?:qty[\s:]*(\d+))|(\d+))?\s*(?:rs\.?|inr|usd|€|£|₹)?\s*([0-9]+\.[0-9]{2})$',
    caseSensitive: false,
  );

  static List<ReceiptItem> extract(List<String> lines) {
    final List<ReceiptItem> items = [];

    for (final line in lines) {
      bool shouldIgnore = false;
      for (var keyword in _ignoreKeywords) {
        if (line.toLowerCase().contains(keyword)) {
          shouldIgnore = true;
          break;
        }
      }

      if (shouldIgnore) continue;

      final match = _itemPattern.firstMatch(line);
      if (match != null) {
        final name = match.group(1)?.trim();
        if (name == null || name.length < 3) continue;

        // Extract quantity from the various capture groups
        final qtyStr = match.group(2) ?? match.group(3) ?? match.group(4) ?? match.group(5);
        final qty = qtyStr != null ? (double.tryParse(qtyStr) ?? 1.0) : 1.0;

        final priceStr = match.group(6);
        final totalPrice = priceStr != null ? (double.tryParse(priceStr) ?? 0.0) : 0.0;

        if (totalPrice > 0) {
          items.add(ReceiptItem(
            id: _uuid.v4(),
            name: name,
            quantity: qty,
            unitPrice: totalPrice / qty, // Derived
            totalPrice: totalPrice,
            confidence: 90.0,
          ));
        }
      }
    }
    
    return items;
  }
}
