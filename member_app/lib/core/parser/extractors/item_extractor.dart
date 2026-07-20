import 'package:uuid/uuid.dart';
import '../../../features/food_splitter/domain/models/receipt_item.dart';

class ItemExtractor {
  static final _uuid = const Uuid();
  
  static final _ignoreKeywords = [
    'gst', 'cgst', 'sgst', 'vat', 'tax', 'total', 'discount', 
    'cash', 'card', 'change', 'subtotal', 'service', 'delivery'
  ];

  // 1. <Name> <Qty> <UnitPrice> <TotalPrice> OR <SlNo> <Name> <Qty> <UnitPrice> <TotalPrice>
  static final _patternFullLine = RegExp(
    r"^(?:\d+\s+)?([a-zA-Z0-9\s\&\.\-\(\)\']+?)\s+(\d+)\s+[0-9]+\.[0-9]{2}\s+([0-9]+\.[0-9]{2})$",
    caseSensitive: false,
  );

  // 2. <Name> <Qty> <Price>
  static final _patternQtyAfterName = RegExp(
    r"^([a-zA-Z0-9\s\&\.\-\(\)\']+?)\s+(?:(?:x\s*(\d+))|(?:(\d+)\s*x)|(?:qty[\s:]*(\d+))|(\d+))?\s*(?:rs\.?|inr|usd|€|£|\$|₹)?\s*([0-9]+\.[0-9]{2})$",
    caseSensitive: false,
  );

  // 3. <Qty> <Name> <Price>
  static final _patternQtyBeforeName = RegExp(
    r"^(\d+)\s+([a-zA-Z0-9\s\&\.\-\(\)\']+?)\s+(?:rs\.?|inr|usd|€|£|\$|₹)?\s*([0-9]+\.[0-9]{2})$",
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

      // Try Pattern 1: Full Line (SlNo Name Qty UnitPrice TotalPrice)
      var match = _patternFullLine.firstMatch(line);
      if (match != null) {
        final name = match.group(1)?.trim();
        final qtyStr = match.group(2);
        final priceStr = match.group(3);
        if (name != null && name.length >= 3 && qtyStr != null && priceStr != null) {
          final qty = double.tryParse(qtyStr) ?? 1.0;
          final totalPrice = double.tryParse(priceStr) ?? 0.0;
          if (totalPrice > 0) {
            items.add(ReceiptItem(id: _uuid.v4(), name: name, quantity: qty, unitPrice: totalPrice / qty, totalPrice: totalPrice, confidence: 90.0));
          }
          continue;
        }
      }

      // Try Pattern 2: Qty AFTER Name
      match = _patternQtyAfterName.firstMatch(line);
      if (match != null) {
        final name = match.group(1)?.trim();
        if (name == null || name.length < 3) continue;

        final qtyStr = match.group(2) ?? match.group(3) ?? match.group(4) ?? match.group(5);
        final qty = qtyStr != null ? (double.tryParse(qtyStr) ?? 1.0) : 1.0;
        final priceStr = match.group(6);
        final totalPrice = priceStr != null ? (double.tryParse(priceStr) ?? 0.0) : 0.0;

        if (totalPrice > 0) {
          items.add(ReceiptItem(id: _uuid.v4(), name: name, quantity: qty, unitPrice: totalPrice / qty, totalPrice: totalPrice, confidence: 90.0));
        }
        continue;
      }

      // Try Pattern 3: Qty BEFORE Name
      match = _patternQtyBeforeName.firstMatch(line);
      if (match != null) {
        final qtyStr = match.group(1);
        final qty = qtyStr != null ? (double.tryParse(qtyStr) ?? 1.0) : 1.0;
        final name = match.group(2)?.trim();
        if (name == null || name.length < 3) continue;
        
        final priceStr = match.group(3);
        final totalPrice = priceStr != null ? (double.tryParse(priceStr) ?? 0.0) : 0.0;

        if (totalPrice > 0) {
          items.add(ReceiptItem(id: _uuid.v4(), name: name, quantity: qty, unitPrice: totalPrice / qty, totalPrice: totalPrice, confidence: 90.0));
        }
      }
    }
    
    return items;
  }
}
