// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_request_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ServiceRequestState {
  DateTime? get selectedDate => throw _privateConstructorUsedError;
  TimeOfDay? get selectedTime => throw _privateConstructorUsedError;
  ServiceDuration get duration => throw _privateConstructorUsedError;
  List<String> get selectedTags => throw _privateConstructorUsedError;

  /// Create a copy of ServiceRequestState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceRequestStateCopyWith<ServiceRequestState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceRequestStateCopyWith<$Res> {
  factory $ServiceRequestStateCopyWith(
          ServiceRequestState value, $Res Function(ServiceRequestState) then) =
      _$ServiceRequestStateCopyWithImpl<$Res, ServiceRequestState>;
  @useResult
  $Res call(
      {DateTime? selectedDate,
      TimeOfDay? selectedTime,
      ServiceDuration duration,
      List<String> selectedTags});
}

/// @nodoc
class _$ServiceRequestStateCopyWithImpl<$Res, $Val extends ServiceRequestState>
    implements $ServiceRequestStateCopyWith<$Res> {
  _$ServiceRequestStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceRequestState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = freezed,
    Object? selectedTime = freezed,
    Object? duration = null,
    Object? selectedTags = null,
  }) {
    return _then(_value.copyWith(
      selectedDate: freezed == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      selectedTime: freezed == selectedTime
          ? _value.selectedTime
          : selectedTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay?,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as ServiceDuration,
      selectedTags: null == selectedTags
          ? _value.selectedTags
          : selectedTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServiceRequestStateImplCopyWith<$Res>
    implements $ServiceRequestStateCopyWith<$Res> {
  factory _$$ServiceRequestStateImplCopyWith(_$ServiceRequestStateImpl value,
          $Res Function(_$ServiceRequestStateImpl) then) =
      __$$ServiceRequestStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime? selectedDate,
      TimeOfDay? selectedTime,
      ServiceDuration duration,
      List<String> selectedTags});
}

/// @nodoc
class __$$ServiceRequestStateImplCopyWithImpl<$Res>
    extends _$ServiceRequestStateCopyWithImpl<$Res, _$ServiceRequestStateImpl>
    implements _$$ServiceRequestStateImplCopyWith<$Res> {
  __$$ServiceRequestStateImplCopyWithImpl(_$ServiceRequestStateImpl _value,
      $Res Function(_$ServiceRequestStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ServiceRequestState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = freezed,
    Object? selectedTime = freezed,
    Object? duration = null,
    Object? selectedTags = null,
  }) {
    return _then(_$ServiceRequestStateImpl(
      selectedDate: freezed == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      selectedTime: freezed == selectedTime
          ? _value.selectedTime
          : selectedTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay?,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as ServiceDuration,
      selectedTags: null == selectedTags
          ? _value._selectedTags
          : selectedTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$ServiceRequestStateImpl implements _ServiceRequestState {
  const _$ServiceRequestStateImpl(
      {this.selectedDate,
      this.selectedTime,
      this.duration = ServiceDuration.eightHours,
      final List<String> selectedTags = const []})
      : _selectedTags = selectedTags;

  @override
  final DateTime? selectedDate;
  @override
  final TimeOfDay? selectedTime;
  @override
  @JsonKey()
  final ServiceDuration duration;
  final List<String> _selectedTags;
  @override
  @JsonKey()
  List<String> get selectedTags {
    if (_selectedTags is EqualUnmodifiableListView) return _selectedTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedTags);
  }

  @override
  String toString() {
    return 'ServiceRequestState(selectedDate: $selectedDate, selectedTime: $selectedTime, duration: $duration, selectedTags: $selectedTags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceRequestStateImpl &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            (identical(other.selectedTime, selectedTime) ||
                other.selectedTime == selectedTime) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            const DeepCollectionEquality()
                .equals(other._selectedTags, _selectedTags));
  }

  @override
  int get hashCode => Object.hash(runtimeType, selectedDate, selectedTime,
      duration, const DeepCollectionEquality().hash(_selectedTags));

  /// Create a copy of ServiceRequestState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceRequestStateImplCopyWith<_$ServiceRequestStateImpl> get copyWith =>
      __$$ServiceRequestStateImplCopyWithImpl<_$ServiceRequestStateImpl>(
          this, _$identity);
}

abstract class _ServiceRequestState implements ServiceRequestState {
  const factory _ServiceRequestState(
      {final DateTime? selectedDate,
      final TimeOfDay? selectedTime,
      final ServiceDuration duration,
      final List<String> selectedTags}) = _$ServiceRequestStateImpl;

  @override
  DateTime? get selectedDate;
  @override
  TimeOfDay? get selectedTime;
  @override
  ServiceDuration get duration;
  @override
  List<String> get selectedTags;

  /// Create a copy of ServiceRequestState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceRequestStateImplCopyWith<_$ServiceRequestStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
