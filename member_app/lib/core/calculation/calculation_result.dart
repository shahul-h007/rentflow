class MemberCalculation {
  final String memberId;
  double food;
  double gst;
  double discount;
  double serviceCharge;
  double delivery;
  double tip;
  double roundOff;
  
  MemberCalculation({
    required this.memberId,
    this.food = 0.0,
    this.gst = 0.0,
    this.discount = 0.0,
    this.serviceCharge = 0.0,
    this.delivery = 0.0,
    this.tip = 0.0,
    this.roundOff = 0.0,
  });

  double get finalAmount => food + gst + serviceCharge + delivery + tip - discount + roundOff;
}

class CalculationResult {
  final List<MemberCalculation> members;
  final bool isValid;
  final List<String> warnings;

  CalculationResult({
    required this.members,
    this.isValid = true,
    this.warnings = const [],
  });
}
