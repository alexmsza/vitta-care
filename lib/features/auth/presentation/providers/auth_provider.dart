import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/providers/auth_provider.dart' show authStateProvider;
import '../../data/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
AuthService authService(Ref ref) => AuthService();

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepository();

@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<AppUser?> build() async {
    // Restore persisted session on app start.
    final user = await ref.read(authServiceProvider).getStoredUser();
    if (user != null) {
      // Sync the global router state so redirect fires on startup.
      ref.read(authStateProvider.notifier).login(user);
    }
    return user;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user =
          await ref.read(authRepositoryProvider).login(email, password);
      await ref.read(authServiceProvider).saveSession(user);
      // Notify the router — triggers redirect to the correct dashboard.
      ref.read(authStateProvider.notifier).login(user);
      return user;
    });
  }

  Future<void> register({
    required String email,
    required String name,
    required String password,
    required String role,
    String? phone,
    String? specialty,
    String? crmCoren,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).register(
            email: email,
            name: name,
            password: password,
            role: role,
            phone: phone,
            specialty: specialty,
            crmCoren: crmCoren,
          );
      // Intentionally NOT syncing authStateProvider here:
      // account is pending approval, user must wait for email.
    });
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).clearSession();
    ref.read(authStateProvider.notifier).logout();
    state = const AsyncValue.data(null);
  }
}
