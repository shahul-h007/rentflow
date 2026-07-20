class Debt {
  final String fromMemberId;
  final String toMemberId;
  final double amount;

  Debt({
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
  });

  @override
  String toString() => '$fromMemberId owes $toMemberId ₹${amount.toStringAsFixed(2)}';
}
