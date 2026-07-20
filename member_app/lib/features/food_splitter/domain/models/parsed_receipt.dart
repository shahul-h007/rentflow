import 'package:freezed_annotation/freezed_annotation.dart';
import 'receipt_item.dart';

part 'parsed_receipt.freezed.dart';
part 'parsed_receipt.g.dart';

@freezed
abstract class ParsedReceipt with _$ParsedReceipt {
  const factory ParsedReceipt({
    required String id,
    String? merchant,
    String? receiptNumber,
    String? date,
    String? currency,
    double? subtotal,
    double? gst,
    double? serviceCharge,
    double? deliveryCharge,
    double? tip,
    double? discount,
    double? roundOff,
    double? grandTotal,
    required List<ReceiptItem> items,
    @Default('1.0.0') String parserVersion,
    @Default(100.0) double overallConfidence,
  }) = _ParsedReceipt;

  factory ParsedReceipt.fromJson(Map<String, dynamic> json) =>
      _$ParsedReceiptFromJson(json);
}
