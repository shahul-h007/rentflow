// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParsedReceipt _$ParsedReceiptFromJson(Map<String, dynamic> json) =>
    _ParsedReceipt(
      id: json['id'] as String,
      merchant: json['merchant'] as String?,
      receiptNumber: json['receiptNumber'] as String?,
      date: json['date'] as String?,
      currency: json['currency'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      gst: (json['gst'] as num?)?.toDouble(),
      serviceCharge: (json['serviceCharge'] as num?)?.toDouble(),
      deliveryCharge: (json['deliveryCharge'] as num?)?.toDouble(),
      tip: (json['tip'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      roundOff: (json['roundOff'] as num?)?.toDouble(),
      grandTotal: (json['grandTotal'] as num?)?.toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      houseMemberIds:
          (json['houseMemberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      externalMembers:
          (json['externalMembers'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          const [],
      parserVersion: json['parserVersion'] as String? ?? '1.0.0',
      overallConfidence:
          (json['overallConfidence'] as num?)?.toDouble() ?? 100.0,
    );

Map<String, dynamic> _$ParsedReceiptToJson(_ParsedReceipt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'merchant': instance.merchant,
      'receiptNumber': instance.receiptNumber,
      'date': instance.date,
      'currency': instance.currency,
      'subtotal': instance.subtotal,
      'gst': instance.gst,
      'serviceCharge': instance.serviceCharge,
      'deliveryCharge': instance.deliveryCharge,
      'tip': instance.tip,
      'discount': instance.discount,
      'roundOff': instance.roundOff,
      'grandTotal': instance.grandTotal,
      'items': instance.items,
      'houseMemberIds': instance.houseMemberIds,
      'externalMembers': instance.externalMembers,
      'parserVersion': instance.parserVersion,
      'overallConfidence': instance.overallConfidence,
    };
