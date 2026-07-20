import 'package:flutter_test/flutter_test.dart';
import 'package:member_app/core/calculation/calculation_result.dart';
import 'package:member_app/core/settlement/settlement_engine.dart';
import 'package:member_app/core/settlement/debt.dart';
import 'package:member_app/core/settlement/engine/debt_optimizer.dart';

void main() {
  group('SettlementEngine', () {
    test('generates raw debts correctly when someone pays', () {
      final result = CalculationResult(
        members: [
          MemberCalculation(memberId: 'A', food: 100)..gst = 10, // A owes 110
          MemberCalculation(memberId: 'B', food: 50)..gst = 5,   // B owes 55
          MemberCalculation(memberId: 'C', food: 50)..gst = 5,   // C owes 55
        ]
      );

      // 'A' paid the bill. So B owes A 55, and C owes A 55.
      final debts = SettlementEngine.generateDebts(result, paidByMemberId: 'A');

      expect(debts.length, 2);
      expect(debts.any((d) => d.fromMemberId == 'B' && d.toMemberId == 'A' && d.amount == 55.0), isTrue);
      expect(debts.any((d) => d.fromMemberId == 'C' && d.toMemberId == 'A' && d.amount == 55.0), isTrue);
    });

    test('DebtOptimizer simplifies overlapping debts', () {
      // A owes B 10
      // B owes C 10
      // Expected optimized: A owes C 10
      final rawDebts = [
        Debt(fromMemberId: 'A', toMemberId: 'B', amount: 10.0),
        Debt(fromMemberId: 'B', toMemberId: 'C', amount: 10.0),
      ];

      final optimized = DebtOptimizer.optimize(rawDebts);

      expect(optimized.length, 1);
      expect(optimized[0].fromMemberId, 'A');
      expect(optimized[0].toMemberId, 'C');
      expect(optimized[0].amount, 10.0);
    });

    test('DebtOptimizer simplifies circular debts', () {
      // A owes B 10
      // B owes C 10
      // C owes A 10
      // Expected optimized: 0 transactions (everyone cancels out)
      final rawDebts = [
        Debt(fromMemberId: 'A', toMemberId: 'B', amount: 10.0),
        Debt(fromMemberId: 'B', toMemberId: 'C', amount: 10.0),
        Debt(fromMemberId: 'C', toMemberId: 'A', amount: 10.0),
      ];

      final optimized = DebtOptimizer.optimize(rawDebts);

      expect(optimized.isEmpty, isTrue);
    });
  });
}
