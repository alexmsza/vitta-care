// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServiceRequest _$ServiceRequestFromJson(Map<String, dynamic> json) {
  return _ServiceRequest.fromJson(json);
}

/// @nodoc
mixin _$ServiceRequest {
  String get id => throw _privateConstructorUsedError;
  String get familyId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  ServiceDuration get duration => throw _privateConstructorUsedError;
  List<String> get tags =>
      throw _privateConstructorUsedError; // ex: ['Acamado', 'Lúcido']
  RequestStatus get status => throw _privateConstructorUsedError;
  double get priceTotal => throw _privateConstructorUsedError;
  String? get assignedProId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String get patientName => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this ServiceRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceRequestCopyWith<ServiceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceRequestCopyWith<$Res> {
  factory $ServiceRequestCopyWith(
          ServiceRequest value, $Res Function(ServiceRequest) then) =
      _$ServiceRequestCopyWithImpl<$Res, ServiceRequest>;
  @useResult
  $Res call(
      {String id,
      String familyId,
      DateTime date,
      ServiceDuration duration,
      List<String> tags,
      RequestStatus status,
      double priceTotal,
      String? assignedProId,
      DateTime? createdAt,
      String patientName,
      String description});
}

/// @nodoc
class _$ServiceRequestCopyWithImpl<$Res, $Val extends ServiceRequest>
    implements $ServiceRequestCopyWith<$Res> {
  _$ServiceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? familyId = null,
    Object? date = null,
    Object? duration = null,
    Object? tags = null,
    Object? status = null,
    Object? priceTotal = null,
    Object? assignedProId = freezed,
    Object? createdAt = freezed,
    Object? patientName = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      familyId: null == familyId
          ? _value.familyId
          : familyId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as ServiceDuration,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RequestStatus,
      priceTotal: null == priceTotal
          ? _value.priceTotal
          : priceTotal // ignore: cast_nullable_to_non_nullable
              as double,
      assignedProId: freezed == assignedProId
          ? _value.assignedProId
          : assignedProId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      patientName: null == patientName
          ? _value.patientName
          : patientName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServiceRequestImplCopyWith<$Res>
    implements $ServiceRequestCopyWith<$Res> {
  factory _$$ServiceRequestImplCopyWith(_$ServiceRequestImpl value,
          $Res Function(_$ServiceRequestImpl) then) =
      __$$ServiceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String familyId,
      DateTime date,
      ServiceDuration duration,
      List<String> tags,
      RequestStatus status,
      double priceTotal,
      String? assignedProId,
      DateTime? createdAt,
      String patientName,
      String description});
}

/// @nodoc
class __$$ServiceRequestImplCopyWithImpl<$Res>
    extends _$ServiceRequestCopyWithImpl<$Res, _$ServiceRequestImpl>
    implements _$$ServiceRequestImplCopyWith<$Res> {
  __$$ServiceRequestImplCopyWithImpl(
      _$ServiceRequestImpl _value, $Res Function(_$ServiceRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? familyId = null,
    Object? date = null,
    Object? duration = null,
    Object? tags = null,
    Object? status = null,
    Object? priceTotal = null,
    Object? assignedProId = freezed,
    Object? createdAt = freezed,
    Object? patientName = null,
    Object? description = null,
  }) {
    return _then(_$ServiceRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      familyId: null == familyId
          ? _value.familyId
          : familyId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as ServiceDuration,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RequestStatus,
      priceTotal: null == priceTotal
          ? _value.priceTotal
          : priceTotal // ignore: cast_nullable_to_non_nullable
              as double,
      assignedProId: freezed == assignedProId
          ? _value.assignedProId
          : assignedProId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      patientName: null == patientName
          ? _value.patientName
          : patientName // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceRequestImpl implements _ServiceRequest {
  const _$ServiceRequestImpl(
      {required this.id,
      required this.familyId,
      required this.date,
      required this.duration,
      final List<String> tags = const [],
      this.status = RequestStatus.open,
      required this.priceTotal,
      this.assignedProId,
      this.createdAt,
      this.patientName = 'Paciente Vitta',
      this.description = 'Descrição do quadro clínico...'})
      : _tags = tags;

  factory _$ServiceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String familyId;
  @override
  final DateTime date;
  @override
  final ServiceDuration duration;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

// ex: ['Acamado', 'Lúcido']
  @override
  @JsonKey()
  final RequestStatus status;
  @override
  final double priceTotal;
  @override
  final String? assignedProId;
  @override
  final DateTime? createdAt;
  @override
  @JsonKey()
  final String patientName;
  @override
  @JsonKey()
  final String description;

  @override
  String toString() {
    return 'ServiceRequest(id: $id, familyId: $familyId, date: $date, duration: $duration, tags: $tags, status: $status, priceTotal: $priceTotal, assignedProId: $assignedProId, createdAt: $createdAt, patientName: $patientName, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.familyId, familyId) ||
                other.familyId == familyId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priceTotal, priceTotal) ||
                other.priceTotal == priceTotal) &&
            (identical(other.assignedProId, assignedProId) ||
                other.assignedProId == assignedProId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      familyId,
      date,
      duration,
      const DeepCollectionEquality().hash(_tags),
      status,
      priceTotal,
      assignedProId,
      createdAt,
      patientName,
      description);

  /// Create a copy of ServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceRequestImplCopyWith<_$ServiceRequestImpl> get copyWith =>
      __$$ServiceRequestImplCopyWithImpl<_$ServiceRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceRequestImplToJson(
      this,
    );
  }
}

abstract class _ServiceRequest implements ServiceRequest {
  const factory _ServiceRequest(
      {required final String id,
      required final String familyId,
      required final DateTime date,
      required final ServiceDuration duration,
      final List<String> tags,
      final RequestStatus status,
      required final double priceTotal,
      final String? assignedProId,
      final DateTime? createdAt,
      final String patientName,
      final String description}) = _$ServiceRequestImpl;

  factory _ServiceRequest.fromJson(Map<String, dynamic> json) =
      _$ServiceRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get familyId;
  @override
  DateTime get date;
  @override
  ServiceDuration get duration;
  @override
  List<String> get tags; // ex: ['Acamado', 'Lúcido']
  @override
  RequestStatus get status;
  @override
  double get priceTotal;
  @override
  String? get assignedProId;
  @override
  DateTime? get createdAt;
  @override
  String get patientName;
  @override
  String get description;

  /// Create a copy of ServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceRequestImplCopyWith<_$ServiceRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
