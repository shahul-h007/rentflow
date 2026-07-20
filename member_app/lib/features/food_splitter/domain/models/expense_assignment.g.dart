// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpenseAssignment _$ExpenseAssignmentFromJson(Map<String, dynamic> json) =>
    _ExpenseAssignment(
      id: json['id'] as String,
      receiptItemId: json['receiptItemId'] as String,
      memberId: json['memberId'] as String,
      splitMethod:
          $enumDecodeNullable(_$SplitMethodEnumMap, json['splitMethod']) ??
          SplitMethod.equal,
      quantity: (json['quantity'] as num?)?.toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      amount: (json['amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ExpenseAssignmentToJson(_ExpenseAssignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'receiptItemId': instance.receiptItemId,
      'memberId': instance.memberId,
      'splitMethod': _$SplitMethodEnumMap[instance.splitMethod]!,
      'quantity': instance.quantity,
      'percentage': instance.percentage,
      'amount': instance.amount,
    };

const _$SplitMethodEnumMap = {
  SplitMethod.equal: 'equal',
  SplitMethod.quantity: 'quantity',
  SplitMethod.percentage: 'percentage',
  SplitMethod.manual: 'manual',
};
