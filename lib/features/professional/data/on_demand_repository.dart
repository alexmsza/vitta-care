import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/models/on_demand_request.dart';

class OnDemandRepository {
  static const String _devBypassToken = 'dev-bypass-token';

  static final List<OnDemandRequest> _mockNearbyRequests = [
    OnDemandRequest(
      id: 301,
      familyId: 5,
      patientName: 'Sra. Maria (79 anos)',
      address: 'Rua Nascimento Silva, 107 - Ipanema, RJ',
      notes:
          'Paciente acamada. Precisa de cuidados noturnos e administracao de medicacao.',
      status: 'searching',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      distanceKm: 1.2,
    ),
    OnDemandRequest(
      id: 302,
      familyId: 7,
      patientName: 'Sr. Roberto (65 anos)',
      address: 'Av. Epitacio Pessoa, 2566 - Lagoa, RJ',
      notes: 'Pos-operatorio. Curativo, controle de dor e fisioterapia leve.',
      status: 'searching',
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      distanceKm: 2.7,
    ),
  ];

  static final List<OnDemandRequest> _mockAcceptedRequests = [
    OnDemandRequest(
      id: 401,
      familyId: 8,
      patientName: 'Sr. Jose (82 anos)',
      address: 'Rua Paula Freitas, 45 - Copacabana, RJ',
      notes: 'Acompanhamento pos-AVC. Monitoramento de sinais vitais.',
      status: 'matched',
      professionalId: 2,
      professionalName: 'Carlos Mendes',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      matchedAt: DateTime.now().subtract(
        const Duration(hours: 1, minutes: 45),
      ),
    ),
  ];

  final http.Client _client;

  OnDemandRepository({http.Client? client}) : _client = client ?? http.Client();

  /// GET /service-requests/nearby
  Future<List<OnDemandRequest>> getNearbyRequests(String token) async {
    if (token == _devBypassToken) {
      return _mockNearbyRequests.where((r) => r.status == 'searching').toList();
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
    throw Exception(_detail(response.body) ?? 'Erro ao carregar solicitacoes proximas.');
  }

  /// GET /service-requests/accepted
  Future<List<OnDemandRequest>> getAcceptedRequests(String token) async {
    if (token == _devBypassToken) {
      return _mockAcceptedRequests
          .where((r) => r.status == 'matched' || r.status == 'in_progress')
          .toList();
    }

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/service-requests/accepted'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => OnDemandRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_detail(response.body) ?? 'Erro ao carregar solicitacoes aceitas.');
  }

  /// POST /service-requests/{id}/cancel
  Future<void> cancelAcceptedRequest(String token, int requestId) async {
    if (token == _devBypassToken) {
      final i = _mockAcceptedRequests.indexWhere((r) => r.id == requestId);
      if (i != -1) {
        _mockAcceptedRequests[i] =
            _mockAcceptedRequests[i].copyWith(status: 'cancelled');
      }
      return;
    }

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/service-requests/$requestId/cancel'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception(_detail(response.body) ?? 'Erro ao cancelar solicitacao.');
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
