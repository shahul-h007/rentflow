import '../calculation_result.dart';

class RoundOffCalculator {
  /// Rounds all member totals to 2 decimal places and applies the difference
  /// (if any) to the member with the largest share to ensure exact receipt matching.
  static void calculate(Map<String, MemberCalculation> members, double grandTotal) {
    if (members.isEmpty) return;

    double calculatedTotal = 0.0;
    String? largestMemberId;
    double largestShare = -1.0;

    for (final member in members.values) {
      // Current final amount before rounding off (4 decimal precision theoretically)
      final rawAmount = member.finalAmount;
      
      // We round everything to 2 decimal places in financial apps
      final roundedAmount = double.parse(rawAmount.toStringAsFixed(2));
      
      // Store back the difference inside roundOff just in case, but for now
      // we'll just track the running sum.
      calculatedTotal += roundedAmount;

      if (roundedAmount > largestShare) {
        largestShare = roundedAmount;
        largestMemberId = member.memberId;
      }
    }

    final diff = double.parse((grandTotal - calculatedTotal).toStringAsFixed(2));

    if (diff != 0 && largestMemberId != null) {
      members[largestMemberId]!.roundOff += diff;
    }
  }
}
