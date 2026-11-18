import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/models/on_demand_request.dart';

/// Repositório para solicitações on-demand (modelo Uber).
/// No bypass (dev), opera sobre listas estáticas em memória.
/// Em produção, consome os endpoints documentados em API_CONTRACTS.md §ServiceRequests.
class OnDemandRequestRepository {
  static const String _devBypassToken = 'dev-bypass-token';

  /// Solicitações criadas pela família no modo bypass.
  /// Pré-populado com itens concluídos/cancelados para o histórico funcionar em dev.
  static final List<OnDemandRequest> _mockFamilyRequests = [
    OnDemandRequest(
      id: 501,
      familyId: 3,
      patientName: 'Dona Helena (75 anos)',
      address: 'Rua Visconde de Pirajá, 500 - Ipanema, RJ',
      notes: 'Acompanhamento pós-cirúrgico. Curativo diário e mobilização.',
      status: 'completed',
      professionalId: 2,
      professionalName: 'Carlos Mendes',
      createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 3)),
      matchedAt:
          DateTime.now().subtract(const Duration(days: 5, hours: 2, minutes: 45)),
    ),
    OnDemandRequest(
      id: 502,
      familyId: 3,
      patientName: 'Dona Helena (75 anos)',
      address: 'Rua Visconde de Pirajá, 500 - Ipanema, RJ',
      notes: 'Cuidados noturnos e administração de insulina.',
      status: 'cancelled',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
  ];

  /// Pool de solicitações abertas visível pelos profissionais no bypass.
  static final List<OnDemandRequest> _mockNearbyRequests = [
    OnDemandRequest(
      id: 301,
      familyId: 5,
      patientName: 'Sra. Maria (79 anos)',
      address: 'Rua Nascimento Silva, 107 - Ipanema, RJ',
      notes:
          'Paciente acamada. Precisa de cuidados noturnos e administração de medicação.',
      status: 'searching',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      distanceKm: 1.2,
    ),
    OnDemandRequest(
      id: 302,
      familyId: 7,
      patientName: 'Sr. Roberto (65 anos)',
      address: 'Av. Epitácio Pessoa, 2566 - Lagoa, RJ',
      notes: 'Pós-operatório. Curativo, controle de dor e fisioterapia leve.',
      status: 'searching',
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      distanceKm: 2.7,
    ),
  ];

  static int _nextId = 401;

  final http.Client _client;

  OnDemandRequestRepository({http.Client? client})
      : _client = client ?? http.Client();

  // ── FAMÍLIA ─────────────────────────────────────────────────────────

  /// GET /service-requests/mine
  Future<List<OnDemandRequest>> getMyRequests(String token) async {
    if (token == _devBypassToken) {
      return List<OnDemandRequest>.from(_mockFamilyRequests);
    }
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/service-requests/mine'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => OnDemandRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_detail(response.body) ?? 'Erro ao carregar solicitações.');
  }

  /// POST /service-requests
  Future<OnDemandRequest> createRequest(
    String token, {
    required String patientName,
    required String address,
    String? notes,
  }) async {
    if (token == _devBypassToken) {
      final req = OnDemandRequest(
        id: _nextId++,
        familyId: 1,
        patientName: patientName,
        address: address,
        notes: notes,
        status: 'searching',
        createdAt: DateTime.now(),
      );
      _mockFamilyRequests.insert(0, req);
      return req;
    }
    final body = jsonEncode({
      'patient_name': patientName,
      'address': address,
      if (notes != null) 'notes': notes,
    });
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/service-requests'),
      headers: _headers(token),
      body: body,
    );
    if (response.statusCode == 201) {
      return OnDemandRequest.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(_detail(response.body) ?? 'Erro ao criar solicitação.');
  }

  /// POST /service-requests/{id}/cancel
  Future<void> cancelRequest(String token, int requestId) async {
    if (token == _devBypassToken) {
      final i = _mockFamilyRequests.indexWhere((r) => r.id == requestId);
      if (i != -1) {
        _mockFamilyRequests[i] =
            _mockFamilyRequests[i].copyWith(status: 'cancelled');
      }
      return;
    }
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/service-requests/$requestId/cancel'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_detail(response.body) ?? 'Erro ao cancelar.');
    }
  }

  /// "Procurar outro" no contrato atual = cancelar a solicitação matched/searching
  /// e criar uma nova solicitação com os mesmos dados.
  Future<OnDemandRequest> requestAnotherProfessional(
    String token,
    OnDemandRequest request,
  ) async {
    await cancelRequest(token, request.id);
    return createRequest(
      token,
      patientName: request.patientName,
      address: request.address,
      notes: request.notes,
    );
  }

  // ── PROFISSIONAL ─────────────────────────────────────────────────────

  /// GET /service-requests/nearby — pool geoespacial de requisições abertas.
  Future<List<OnDemandRequest>> getNearbyRequests(String token) async {
    if (token == _devBypassToken) {
      return _mockNearbyRequests
          .where((r) => r.status == 'searching')
          .toList();
    }
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/service-requests/nearby'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => OnDemandRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
        _detail(response.body) ?? 'Erro ao carregar solicitações próximas.');
  }

  /// POST /service-requests/{id}/accept
  /// Status muda para matched e a requisição sai do pool público.
  Future<void> acceptRequest(String token, int requestId) async {
    if (token == _devBypassToken) {
      final i =
          _mockNearbyRequests.indexWhere((r) => r.id == requestId);
      if (i == -1) throw Exception('Solicitação não encontrada ou já atendida.');
      _mockNearbyRequests[i] = _mockNearbyRequests[i].copyWith(
        status: 'matched',
        professionalId: 2,
        professionalName: 'Carlos Mendes',
        matchedAt: DateTime.now(),
      );
      return;
    }
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/service-requests/$requestId/accept'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_detail(response.body) ?? 'Erro ao aceitar solicitação.');
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
