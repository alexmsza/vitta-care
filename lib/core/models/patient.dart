/// Dados do paciente vinculado a um [Shift] (plantão programado).
/// Retornado como objeto aninhado dentro de [ShiftResponse].
class Patient {
  final String name;

  /// Idade em anos. Null se a família não preencheu.
  final int? age;

  /// Média de avaliações de cuidadores anteriores (0–5).
  /// Null para pacientes sem histórico de atendimentos na plataforma.
  final double? rating;

  /// Resumo clínico livre fornecido pela família (condições, alergias, medicação).
  final String? medicalHistory;

  const Patient({
    required this.name,
    this.age,
    this.rating,
    this.medicalHistory,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      name: json['name'] as String,
      age: json['age'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      medicalHistory: json['medical_history'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (age != null) 'age': age,
        if (rating != null) 'rating': rating,
        if (medicalHistory != null) 'medical_history': medicalHistory,
      };
}
