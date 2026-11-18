import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

/// Global auth state watched by the router. null = not logged in.
/// Updated by features/auth/presentation/providers/auth_provider.dart after login/logout.
final authStateProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier() : super(null);

  void login(AppUser user) => state = user;

  void updateProfile(AppUser user) => state = user;

  void logout() => state = null;
}
