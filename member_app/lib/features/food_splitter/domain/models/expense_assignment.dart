import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_assignment.freezed.dart';
part 'expense_assignment.g.dart';

enum SplitMethod { equal, quantity, percentage, manual }

@freezed
abstract class ExpenseAssignment with _$ExpenseAssignment {
  const factory ExpenseAssignment({
    required String id,
    required String receiptItemId,
    required String memberId,
    @Default(SplitMethod.equal) SplitMethod splitMethod,
    double? quantity,
    double? percentage,
    double? amount,
  }) = _ExpenseAssignment;

  factory ExpenseAssignment.fromJson(Map<String, dynamic> json) =>
      _$ExpenseAssignmentFromJson(json);
}
