/// Solicitação de cuidado on-demand feita por uma família.
/// Fluxo de status: searching → matched → in_progress → completed | cancelled
class ServiceRequest {
  final int id;
  final int familyId;
  final String patientName;
  final String address;
  final String? notes;
  final String status;
  final int? professionalId;
  final String? professionalName;
  final DateTime createdAt;
  final DateTime? matchedAt;

  /// Calculado client-side a partir de lat/lng retornados pelo backend.
  /// No mock, valor fixo definido no repositório.
  final double? distanceKm;

  const ServiceRequest({
    required this.id,
    required this.familyId,
    required this.patientName,
    required this.address,
    this.notes,
    required this.status,
    this.professionalId,
    this.professionalName,
    required this.createdAt,
    this.matchedAt,
    this.distanceKm,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as int,
      familyId: json['family_id'] as int,
      patientName: json['patient_name'] as String,
      address: json['address'] as String,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      professionalId: json['professional_id'] as int?,
      professionalName: json['professional_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      matchedAt: json['matched_at'] != null
          ? DateTime.parse(json['matched_at'] as String)
          : null,
      // distanceKm: computed separately via geolocation, not in JSON
    );
  }

  Map<String, dynamic> toJson() => {
        'patient_name': patientName,
        'address': address,
        if (notes != null) 'notes': notes,
      };

  ServiceRequest copyWith({
    int? id,
    int? familyId,
    String? patientName,
    String? address,
    String? notes,
    String? status,
    int? professionalId,
    String? professionalName,
    DateTime? createdAt,
    DateTime? matchedAt,
    double? distanceKm,
  }) =>
      ServiceRequest(
        id: id ?? this.id,
        familyId: familyId ?? this.familyId,
        patientName: patientName ?? this.patientName,
        address: address ?? this.address,
        notes: notes ?? this.notes,
        status: status ?? this.status,
        professionalId: professionalId ?? this.professionalId,
        professionalName: professionalName ?? this.professionalName,
        createdAt: createdAt ?? this.createdAt,
        matchedAt: matchedAt ?? this.matchedAt,
        distanceKm: distanceKm ?? this.distanceKm,
      );
}
