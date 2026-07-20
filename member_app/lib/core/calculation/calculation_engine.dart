import '../../../features/food_splitter/domain/models/parsed_receipt.dart';
import '../../../features/food_splitter/domain/models/expense_assignment.dart';
import 'calculation_result.dart';
import 'calculators/food_calculator.dart';
import 'calculators/proportional_calculator.dart';
import 'calculators/round_off_calculator.dart';

class CalculationEngine {
  static CalculationResult calculate({
    required ParsedReceipt receipt,
    required List<ExpenseAssignment> assignments,
  }) {
    final members = <String, MemberCalculation>{};
    final warnings = <String>[];

    // 1. Calculate Food (Equal, Quantity, Percentage, Manual)
    FoodCalculator.calculate(receipt, assignments, members);

    double totalFood = members.values.fold(0.0, (sum, m) => sum + m.food);

    // If totalFood is 0, we can't properly distribute proportional charges
    if (totalFood <= 0) {
      warnings.add('Total food is zero. Check assignments.');
    } else {
      // 2. Allocate Proportional Charges
      ProportionalCalculator.calculate(
        members, 
        totalFood,
        totalGst: receipt.gst ?? 0.0,
        totalDiscount: receipt.discount ?? 0.0,
        totalServiceCharge: receipt.serviceCharge ?? 0.0,
        totalDelivery: receipt.deliveryCharge ?? 0.0,
        totalTip: receipt.tip ?? 0.0,
      );
    }

    // 3. Round Off and fix decimal drift
    if (receipt.grandTotal != null && receipt.grandTotal! > 0) {
      RoundOffCalculator.calculate(members, receipt.grandTotal!);
    }

    // Validation
    bool isValid = true;
    for (final m in members.values) {
      if (m.finalAmount < 0) {
        isValid = false;
        warnings.add('Member ${m.memberId} has a negative final amount.');
      }
    }

    return CalculationResult(
      members: members.values.toList(),
      isValid: isValid,
      warnings: warnings,
    );
  }
}
