import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/models/user.dart';

class AuthRepository {
  final http.Client _client;

  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<AppUser> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return AppUser.fromLoginJson(data, email: email);
    } else if (response.statusCode == 401) {
      throw Exception('Credenciais inválidas.');
    } else if (response.statusCode == 403) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Sua conta está em análise.');
    } else {
      throw Exception('Erro ao realizar login. Tente novamente.');
    }
  }

  Future<AppUser> register({
    required String email,
    required String name,
    required String password,
    required String role,
    String? phone,
    String? specialty,
    String? crmCoren,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'name': name,
        'password': password,
        'role': role,
        'phone': phone,
        'specialty': specialty,
        'crm_coren': crmCoren,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return AppUser.fromLoginJson(data, email: email);
    } else if (response.statusCode == 400) {
      throw Exception('Email já cadastrado.');
    } else if (response.statusCode == 403) {
      throw Exception('Registro não permitido.');
    } else {
      throw Exception('Erro ao realizar cadastro. Tente novamente.');
    }
  }
}
