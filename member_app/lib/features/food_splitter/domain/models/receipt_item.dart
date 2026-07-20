import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt_item.freezed.dart';
part 'receipt_item.g.dart';

@freezed
abstract class ReceiptItem with _$ReceiptItem {
  const factory ReceiptItem({
    required String id,
    required String name,
    required double quantity,
    required double unitPrice,
    required double totalPrice,
    @Default(100.0) double confidence,
    @Default(false) bool isEdited,
    String? category,
  }) = _ReceiptItem;

  factory ReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$ReceiptItemFromJson(json);
}
