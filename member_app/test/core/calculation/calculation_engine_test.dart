import 'package:flutter_test/flutter_test.dart';
import 'package:member_app/core/calculation/calculation_engine.dart';
import 'package:member_app/features/food_splitter/domain/models/parsed_receipt.dart';
import 'package:member_app/features/food_splitter/domain/models/receipt_item.dart';
import 'package:member_app/features/food_splitter/domain/models/expense_assignment.dart';

void main() {
  group('CalculationEngine', () {
    test('calculates equal split with proportional GST correctly', () {
      final receipt = ParsedReceipt(
        id: 'r1',
        items: [
          const ReceiptItem(id: 'i1', name: 'Burger', quantity: 1, unitPrice: 100, totalPrice: 100),
          const ReceiptItem(id: 'i2', name: 'Fries', quantity: 1, unitPrice: 50, totalPrice: 50),
        ],
        gst: 15.0, // 10% overall
        grandTotal: 165.0,
      );

      // Alice eats Burger (100)
      // Bob and Charlie split Fries (25 each)
      final assignments = [
        const ExpenseAssignment(id: 'a1', receiptItemId: 'i1', memberId: 'Alice', splitMethod: SplitMethod.equal),
        const ExpenseAssignment(id: 'a2', receiptItemId: 'i2', memberId: 'Bob', splitMethod: SplitMethod.equal),
        const ExpenseAssignment(id: 'a3', receiptItemId: 'i2', memberId: 'Charlie', splitMethod: SplitMethod.equal),
      ];

      final result = CalculationEngine.calculate(receipt: receipt, assignments: assignments);

      expect(result.isValid, isTrue);
      
      final alice = result.members.firstWhere((m) => m.memberId == 'Alice');
      final bob = result.members.firstWhere((m) => m.memberId == 'Bob');
      final charlie = result.members.firstWhere((m) => m.memberId == 'Charlie');

      // Check Base Food
      expect(alice.food, 100.0);
      expect(bob.food, 25.0);
      expect(charlie.food, 25.0);

      // Check Proportional GST (Total GST is 15. Food shares: Alice 100/150, Bob 25/150, Charlie 25/150)
      expect(alice.gst, closeTo(10.0, 0.01));
      expect(bob.gst, closeTo(2.5, 0.01));
      expect(charlie.gst, closeTo(2.5, 0.01));

      // Final Amounts
      expect(alice.finalAmount, closeTo(110.0, 0.01));
      expect(bob.finalAmount, closeTo(27.5, 0.01));
      expect(charlie.finalAmount, closeTo(27.5, 0.01));
    });

    test('round off calculator fixes cent precision drift', () {
      final receipt = ParsedReceipt(
        id: 'r2',
        items: [
          const ReceiptItem(id: 'i1', name: 'Combo', quantity: 1, unitPrice: 100, totalPrice: 100),
        ],
        grandTotal: 100.0, // Let's say it's exactly 100
      );

      // 3 people splitting 100 equally: 33.333... each.
      final assignments = [
        const ExpenseAssignment(id: 'a1', receiptItemId: 'i1', memberId: 'M1', splitMethod: SplitMethod.equal),
        const ExpenseAssignment(id: 'a2', receiptItemId: 'i1', memberId: 'M2', splitMethod: SplitMethod.equal),
        const ExpenseAssignment(id: 'a3', receiptItemId: 'i1', memberId: 'M3', splitMethod: SplitMethod.equal),
      ];

      final result = CalculationEngine.calculate(receipt: receipt, assignments: assignments);

      final m1 = result.members.firstWhere((m) => m.memberId == 'M1');
      final m2 = result.members.firstWhere((m) => m.memberId == 'M2');
      final m3 = result.members.firstWhere((m) => m.memberId == 'M3');

      // Without round off: 33.33 + 33.33 + 33.33 = 99.99 (missing 0.01)
      // RoundOffCalculator should add 0.01 to the first member that had the "largest share" 
      // (in a tie, it picks one).
      final totalCalculated = double.parse(m1.finalAmount.toStringAsFixed(2)) + 
                              double.parse(m2.finalAmount.toStringAsFixed(2)) + 
                              double.parse(m3.finalAmount.toStringAsFixed(2));

      expect(totalCalculated, 100.00); // Must exactly equal grandTotal
    });
  });
}
