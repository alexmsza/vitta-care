// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceRequestImpl _$$ServiceRequestImplFromJson(Map<String, dynamic> json) =>
    _$ServiceRequestImpl(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: $enumDecode(_$ServiceDurationEnumMap, json['duration']),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      status: $enumDecodeNullable(_$RequestStatusEnumMap, json['status']) ??
          RequestStatus.open,
      priceTotal: (json['priceTotal'] as num).toDouble(),
      assignedProId: json['assignedProId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      patientName: json['patientName'] as String? ?? 'Paciente Vitta',
      description:
          json['description'] as String? ?? 'Descrição do quadro clínico...',
    );

Map<String, dynamic> _$$ServiceRequestImplToJson(
        _$ServiceRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'familyId': instance.familyId,
      'date': instance.date.toIso8601String(),
      'duration': _$ServiceDurationEnumMap[instance.duration]!,
      'tags': instance.tags,
      'status': _$RequestStatusEnumMap[instance.status]!,
      'priceTotal': instance.priceTotal,
      'assignedProId': instance.assignedProId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'patientName': instance.patientName,
      'description': instance.description,
    };

const _$ServiceDurationEnumMap = {
  ServiceDuration.eightHours: 'eightHours',
  ServiceDuration.twelveHours: 'twelveHours',
  ServiceDuration.twentyFourHours: 'twentyFourHours',
};

const _$RequestStatusEnumMap = {
  RequestStatus.open: 'open',
  RequestStatus.accepted: 'accepted',
  RequestStatus.completed: 'completed',
  RequestStatus.cancelled: 'cancelled',
};
