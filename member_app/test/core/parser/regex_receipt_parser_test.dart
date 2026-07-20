import 'package:flutter_test/flutter_test.dart';
import 'package:member_app/core/parser/regex_receipt_parser.dart';

void main() {
  group('RegexReceiptParser', () {
    test('parses a standard restaurant receipt correctly', () {
      const mockOcrText = '''
ABC FAMILY RESTAURANT
123 Main Street
Bill No: 1024
Date: 19/07/2026

Chicken Burger x2 360.00
French Fries 1 120.00
Coke 2 80.00

Subtotal 560.00
CGST 14.00
SGST 14.00
Service Charge 20.00

Grand Total 608.00
Thank you for visiting!
''';

      final receipt = RegexReceiptParser.parse(mockOcrText);

      expect(receipt.merchant, 'ABC FAMILY RESTAURANT');
      expect(receipt.receiptNumber, '1024');
      expect(receipt.date, '19/07/2026');
      
      expect(receipt.items.length, 3);
      
      expect(receipt.items[0].name, 'Chicken Burger');
      expect(receipt.items[0].quantity, 2.0);
      expect(receipt.items[0].totalPrice, 360.0);
      expect(receipt.items[0].unitPrice, 180.0);

      expect(receipt.items[1].name, 'French Fries');
      expect(receipt.items[1].quantity, 1.0);
      expect(receipt.items[1].totalPrice, 120.0);

      expect(receipt.items[2].name, 'Coke');
      expect(receipt.items[2].quantity, 2.0);
      expect(receipt.items[2].totalPrice, 80.0);

      expect(receipt.gst, 28.0); // 14.00 + 14.00
      expect(receipt.grandTotal, 608.0);
    });

    test('handles missing or poorly formatted data', () {
      const messyOcrText = '''
Just some random text
No obvious totals
''';
      final receipt = RegexReceiptParser.parse(messyOcrText);

      expect(receipt.merchant, 'Just some random text'); // First line
      expect(receipt.receiptNumber, isNull);
      expect(receipt.items, isEmpty);
      expect(receipt.gst, 0.0);
      expect(receipt.grandTotal, isNull);
      expect(receipt.overallConfidence, lessThan(100.0));
    });
  });
}
