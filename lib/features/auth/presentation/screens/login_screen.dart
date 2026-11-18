import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const bool _useTemporaryUiBypass = true;
  static const String _devBypassToken = 'dev-bypass-token';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_useTemporaryUiBypass) {
      await _enterBypass(
        role: 'family',
        route: '/family',
        name: 'Cliente Teste',
      );
      return;
    }

    await ref
        .read(authProvider.notifier)
        .login(_emailController.text, _passwordController.text);

    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);
    if (authState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authState.error.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _enterBypass({
    required String role,
    required String route,
    required String name,
  }) async {
    final mockUser = AppUser(
      id: role == 'professional' ? 2 : 3,
      name: name,
      email: _emailController.text.isNotEmpty
          ? _emailController.text
          : '$role@dev.local',
      role: role,
      token: _devBypassToken,
      isActive: true,
    );

    ref.read(authStateProvider.notifier).login(mockUser);
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = !_useTemporaryUiBypass && authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'assets/images/logo.jpeg',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.local_hospital,
                      size: 80,
                      color: AppTheme.petrol,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Bem-vindo a Vitta',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.petrol,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sua conexão de confiança',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.sage,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe seu e-mail';
                    }
                    if (!value.contains('@')) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe sua senha';
                    }
                    if (value.length < 6) {
                      return 'Minimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: isLoading ? null : _handleLogin,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Entrar'),
                ),
                if (_useTemporaryUiBypass) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Bypass temporario para testar UX localmente. Nao vai para main.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _enterBypass(
                          role: 'professional',
                          route: '/professional',
                          name: 'Cuidador Teste',
                        ),
                        icon: const Icon(Icons.medical_services_outlined),
                        label: const Text('Painel Cuidador'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _enterBypass(
                          role: 'family',
                          route: '/family',
                          name: 'Cliente Teste',
                        ),
                        icon: const Icon(Icons.family_restroom_outlined),
                        label: const Text('Painel Cliente'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Ainda não tem conta? '),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: const Text(
                        'Criar conta',
                        style: TextStyle(
                          color: AppTheme.petrol,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
