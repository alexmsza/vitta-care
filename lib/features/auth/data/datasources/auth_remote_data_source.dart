import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vitta/core/error/exceptions.dart';

class AuthRemoteDataSource {
  final http.Client client;
  // Android emulator uses 10.0.2.2 to access localhost of the host machine.
  // iOS simulator uses localhost directly.
  // GitHub Actions (iOS Build) runs on macOS, so localhost refers to the runner itself (but the backend won't be there).
  // NOTE: For the IPA build on GitHub Actions, this URL will likely fail unless the backend is also hosted publicly.
  // However, for local testing on iOS Simulator, 'localhost' is correct.
  static const String baseUrl = 'http://localhost:8000/api';

  AuthRemoteDataSource({required this.client});

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ServerException(message: 'Login failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw ServerException(message: 'Registration failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ServerException(message: 'Failed to get user: ${response.body}');
    }
  }
}
