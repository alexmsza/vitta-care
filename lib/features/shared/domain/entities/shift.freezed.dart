// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shift.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Shift _$ShiftFromJson(Map<String, dynamic> json) {
  return _Shift.fromJson(json);
}

/// @nodoc
mixin _$Shift {
  String get id => throw _privateConstructorUsedError;
  String get proId => throw _privateConstructorUsedError;
  String get serviceRequestId => throw _privateConstructorUsedError;
  DateTime? get checkIn => throw _privateConstructorUsedError;
  DateTime? get checkOut => throw _privateConstructorUsedError;
  Map<String, dynamic>? get reportData => throw _privateConstructorUsedError;

  /// Serializes this Shift to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShiftCopyWith<Shift> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShiftCopyWith<$Res> {
  factory $ShiftCopyWith(Shift value, $Res Function(Shift) then) =
      _$ShiftCopyWithImpl<$Res, Shift>;
  @useResult
  $Res call(
      {String id,
      String proId,
      String serviceRequestId,
      DateTime? checkIn,
      DateTime? checkOut,
      Map<String, dynamic>? reportData});
}

/// @nodoc
class _$ShiftCopyWithImpl<$Res, $Val extends Shift>
    implements $ShiftCopyWith<$Res> {
  _$ShiftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? proId = null,
    Object? serviceRequestId = null,
    Object? checkIn = freezed,
    Object? checkOut = freezed,
    Object? reportData = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      proId: null == proId
          ? _value.proId
          : proId // ignore: cast_nullable_to_non_nullable
              as String,
      serviceRequestId: null == serviceRequestId
          ? _value.serviceRequestId
          : serviceRequestId // ignore: cast_nullable_to_non_nullable
              as String,
      checkIn: freezed == checkIn
          ? _value.checkIn
          : checkIn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      checkOut: freezed == checkOut
          ? _value.checkOut
          : checkOut // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reportData: freezed == reportData
          ? _value.reportData
          : reportData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShiftImplCopyWith<$Res> implements $ShiftCopyWith<$Res> {
  factory _$$ShiftImplCopyWith(
          _$ShiftImpl value, $Res Function(_$ShiftImpl) then) =
      __$$ShiftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String proId,
      String serviceRequestId,
      DateTime? checkIn,
      DateTime? checkOut,
      Map<String, dynamic>? reportData});
}

/// @nodoc
class __$$ShiftImplCopyWithImpl<$Res>
    extends _$ShiftCopyWithImpl<$Res, _$ShiftImpl>
    implements _$$ShiftImplCopyWith<$Res> {
  __$$ShiftImplCopyWithImpl(
      _$ShiftImpl _value, $Res Function(_$ShiftImpl) _then)
      : super(_value, _then);

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? proId = null,
    Object? serviceRequestId = null,
    Object? checkIn = freezed,
    Object? checkOut = freezed,
    Object? reportData = freezed,
  }) {
    return _then(_$ShiftImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      proId: null == proId
          ? _value.proId
          : proId // ignore: cast_nullable_to_non_nullable
              as String,
      serviceRequestId: null == serviceRequestId
          ? _value.serviceRequestId
          : serviceRequestId // ignore: cast_nullable_to_non_nullable
              as String,
      checkIn: freezed == checkIn
          ? _value.checkIn
          : checkIn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      checkOut: freezed == checkOut
          ? _value.checkOut
          : checkOut // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reportData: freezed == reportData
          ? _value._reportData
          : reportData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShiftImpl implements _Shift {
  const _$ShiftImpl(
      {required this.id,
      required this.proId,
      required this.serviceRequestId,
      this.checkIn,
      this.checkOut,
      final Map<String, dynamic>? reportData})
      : _reportData = reportData;

  factory _$ShiftImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShiftImplFromJson(json);

  @override
  final String id;
  @override
  final String proId;
  @override
  final String serviceRequestId;
  @override
  final DateTime? checkIn;
  @override
  final DateTime? checkOut;
  final Map<String, dynamic>? _reportData;
  @override
  Map<String, dynamic>? get reportData {
    final value = _reportData;
    if (value == null) return null;
    if (_reportData is EqualUnmodifiableMapView) return _reportData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Shift(id: $id, proId: $proId, serviceRequestId: $serviceRequestId, checkIn: $checkIn, checkOut: $checkOut, reportData: $reportData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShiftImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.proId, proId) || other.proId == proId) &&
            (identical(other.serviceRequestId, serviceRequestId) ||
                other.serviceRequestId == serviceRequestId) &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            (identical(other.checkOut, checkOut) ||
                other.checkOut == checkOut) &&
            const DeepCollectionEquality()
                .equals(other._reportData, _reportData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, proId, serviceRequestId,
      checkIn, checkOut, const DeepCollectionEquality().hash(_reportData));

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShiftImplCopyWith<_$ShiftImpl> get copyWith =>
      __$$ShiftImplCopyWithImpl<_$ShiftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShiftImplToJson(
      this,
    );
  }
}

abstract class _Shift implements Shift {
  const factory _Shift(
      {required final String id,
      required final String proId,
      required final String serviceRequestId,
      final DateTime? checkIn,
      final DateTime? checkOut,
      final Map<String, dynamic>? reportData}) = _$ShiftImpl;

  factory _Shift.fromJson(Map<String, dynamic> json) = _$ShiftImpl.fromJson;

  @override
  String get id;
  @override
  String get proId;
  @override
  String get serviceRequestId;
  @override
  DateTime? get checkIn;
  @override
  DateTime? get checkOut;
  @override
  Map<String, dynamic>? get reportData;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShiftImplCopyWith<_$ShiftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
