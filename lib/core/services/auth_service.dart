import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

/// Persists auth session securely between app restarts.
class AuthService {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<void> saveSession(AppUser user) async {
    await _storage.write(key: _tokenKey, value: user.token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  /// Returns the stored user or null if no session exists.
  Future<AppUser?> getStoredUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final token = json['token'] as String? ?? '';
      return AppUser.fromProfileJson(json, token: token);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
