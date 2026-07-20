import '../calculation_result.dart';

class ProportionalCalculator {
  static void calculate(Map<String, MemberCalculation> members, double totalFood, {
    required double totalGst,
    required double totalDiscount,
    required double totalServiceCharge,
    required double totalDelivery,
    required double totalTip,
  }) {
    if (totalFood <= 0) return;

    for (final member in members.values) {
      final ratio = member.food / totalFood;

      member.gst = totalGst * ratio;
      member.discount = totalDiscount * ratio;
      member.serviceCharge = totalServiceCharge * ratio;
      member.delivery = totalDelivery * ratio;
      member.tip = totalTip * ratio;
    }
  }
}
