import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  // Professional-only
  late final TextEditingController _specialtyController;
  late final TextEditingController _crmCorenController;
  // Family-only
  late final TextEditingController _clinicalSummaryController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _specialtyController =
        TextEditingController(text: user?.specialty ?? '');
    _crmCorenController =
        TextEditingController(text: user?.crmCoren ?? '');
    _clinicalSummaryController =
        TextEditingController(text: user?.clinicalSummary ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _crmCorenController.dispose();
    _clinicalSummaryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final user = ref.read(authStateProvider)!;

      // TODO(backend): substituir pelo call real: PATCH /profile/me
      // final repo = ref.read(profileRepositoryProvider);
      // await repo.updateProfile(
      //   name: _nameController.text.trim(),
      //   phone: _phoneController.text.trim(),
      //   specialty: _specialtyController.text.trim(),  // professional only
      //   crmCoren: _crmCorenController.text.trim(),    // professional only
      //   clinicalSummary: _clinicalSummaryController.text.trim(), // family only
      // );

      final updated = user.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        specialty: user.role == 'professional'
            ? _specialtyController.text.trim()
            : null,
        crmCoren: user.role == 'professional'
            ? _crmCorenController.text.trim()
            : null,
        clinicalSummary: user.role == 'family'
            ? _clinicalSummaryController.text.trim()
            : null,
      );

      ref.read(authStateProvider.notifier).updateProfile(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final isProfessional = user?.role == 'professional';
    final isFamily = user?.role == 'family';
    final initials =
        (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: Text(
                _isSaving ? 'Salvando...' : 'Salvar',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar ──────────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.vittaSageLight,
                        child: Text(
                          initials,
                          style: GoogleFonts.inter(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        // TODO(backend): abrir image picker + upload para /profile/me/photo
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  user?.email ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Campos comuns ────────────────────────────────────
              _buildSectionTitle('Dados Pessoais'),
              const SizedBox(height: 16),
              _buildField(
                'Nome completo',
                _nameController,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                'Telefone',
                _phoneController,
                hint: '(11) 9 0000-0000',
                keyboardType: TextInputType.phone,
              ),

              // ── Profissional ─────────────────────────────────────
              if (isProfessional) ...[
                const SizedBox(height: 32),
                _buildSectionTitle('Dados Profissionais'),
                const SizedBox(height: 16),
                _buildField(
                  'Especialidade',
                  _specialtyController,
                  hint: 'Ex: Enfermagem, Fisioterapia',
                ),
                const SizedBox(height: 16),
                _buildField(
                  'CRM / COREN',
                  _crmCorenController,
                  hint: 'Ex: COREN-SP 123456',
                ),
              ],

              // ── Família ──────────────────────────────────────────
              if (isFamily) ...[
                const SizedBox(height: 32),
                _buildSectionTitle('Informações do Paciente'),
                const SizedBox(height: 16),
                _buildField(
                  'Resumo Clínico',
                  _clinicalSummaryController,
                  hint:
                      'Condições de saúde, alergias, necessidades especiais...',
                  maxLines: 4,
                ),
              ],

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Salvar Alterações',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      );

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }
}
