import '../../../features/food_splitter/domain/models/parsed_receipt.dart';
import '../../../features/food_splitter/domain/models/expense_assignment.dart';
import '../calculation_result.dart';

class FoodCalculator {
  static void calculate(ParsedReceipt receipt, List<ExpenseAssignment> assignments, Map<String, MemberCalculation> members) {
    for (final item in receipt.items) {
      final itemAssignments = assignments.where((a) => a.receiptItemId == item.id).toList();
      if (itemAssignments.isEmpty) continue;

      // Ensure all members exist in the map
      for (final a in itemAssignments) {
        members.putIfAbsent(a.memberId, () => MemberCalculation(memberId: a.memberId));
      }

      // Group by split method (assuming all assignments for an item share the same split method)
      final splitMethod = itemAssignments.first.splitMethod;

      switch (splitMethod) {
        case SplitMethod.equal:
          final splitAmount = item.totalPrice / itemAssignments.length;
          for (final a in itemAssignments) {
            members[a.memberId]!.food += splitAmount;
          }
          break;
        case SplitMethod.quantity:
          // In quantity split, they split based on assigned quantities
          double totalAssignedQty = itemAssignments.fold(0.0, (sum, a) => sum + (a.quantity ?? 1.0));
          if (totalAssignedQty > 0) {
            for (final a in itemAssignments) {
              final ratio = (a.quantity ?? 1.0) / totalAssignedQty;
              members[a.memberId]!.food += item.totalPrice * ratio;
            }
          }
          break;
        case SplitMethod.percentage:
          for (final a in itemAssignments) {
            final pct = a.percentage ?? 0.0;
            members[a.memberId]!.food += item.totalPrice * (pct / 100.0);
          }
          break;
        case SplitMethod.manual:
          for (final a in itemAssignments) {
            members[a.memberId]!.food += a.amount ?? 0.0;
          }
          break;
      }
    }
  }
}
