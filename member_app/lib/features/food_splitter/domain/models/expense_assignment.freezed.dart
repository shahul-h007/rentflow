// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpenseAssignment {

 String get id; String get receiptItemId; String get memberId; SplitMethod get splitMethod; double? get quantity; double? get percentage; double? get amount;
/// Create a copy of ExpenseAssignment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseAssignmentCopyWith<ExpenseAssignment> get copyWith => _$ExpenseAssignmentCopyWithImpl<ExpenseAssignment>(this as ExpenseAssignment, _$identity);

  /// Serializes this ExpenseAssignment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.receiptItemId, receiptItemId) || other.receiptItemId == receiptItemId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.splitMethod, splitMethod) || other.splitMethod == splitMethod)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,receiptItemId,memberId,splitMethod,quantity,percentage,amount);

@override
String toString() {
  return 'ExpenseAssignment(id: $id, receiptItemId: $receiptItemId, memberId: $memberId, splitMethod: $splitMethod, quantity: $quantity, percentage: $percentage, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $ExpenseAssignmentCopyWith<$Res>  {
  factory $ExpenseAssignmentCopyWith(ExpenseAssignment value, $Res Function(ExpenseAssignment) _then) = _$ExpenseAssignmentCopyWithImpl;
@useResult
$Res call({
 String id, String receiptItemId, String memberId, SplitMethod splitMethod, double? quantity, double? percentage, double? amount
});




}
/// @nodoc
class _$ExpenseAssignmentCopyWithImpl<$Res>
    implements $ExpenseAssignmentCopyWith<$Res> {
  _$ExpenseAssignmentCopyWithImpl(this._self, this._then);

  final ExpenseAssignment _self;
  final $Res Function(ExpenseAssignment) _then;

/// Create a copy of ExpenseAssignment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? receiptItemId = null,Object? memberId = null,Object? splitMethod = null,Object? quantity = freezed,Object? percentage = freezed,Object? amount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,receiptItemId: null == receiptItemId ? _self.receiptItemId : receiptItemId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,splitMethod: null == splitMethod ? _self.splitMethod : splitMethod // ignore: cast_nullable_to_non_nullable
as SplitMethod,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double?,percentage: freezed == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseAssignment].
extension ExpenseAssignmentPatterns on ExpenseAssignment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseAssignment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseAssignment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseAssignment value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseAssignment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseAssignment value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseAssignment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String receiptItemId,  String memberId,  SplitMethod splitMethod,  double? quantity,  double? percentage,  double? amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseAssignment() when $default != null:
return $default(_that.id,_that.receiptItemId,_that.memberId,_that.splitMethod,_that.quantity,_that.percentage,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String receiptItemId,  String memberId,  SplitMethod splitMethod,  double? quantity,  double? percentage,  double? amount)  $default,) {final _that = this;
switch (_that) {
case _ExpenseAssignment():
return $default(_that.id,_that.receiptItemId,_that.memberId,_that.splitMethod,_that.quantity,_that.percentage,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String receiptItemId,  String memberId,  SplitMethod splitMethod,  double? quantity,  double? percentage,  double? amount)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseAssignment() when $default != null:
return $default(_that.id,_that.receiptItemId,_that.memberId,_that.splitMethod,_that.quantity,_that.percentage,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpenseAssignment implements ExpenseAssignment {
  const _ExpenseAssignment({required this.id, required this.receiptItemId, required this.memberId, this.splitMethod = SplitMethod.equal, this.quantity, this.percentage, this.amount});
  factory _ExpenseAssignment.fromJson(Map<String, dynamic> json) => _$ExpenseAssignmentFromJson(json);

@override final  String id;
@override final  String receiptItemId;
@override final  String memberId;
@override@JsonKey() final  SplitMethod splitMethod;
@override final  double? quantity;
@override final  double? percentage;
@override final  double? amount;

/// Create a copy of ExpenseAssignment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseAssignmentCopyWith<_ExpenseAssignment> get copyWith => __$ExpenseAssignmentCopyWithImpl<_ExpenseAssignment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseAssignmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.receiptItemId, receiptItemId) || other.receiptItemId == receiptItemId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.splitMethod, splitMethod) || other.splitMethod == splitMethod)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,receiptItemId,memberId,splitMethod,quantity,percentage,amount);

@override
String toString() {
  return 'ExpenseAssignment(id: $id, receiptItemId: $receiptItemId, memberId: $memberId, splitMethod: $splitMethod, quantity: $quantity, percentage: $percentage, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$ExpenseAssignmentCopyWith<$Res> implements $ExpenseAssignmentCopyWith<$Res> {
  factory _$ExpenseAssignmentCopyWith(_ExpenseAssignment value, $Res Function(_ExpenseAssignment) _then) = __$ExpenseAssignmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String receiptItemId, String memberId, SplitMethod splitMethod, double? quantity, double? percentage, double? amount
});




}
/// @nodoc
class __$ExpenseAssignmentCopyWithImpl<$Res>
    implements _$ExpenseAssignmentCopyWith<$Res> {
  __$ExpenseAssignmentCopyWithImpl(this._self, this._then);

  final _ExpenseAssignment _self;
  final $Res Function(_ExpenseAssignment) _then;

/// Create a copy of ExpenseAssignment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? receiptItemId = null,Object? memberId = null,Object? splitMethod = null,Object? quantity = freezed,Object? percentage = freezed,Object? amount = freezed,}) {
  return _then(_ExpenseAssignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,receiptItemId: null == receiptItemId ? _self.receiptItemId : receiptItemId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,splitMethod: null == splitMethod ? _self.splitMethod : splitMethod // ignore: cast_nullable_to_non_nullable
as SplitMethod,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double?,percentage: freezed == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
