// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParsedReceipt {

 String get id; String? get merchant; String? get receiptNumber; String? get date; String? get currency; double? get subtotal; double? get gst; double? get serviceCharge; double? get deliveryCharge; double? get tip; double? get discount; double? get roundOff; double? get grandTotal; List<ReceiptItem> get items; List<String> get houseMemberIds; List<Map<String, String>> get externalMembers; String get parserVersion; double get overallConfidence;
/// Create a copy of ParsedReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedReceiptCopyWith<ParsedReceipt> get copyWith => _$ParsedReceiptCopyWithImpl<ParsedReceipt>(this as ParsedReceipt, _$identity);

  /// Serializes this ParsedReceipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.date, date) || other.date == date)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.gst, gst) || other.gst == gst)&&(identical(other.serviceCharge, serviceCharge) || other.serviceCharge == serviceCharge)&&(identical(other.deliveryCharge, deliveryCharge) || other.deliveryCharge == deliveryCharge)&&(identical(other.tip, tip) || other.tip == tip)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.roundOff, roundOff) || other.roundOff == roundOff)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.houseMemberIds, houseMemberIds)&&const DeepCollectionEquality().equals(other.externalMembers, externalMembers)&&(identical(other.parserVersion, parserVersion) || other.parserVersion == parserVersion)&&(identical(other.overallConfidence, overallConfidence) || other.overallConfidence == overallConfidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,merchant,receiptNumber,date,currency,subtotal,gst,serviceCharge,deliveryCharge,tip,discount,roundOff,grandTotal,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(houseMemberIds),const DeepCollectionEquality().hash(externalMembers),parserVersion,overallConfidence);

@override
String toString() {
  return 'ParsedReceipt(id: $id, merchant: $merchant, receiptNumber: $receiptNumber, date: $date, currency: $currency, subtotal: $subtotal, gst: $gst, serviceCharge: $serviceCharge, deliveryCharge: $deliveryCharge, tip: $tip, discount: $discount, roundOff: $roundOff, grandTotal: $grandTotal, items: $items, houseMemberIds: $houseMemberIds, externalMembers: $externalMembers, parserVersion: $parserVersion, overallConfidence: $overallConfidence)';
}


}

/// @nodoc
abstract mixin class $ParsedReceiptCopyWith<$Res>  {
  factory $ParsedReceiptCopyWith(ParsedReceipt value, $Res Function(ParsedReceipt) _then) = _$ParsedReceiptCopyWithImpl;
@useResult
$Res call({
 String id, String? merchant, String? receiptNumber, String? date, String? currency, double? subtotal, double? gst, double? serviceCharge, double? deliveryCharge, double? tip, double? discount, double? roundOff, double? grandTotal, List<ReceiptItem> items, List<String> houseMemberIds, List<Map<String, String>> externalMembers, String parserVersion, double overallConfidence
});




}
/// @nodoc
class _$ParsedReceiptCopyWithImpl<$Res>
    implements $ParsedReceiptCopyWith<$Res> {
  _$ParsedReceiptCopyWithImpl(this._self, this._then);

  final ParsedReceipt _self;
  final $Res Function(ParsedReceipt) _then;

/// Create a copy of ParsedReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? merchant = freezed,Object? receiptNumber = freezed,Object? date = freezed,Object? currency = freezed,Object? subtotal = freezed,Object? gst = freezed,Object? serviceCharge = freezed,Object? deliveryCharge = freezed,Object? tip = freezed,Object? discount = freezed,Object? roundOff = freezed,Object? grandTotal = freezed,Object? items = null,Object? houseMemberIds = null,Object? externalMembers = null,Object? parserVersion = null,Object? overallConfidence = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,receiptNumber: freezed == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,subtotal: freezed == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double?,gst: freezed == gst ? _self.gst : gst // ignore: cast_nullable_to_non_nullable
as double?,serviceCharge: freezed == serviceCharge ? _self.serviceCharge : serviceCharge // ignore: cast_nullable_to_non_nullable
as double?,deliveryCharge: freezed == deliveryCharge ? _self.deliveryCharge : deliveryCharge // ignore: cast_nullable_to_non_nullable
as double?,tip: freezed == tip ? _self.tip : tip // ignore: cast_nullable_to_non_nullable
as double?,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,roundOff: freezed == roundOff ? _self.roundOff : roundOff // ignore: cast_nullable_to_non_nullable
as double?,grandTotal: freezed == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ReceiptItem>,houseMemberIds: null == houseMemberIds ? _self.houseMemberIds : houseMemberIds // ignore: cast_nullable_to_non_nullable
as List<String>,externalMembers: null == externalMembers ? _self.externalMembers : externalMembers // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>,parserVersion: null == parserVersion ? _self.parserVersion : parserVersion // ignore: cast_nullable_to_non_nullable
as String,overallConfidence: null == overallConfidence ? _self.overallConfidence : overallConfidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedReceipt].
extension ParsedReceiptPatterns on ParsedReceipt {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedReceipt() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedReceipt value)  $default,){
final _that = this;
switch (_that) {
case _ParsedReceipt():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedReceipt() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? merchant,  String? receiptNumber,  String? date,  String? currency,  double? subtotal,  double? gst,  double? serviceCharge,  double? deliveryCharge,  double? tip,  double? discount,  double? roundOff,  double? grandTotal,  List<ReceiptItem> items,  List<String> houseMemberIds,  List<Map<String, String>> externalMembers,  String parserVersion,  double overallConfidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedReceipt() when $default != null:
return $default(_that.id,_that.merchant,_that.receiptNumber,_that.date,_that.currency,_that.subtotal,_that.gst,_that.serviceCharge,_that.deliveryCharge,_that.tip,_that.discount,_that.roundOff,_that.grandTotal,_that.items,_that.houseMemberIds,_that.externalMembers,_that.parserVersion,_that.overallConfidence);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? merchant,  String? receiptNumber,  String? date,  String? currency,  double? subtotal,  double? gst,  double? serviceCharge,  double? deliveryCharge,  double? tip,  double? discount,  double? roundOff,  double? grandTotal,  List<ReceiptItem> items,  List<String> houseMemberIds,  List<Map<String, String>> externalMembers,  String parserVersion,  double overallConfidence)  $default,) {final _that = this;
switch (_that) {
case _ParsedReceipt():
return $default(_that.id,_that.merchant,_that.receiptNumber,_that.date,_that.currency,_that.subtotal,_that.gst,_that.serviceCharge,_that.deliveryCharge,_that.tip,_that.discount,_that.roundOff,_that.grandTotal,_that.items,_that.houseMemberIds,_that.externalMembers,_that.parserVersion,_that.overallConfidence);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? merchant,  String? receiptNumber,  String? date,  String? currency,  double? subtotal,  double? gst,  double? serviceCharge,  double? deliveryCharge,  double? tip,  double? discount,  double? roundOff,  double? grandTotal,  List<ReceiptItem> items,  List<String> houseMemberIds,  List<Map<String, String>> externalMembers,  String parserVersion,  double overallConfidence)?  $default,) {final _that = this;
switch (_that) {
case _ParsedReceipt() when $default != null:
return $default(_that.id,_that.merchant,_that.receiptNumber,_that.date,_that.currency,_that.subtotal,_that.gst,_that.serviceCharge,_that.deliveryCharge,_that.tip,_that.discount,_that.roundOff,_that.grandTotal,_that.items,_that.houseMemberIds,_that.externalMembers,_that.parserVersion,_that.overallConfidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedReceipt implements ParsedReceipt {
  const _ParsedReceipt({required this.id, this.merchant, this.receiptNumber, this.date, this.currency, this.subtotal, this.gst, this.serviceCharge, this.deliveryCharge, this.tip, this.discount, this.roundOff, this.grandTotal, required final  List<ReceiptItem> items, final  List<String> houseMemberIds = const [], final  List<Map<String, String>> externalMembers = const [], this.parserVersion = '1.0.0', this.overallConfidence = 100.0}): _items = items,_houseMemberIds = houseMemberIds,_externalMembers = externalMembers;
  factory _ParsedReceipt.fromJson(Map<String, dynamic> json) => _$ParsedReceiptFromJson(json);

@override final  String id;
@override final  String? merchant;
@override final  String? receiptNumber;
@override final  String? date;
@override final  String? currency;
@override final  double? subtotal;
@override final  double? gst;
@override final  double? serviceCharge;
@override final  double? deliveryCharge;
@override final  double? tip;
@override final  double? discount;
@override final  double? roundOff;
@override final  double? grandTotal;
 final  List<ReceiptItem> _items;
@override List<ReceiptItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<String> _houseMemberIds;
@override@JsonKey() List<String> get houseMemberIds {
  if (_houseMemberIds is EqualUnmodifiableListView) return _houseMemberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_houseMemberIds);
}

 final  List<Map<String, String>> _externalMembers;
@override@JsonKey() List<Map<String, String>> get externalMembers {
  if (_externalMembers is EqualUnmodifiableListView) return _externalMembers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_externalMembers);
}

@override@JsonKey() final  String parserVersion;
@override@JsonKey() final  double overallConfidence;

/// Create a copy of ParsedReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedReceiptCopyWith<_ParsedReceipt> get copyWith => __$ParsedReceiptCopyWithImpl<_ParsedReceipt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParsedReceiptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.date, date) || other.date == date)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.gst, gst) || other.gst == gst)&&(identical(other.serviceCharge, serviceCharge) || other.serviceCharge == serviceCharge)&&(identical(other.deliveryCharge, deliveryCharge) || other.deliveryCharge == deliveryCharge)&&(identical(other.tip, tip) || other.tip == tip)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.roundOff, roundOff) || other.roundOff == roundOff)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._houseMemberIds, _houseMemberIds)&&const DeepCollectionEquality().equals(other._externalMembers, _externalMembers)&&(identical(other.parserVersion, parserVersion) || other.parserVersion == parserVersion)&&(identical(other.overallConfidence, overallConfidence) || other.overallConfidence == overallConfidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,merchant,receiptNumber,date,currency,subtotal,gst,serviceCharge,deliveryCharge,tip,discount,roundOff,grandTotal,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_houseMemberIds),const DeepCollectionEquality().hash(_externalMembers),parserVersion,overallConfidence);

@override
String toString() {
  return 'ParsedReceipt(id: $id, merchant: $merchant, receiptNumber: $receiptNumber, date: $date, currency: $currency, subtotal: $subtotal, gst: $gst, serviceCharge: $serviceCharge, deliveryCharge: $deliveryCharge, tip: $tip, discount: $discount, roundOff: $roundOff, grandTotal: $grandTotal, items: $items, houseMemberIds: $houseMemberIds, externalMembers: $externalMembers, parserVersion: $parserVersion, overallConfidence: $overallConfidence)';
}


}

/// @nodoc
abstract mixin class _$ParsedReceiptCopyWith<$Res> implements $ParsedReceiptCopyWith<$Res> {
  factory _$ParsedReceiptCopyWith(_ParsedReceipt value, $Res Function(_ParsedReceipt) _then) = __$ParsedReceiptCopyWithImpl;
@override @useResult
$Res call({
 String id, String? merchant, String? receiptNumber, String? date, String? currency, double? subtotal, double? gst, double? serviceCharge, double? deliveryCharge, double? tip, double? discount, double? roundOff, double? grandTotal, List<ReceiptItem> items, List<String> houseMemberIds, List<Map<String, String>> externalMembers, String parserVersion, double overallConfidence
});




}
/// @nodoc
class __$ParsedReceiptCopyWithImpl<$Res>
    implements _$ParsedReceiptCopyWith<$Res> {
  __$ParsedReceiptCopyWithImpl(this._self, this._then);

  final _ParsedReceipt _self;
  final $Res Function(_ParsedReceipt) _then;

/// Create a copy of ParsedReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? merchant = freezed,Object? receiptNumber = freezed,Object? date = freezed,Object? currency = freezed,Object? subtotal = freezed,Object? gst = freezed,Object? serviceCharge = freezed,Object? deliveryCharge = freezed,Object? tip = freezed,Object? discount = freezed,Object? roundOff = freezed,Object? grandTotal = freezed,Object? items = null,Object? houseMemberIds = null,Object? externalMembers = null,Object? parserVersion = null,Object? overallConfidence = null,}) {
  return _then(_ParsedReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,receiptNumber: freezed == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,subtotal: freezed == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double?,gst: freezed == gst ? _self.gst : gst // ignore: cast_nullable_to_non_nullable
as double?,serviceCharge: freezed == serviceCharge ? _self.serviceCharge : serviceCharge // ignore: cast_nullable_to_non_nullable
as double?,deliveryCharge: freezed == deliveryCharge ? _self.deliveryCharge : deliveryCharge // ignore: cast_nullable_to_non_nullable
as double?,tip: freezed == tip ? _self.tip : tip // ignore: cast_nullable_to_non_nullable
as double?,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,roundOff: freezed == roundOff ? _self.roundOff : roundOff // ignore: cast_nullable_to_non_nullable
as double?,grandTotal: freezed == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ReceiptItem>,houseMemberIds: null == houseMemberIds ? _self._houseMemberIds : houseMemberIds // ignore: cast_nullable_to_non_nullable
as List<String>,externalMembers: null == externalMembers ? _self._externalMembers : externalMembers // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>,parserVersion: null == parserVersion ? _self.parserVersion : parserVersion // ignore: cast_nullable_to_non_nullable
as String,overallConfidence: null == overallConfidence ? _self.overallConfidence : overallConfidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
