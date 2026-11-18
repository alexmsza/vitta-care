import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift.freezed.dart';
part 'shift.g.dart';

@freezed
class Shift with _$Shift {
  const factory Shift({
    required String id,
    required String proId,
    required String serviceRequestId,
    DateTime? checkIn,
    DateTime? checkOut,
    Map<String, dynamic>? reportData, // Checklist responses
  }) = _Shift;

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);
}
