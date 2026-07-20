import '../calculation/calculation_result.dart';
import 'debt.dart';
import 'engine/debt_optimizer.dart';

class SettlementEngine {
  /// Generates optimized debts based on the calculation results and the member who paid.
  /// If the payer is not provided, it assumes there is a pending payment to the "House".
  static List<Debt> generateDebts(CalculationResult result, {String? paidByMemberId}) {
    if (!result.isValid || result.members.isEmpty) return [];

    final rawDebts = <Debt>[];

    if (paidByMemberId != null) {
      // 1. One member paid the entire bill. Everyone owes them their finalAmount.
      for (final member in result.members) {
        if (member.memberId != paidByMemberId && member.finalAmount > 0) {
          rawDebts.add(Debt(
            fromMemberId: member.memberId,
            toMemberId: paidByMemberId,
            amount: member.finalAmount,
          ));
        }
      }
    } else {
      // 2. No payer specified - this means we haven't paid the restaurant yet, or we're pooling.
      // Typically, members owe the "house" or a "pool" account.
      for (final member in result.members) {
        if (member.finalAmount > 0) {
          rawDebts.add(Debt(
            fromMemberId: member.memberId,
            toMemberId: 'HOUSE',
            amount: member.finalAmount,
          ));
        }
      }
    }

    // Pass through optimizer just in case there are overlapping debts
    // (e.g., if we enhance this to handle partial payments later)
    return DebtOptimizer.optimize(rawDebts);
  }
}
