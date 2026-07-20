// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReceiptItem _$ReceiptItemFromJson(Map<String, dynamic> json) => _ReceiptItem(
  id: json['id'] as String,
  name: json['name'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  confidence: (json['confidence'] as num?)?.toDouble() ?? 100.0,
  isEdited: json['isEdited'] as bool? ?? false,
  category: json['category'] as String?,
);

Map<String, dynamic> _$ReceiptItemToJson(_ReceiptItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'confidence': instance.confidence,
      'isEdited': instance.isEdited,
      'category': instance.category,
    };
