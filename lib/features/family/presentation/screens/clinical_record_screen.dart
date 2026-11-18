import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Anamnese digital do paciente.
/// Os 4 campos de saúde são serializados como JSON em [AppUser.clinicalSummary].
/// Os gostos/hobbies são salvos em [AppUser.hobbies] como lista de strings.
class ClinicalRecordScreen extends ConsumerStatefulWidget {
  const ClinicalRecordScreen({super.key});

  @override
  ConsumerState<ClinicalRecordScreen> createState() =>
      _ClinicalRecordScreenState();
}

class _ClinicalRecordScreenState extends ConsumerState<ClinicalRecordScreen> {
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _surgeriesController = TextEditingController();
  final _routineController = TextEditingController();
  final _hobbiesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFromUser();
  }

  void _loadFromUser() {
    final user = ref.read(authStateProvider);
    if (user == null) return;

    // Parse structured JSON stored in clinicalSummary
    if (user.clinicalSummary != null && user.clinicalSummary!.isNotEmpty) {
      try {
        final data =
            jsonDecode(user.clinicalSummary!) as Map<String, dynamic>;
        _allergiesController.text = (data['allergies'] as String?) ?? '';
        _medicationsController.text = (data['medications'] as String?) ?? '';
        _surgeriesController.text = (data['surgeries'] as String?) ?? '';
        _routineController.text = (data['routine'] as String?) ?? '';
      } catch (_) {
        // Legacy plain text — put it in allergies field as fallback
        _allergiesController.text = user.clinicalSummary!;
      }
    }

    // Hobbies → comma-separated text
    if (user.hobbies != null && user.hobbies!.isNotEmpty) {
      _hobbiesController.text = user.hobbies!.join(', ');
    }
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _medicationsController.dispose();
    _surgeriesController.dispose();
    _routineController.dispose();
    _hobbiesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final user = ref.read(authStateProvider)!;

      // Encode health fields as structured JSON
      final clinicalSummary = jsonEncode({
        'allergies': _allergiesController.text.trim(),
        'medications': _medicationsController.text.trim(),
        'surgeries': _surgeriesController.text.trim(),
        'routine': _routineController.text.trim(),
      });

      // Parse hobbies from comma-separated text
      final hobbies = _hobbiesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      ref.read(authStateProvider.notifier).updateProfile(
            user.copyWith(
              clinicalSummary: clinicalSummary,
              hobbies: hobbies,
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anamnese salva com sucesso!'),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Anamnese Digital',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              icon: Icons.medical_information_outlined,
              title: 'Histórico de Saúde',
              subtitle: 'Informações essenciais para os profissionais',
            ),
            const SizedBox(height: 20),
            _buildInput(
              label: 'Alergias',
              controller: _allergiesController,
              hint: 'Ex: Dipirona, frutos do mar, látex',
              icon: Icons.warning_amber_outlined,
            ),
            const SizedBox(height: 16),
            _buildInput(
              label: 'Medicamentos em Uso',
              controller: _medicationsController,
              hint: 'Ex: Losartana 50mg (manhã), Insulina NPH 10UI (22h)',
              icon: Icons.medication_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildInput(
              label: 'Histórico Cirúrgico',
              controller: _surgeriesController,
              hint: 'Ex: Apendicite (2010), Prótese de quadril (2023)',
              icon: Icons.local_hospital_outlined,
            ),
            const SizedBox(height: 32),
            const _SectionHeader(
              icon: Icons.favorite_outline,
              title: 'Rotina e Preferências',
              subtitle: 'Ajuda o profissional a criar conexão',
            ),
            const SizedBox(height: 20),
            _buildInput(
              label: 'Rotina Diária',
              controller: _routineController,
              hint: 'Ex: Acorda às 7h, almoço às 12h, dorme às 22h',
              icon: Icons.schedule_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildInput(
              label: 'Gostos Pessoais e Hobbies',
              controller: _hobbiesController,
              hint:
                  'Ex: música clássica, xadrez, jardinagem (separados por vírgula)',
              icon: Icons.star_outline_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
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
                        'Salvar Anamnese',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
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
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.vittaSageLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
