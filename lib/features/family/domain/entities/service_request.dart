import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_request.freezed.dart';
part 'service_request.g.dart';

enum ServiceDuration { eightHours, twelveHours, twentyFourHours }

enum RequestStatus { open, accepted, completed, cancelled }

@freezed
class ServiceRequest with _$ServiceRequest {
  const factory ServiceRequest({
    required String id,
    required String familyId,
    required DateTime date,
    required ServiceDuration duration,
    @Default([]) List<String> tags, // ex: ['Acamado', 'Lúcido']
    @Default(RequestStatus.open) RequestStatus status,
    required double priceTotal,
    String? assignedProId,
    DateTime? createdAt,
    @Default('Paciente Vitta') String patientName,
    @Default('Descrição do quadro clínico...') String description,
  }) = _ServiceRequest;

  factory ServiceRequest.fromJson(Map<String, dynamic> json) =>
      _$ServiceRequestFromJson(json);
}
