import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/models/faq_item.dart';

class FaqRepository {
  static const String _devBypassToken = 'dev-bypass-token';
  final http.Client _client;

  FaqRepository({http.Client? client}) : _client = client ?? http.Client();

  static final List<FaqItem> _mockItems = [
    FaqItem(
      id: 1,
      category: 'Pagamentos',
      question: 'Como funciona o pagamento dos plantões?',
      answer:
          'O pagamento é processado automaticamente após a conclusão do plantão, com repasse ao profissional em até 2 dias úteis via PIX.',
      order: 1,
      targetRoles: ['professional', 'family'],
    ),
    FaqItem(
      id: 2,
      category: 'Pagamentos',
      question: 'Quais formas de pagamento são aceitas?',
      answer:
          'Aceitamos cartão de crédito, débito e PIX. O valor é reservado no momento da solicitação e cobrado apenas quando o profissional é confirmado.',
      order: 2,
      targetRoles: ['family'],
    ),
    FaqItem(
      id: 3,
      category: 'Pagamentos',
      question: 'Quando recebo meu saldo?',
      answer:
          'Seu saldo é liberado em até 48h após a conclusão do plantão. Você pode solicitar o saque a qualquer momento na aba Carteira.',
      order: 2,
      targetRoles: ['professional'],
    ),
    FaqItem(
      id: 4,
      category: 'Plantões',
      question: 'O que é um plantão programado?',
      answer:
          'Plantões programados são agendados com antecedência pela Vitta. Você pode aceitar e se planejar com antecedência.',
      order: 1,
      targetRoles: ['professional', 'family'],
    ),
    FaqItem(
      id: 5,
      category: 'Plantões',
      question: 'Como solicito cuidado imediato?',
      answer:
          'No painel principal, toque em "Solicitar Agora". Profissionais disponíveis na sua região receberão o aviso e poderão aceitar em minutos.',
      order: 2,
      targetRoles: ['family'],
    ),
    FaqItem(
      id: 6,
      category: 'Plantões',
      question: 'Como cancelo um plantão aceito?',
      answer:
          'Entre em contato com o suporte Vitta pelo chat em até 2h antes do início. Cancelamentos tardios podem gerar penalidade de avaliação.',
      order: 2,
      targetRoles: ['professional'],
    ),
    FaqItem(
      id: 7,
      category: 'Conta',
      question: 'Minha conta está em análise. Quanto tempo leva?',
      answer:
          'A aprovação é feita pela nossa equipe em até 24h úteis. Você receberá um e-mail assim que sua conta for ativada.',
      order: 1,
      targetRoles: ['professional', 'family'],
    ),
    FaqItem(
      id: 8,
      category: 'Conta',
      question: 'Preciso enviar documentação?',
      answer:
          'Sim. Após a aprovação, acesse Perfil > Documentos para enviar COREN/CRM, RG e comprovante de residência. Plantões só são liberados após validação.',
      order: 2,
      targetRoles: ['professional'],
    ),
  ];

  Future<List<FaqItem>> listFaq(String token, {String? category}) async {
    if (token == _devBypassToken) {
      if (category != null) {
        return _mockItems.where((i) => i.category == category).toList();
      }
      return List.from(_mockItems);
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/faq').replace(
      queryParameters: category != null ? {'category': category} : null,
    );

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => FaqItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erro ao carregar FAQ.');
  }
}
