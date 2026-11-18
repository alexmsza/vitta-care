import 'patient.dart';

class Shift {
  final int id;
  final String title;
  final String? description;
  final String hospitalName;
  final String address;
  final double value;
  final DateTime dateStart;
  final DateTime dateEnd;
  final String status; // 'open' | 'assigned' | 'in_progress' | 'completed' | 'cancelled'
  final int? professionalId;

  /// Definido pela equipe Vitta ao criar o plantão.
  /// Substitui a inferência client-side por texto/data.
  final bool isUrgent;

  /// Dados do paciente. Presente em todos os plantões a partir da API v2.6.
  /// Null apenas em registros legados sem migração.
  final Patient? patient;

  Shift({
    required this.id,
    required this.title,
    this.description,
    required this.hospitalName,
    required this.address,
    required this.value,
    required this.dateStart,
    required this.dateEnd,
    required this.status,
    this.professionalId,
    this.isUrgent = false,
    this.patient,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      hospitalName: json['hospital_name'] as String,
      address: json['address'] as String,
      value: (json['value'] as num).toDouble(),
      dateStart: DateTime.parse(json['date_start'] as String),
      dateEnd: DateTime.parse(json['date_end'] as String),
      status: json['status'] as String,
      professionalId: json['professional_id'] as int?,
      isUrgent: (json['is_urgent'] as bool?) ?? false,
      patient: json['patient'] != null
          ? Patient.fromJson(json['patient'] as Map<String, dynamic>)
          : null,
    );
  }

  Duration get duration => dateEnd.difference(dateStart);

  /// Multiplicador de urgencia exibido na UI.
  ///
  /// Regra de negocio:
  /// - isUrgent=false: plantao programado comum, sem acrescimo.
  /// - isUrgent=true: aplica acrescimo progressivo conforme proximidade.
  /// Quanto menor a janela ate o inicio, maior o multiplicador.
  ///
  /// Importante: o backend aplica esse multiplicador no `value` ao criar o
  /// plantao. No app, este getter serve para explicar a tag/preco ao cuidador
  /// sem recalcular nem duplicar o valor cobrado.
  double get urgencyMultiplier {
    if (!isUrgent) return 1.0;

    final hoursUntilStart = dateStart.difference(DateTime.now()).inHours;
    if (hoursUntilStart <= 2) return 1.75;
    if (hoursUntilStart <= 6) return 1.50;
    if (hoursUntilStart <= 24) return 1.35;
    return 1.25;
  }
}
