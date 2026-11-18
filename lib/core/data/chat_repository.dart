import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/conversation.dart';
import '../models/chat_message.dart';

class ChatRepository {
  static const String _devBypassToken = 'dev-bypass-token';
  final http.Client _client;

  ChatRepository({http.Client? client}) : _client = client ?? http.Client();

  // ─── Mock data ────────────────────────────────────────────────────

  // Start empty — no fake pre-seeded conversation
  static final _mockMessages = <int, List<ChatMessage>>{};

  List<Conversation> _mockConversations() => [
        Conversation(
          id: 1,
          requestId: 201,
          requestType: 'shift',
          familyId: 3,
          professionalId: 2,
          familyName: 'Cliente Teste',
          professionalName: 'Cuidador Teste',
          patientName: 'Paciente da visita',
          lastMessage: null,
          lastMessageAt: null,
          unreadCount: 0,
          visitDate: DateTime.now().add(const Duration(hours: 4)),
        ),
        Conversation(
          id: 2,
          requestId: 202,
          requestType: 'shift',
          familyId: 3,
          professionalId: 2,
          familyName: 'Cliente Teste',
          professionalName: 'Cuidador Teste',
          patientName: 'Paciente da visita',
          lastMessage: null,
          lastMessageAt: null,
          unreadCount: 0,
          visitDate: DateTime.now().add(const Duration(days: 5)),
        ),
      ];

  // ─── API ──────────────────────────────────────────────────────────

  Future<List<Conversation>> getConversations(String token) async {
    if (token == _devBypassToken) return _mockConversations();

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/chat/conversations'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_detail(response.body) ?? 'Erro ao carregar conversas.');
  }

  Future<Conversation> getConversationByRequest(
      String token, int requestId, String requestType) async {
    if (token == _devBypassToken) {
      // Use the same names as _mockConversations() so appbar/chat titles are consistent
      final base = _mockConversations().first;
      return Conversation(
        id: base.id,
        requestId: requestId,
        requestType: requestType,
        familyId: base.familyId,
        professionalId: base.professionalId,
        familyName: base.familyName,
        professionalName: base.professionalName,
        patientName: base.patientName,
        lastMessage: base.lastMessage,
        lastMessageAt: base.lastMessageAt,
        unreadCount: base.unreadCount,
        visitDate: requestType == 'service_request'
            ? null
            : DateTime.now().add(const Duration(hours: 4)),
      );
    }

    final response = await _client.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/chat/conversations/by-request/$requestId?request_type=$requestType'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return Conversation.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(
        _detail(response.body) ?? 'Conversa não encontrada para este pedido.');
  }

  Future<List<ChatMessage>> getMessages(String token, int conversationId) async {
    if (token == _devBypassToken) {
      return List<ChatMessage>.from(
          _mockMessages[conversationId] ?? []);
    }

    final response = await _client.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/chat/conversations/$conversationId/messages'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_detail(response.body) ?? 'Erro ao carregar mensagens.');
  }

  Future<ChatMessage> sendMessage(
      String token, int conversationId, String content,
      {int senderIdHint = 0,
      String senderNameHint = 'Você',
      String senderRoleHint = 'family'}) async {
    if (token == _devBypassToken) {
      final msg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        conversationId: conversationId,
        senderId: senderIdHint,
        senderName: senderNameHint,
        senderRole: senderRoleHint,
        content: content,
        sentAt: DateTime.now(),
        read: false,
      );
      _mockMessages.putIfAbsent(conversationId, () => []).add(msg);
      return msg;
    }

    final response = await _client.post(
      Uri.parse(
          '${ApiConfig.baseUrl}/chat/conversations/$conversationId/messages'),
      headers: _headers(token),
      body: jsonEncode({'content': content}),
    );
    if (response.statusCode == 201) {
      return ChatMessage.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(_detail(response.body) ?? 'Erro ao enviar mensagem.');
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
