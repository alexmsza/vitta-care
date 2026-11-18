import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/models/patient.dart';
import '../../../core/models/shift.dart';

class ShiftRepository {
  static const String _devBypassToken = 'dev-bypass-token';

  // Relative to now so the mock always feels "live".
  static final List<Shift> _mockOpenShifts = [
    Shift(
      id: 101,
      title: 'Plantão Noturno - Copacabana',
      description: 'Cuidados com paciente idosa e administração de medicação.',
      hospitalName: 'Residência Particular',
      address: 'Av. Atlântica, 1500 - Copacabana, RJ',
      value: 450,
      dateStart: DateTime.now().add(const Duration(days: 2)),
      dateEnd: DateTime.now().add(const Duration(days: 2, hours: 12)),
      status: 'open',
      isUrgent: true,
      patient: const Patient(
        name: 'Sra. Maria Silva',
        age: 79,
        rating: 4.9,
        medicalHistory:
            'Hipertensão arterial, diabetes tipo 2, mobilidade reduzida. '
            'Usa insulina NPH 10UI às 08h e 22h. Alergia a dipirona.',
      ),
    ),
    Shift(
      id: 102,
      title: 'Home Care Diurno - Barra',
      description: 'Acompanhamento pós-cirúrgico com curativos.',
      hospitalName: 'Residência Particular',
      address: 'Av. das Américas, 3000 - Barra da Tijuca, RJ',
      value: 320,
      dateStart: DateTime.now().add(const Duration(days: 3)),
      dateEnd: DateTime.now().add(const Duration(days: 3, hours: 8)),
      status: 'open',
      isUrgent: false,
      patient: const Patient(
        name: 'Sr. Roberto Faria',
        age: 65,
        rating: 4.6,
        medicalHistory:
            'Pós-operatório de quadril (prótese total). '
            'Requer auxílio na mobilização e fisioterapia leve.',
      ),
    ),
  ];

  static final List<Shift> _mockMyShifts = [
    // Plantão recém-finalizado — usado pela seção "Meu último plantão" na home
    Shift(
      id: 200,
      title: 'Cuidado Diurno - Selma Soares',
      description: 'Hidratação, mobilização leve e administração de medicação.',
      hospitalName: 'Residência Particular',
      address: 'Rua Visconde de Pirajá, 200 - Ipanema, RJ',
      value: 360,
      dateStart: DateTime.now().subtract(const Duration(hours: 14)),
      dateEnd: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'completed',
      professionalId: 2,
      isUrgent: false,
      patient: const Patient(
        name: 'Sra. Selma Soares Ferreira',
        age: 76,
        rating: 4.8,
        medicalHistory:
            'Hipertensão controlada, artrose nos joelhos, episódios de '
            'insônia. Usa losartana 50mg pela manhã. Sem alergias.',
      ),
    ),
    // Within 24 h — chat unlocked
    Shift(
      id: 201,
      title: 'Fisioterapia Domiciliar - Ipanema',
      description: 'Sessão motora e respiratória.',
      hospitalName: 'Residência Particular',
      address: 'Rua Visconde de Pirajá, 500 - Ipanema, RJ',
      value: 280,
      dateStart: DateTime.now().add(const Duration(hours: 4)),
      dateEnd: DateTime.now().add(const Duration(hours: 8)),
      status: 'assigned',
      professionalId: 2,
      isUrgent: false,
      patient: const Patient(
        name: 'Dna. Helena Costa',
        age: 71,
        rating: 5.0,
        medicalHistory:
            'AVC isquêmico há 8 meses. Hemiplegia leve à esquerda. '
            'Em reabilitação motora e fonoaudiológica. Sem alergias conhecidas.',
      ),
    ),
    // 5 days away — chat locked
    Shift(
      id: 202,
      title: 'Cuidado Noturno - Leme',
      description: 'Acompanhamento e administração de insulina.',
      hospitalName: 'Residência Particular',
      address: 'Rua Gustavo Sampaio, 320 - Leme, RJ',
      value: 390,
      dateStart: DateTime.now().add(const Duration(days: 5)),
      dateEnd: DateTime.now().add(const Duration(days: 5, hours: 12)),
      status: 'assigned',
      professionalId: 2,
      isUrgent: false,
      patient: const Patient(
        name: 'Sr. Antônio Braga',
        age: 84,
        rating: 4.7,
        medicalHistory:
            'Diabetes tipo 1, insuficiência renal crônica estágio 3. '
            'Insulina Glargina 20UI às 22h. Dieta com restrição de potássio.',
      ),
    ),
  ];

  final http.Client _client;

  ShiftRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Shift>> getOpenShifts(String token) async {
    if (token == _devBypassToken) return List<Shift>.from(_mockOpenShifts);

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/shifts?skip=0&limit=100'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Shift.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_detail(response.body) ?? 'Erro ao carregar plantões.');
  }

  Future<List<Shift>> getMyShifts(String token, {String? status}) async {
    if (token == _devBypassToken) {
      final filtered = status == null || status.isEmpty
          ? _mockMyShifts
          : _mockMyShifts.where((s) => s.status == status).toList();
      return List<Shift>.from(filtered);
    }

    final query = <String, String>{
      'skip': '0',
      'limit': '50',
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/shifts/my')
        .replace(queryParameters: query);
    final response = await _client.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Shift.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_detail(response.body) ?? 'Erro ao carregar seus plantões.');
  }

  Future<void> applyForShift(int shiftId, String token) async {
    if (token == _devBypassToken) {
      final index = _mockOpenShifts.indexWhere((s) => s.id == shiftId);
      if (index == -1) throw Exception('Esse plantão não está mais disponível.');

      final shift = _mockOpenShifts.removeAt(index);
      _mockMyShifts.insert(
        0,
        Shift(
          id: shift.id,
          title: shift.title,
          description: shift.description,
          hospitalName: shift.hospitalName,
          address: shift.address,
          value: shift.value,
          dateStart: shift.dateStart,
          dateEnd: shift.dateEnd,
          status: 'assigned',
          professionalId: 1,
          isUrgent: shift.isUrgent,
          patient: shift.patient,
        ),
      );
      return;
    }

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/shifts/$shiftId/apply'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_detail(response.body) ?? 'Erro ao aceitar plantão.');
    }
  }

  Future<void> cancelShift(int shiftId, String token) async {
    if (token == _devBypassToken) {
      _mockMyShifts.removeWhere((s) => s.id == shiftId);
      return;
    }

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/shifts/$shiftId/cancel'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_detail(response.body) ?? 'Erro ao cancelar plantão.');
    }
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  String? _detail(String body) {
    try {
      return (jsonDecode(body) as Map<String, dynamic>)['detail'] as String?;
    } catch (_) {
      return null;
    }
  }
}
