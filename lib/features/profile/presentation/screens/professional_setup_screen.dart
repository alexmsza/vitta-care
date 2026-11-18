import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitta/core/theme/app_colors.dart';

class ProfessionalSetupScreen extends StatefulWidget {
  const ProfessionalSetupScreen({super.key});

  @override
  State<ProfessionalSetupScreen> createState() =>
      _ProfessionalSetupScreenState();
}

class _ProfessionalSetupScreenState extends State<ProfessionalSetupScreen> {
  final _specialtyController = TextEditingController();
  final _registryController = TextEditingController();
  final _aboutController = TextEditingController();
  final List<String> _selectedHobbies = [];

  final List<String> _availableHobbies = [
    'Leitura',
    'Música Clássica',
    'Jardinagem',
    'Caminhada',
    'Xadrez',
    'Culinária',
    'Artesanato',
    'Filmes Antigos',
    'Animais',
    'Viagens',
  ];

  void _toggleHobby(String hobby) {
    setState(() {
      if (_selectedHobbies.contains(hobby)) {
        _selectedHobbies.remove(hobby);
      } else {
        _selectedHobbies.add(hobby);
      }
    });
  }

  void _submit() {
    // Mock saving profile data
    context.go('/pro/dashboard');
  }

  @override
  void dispose() {
    _specialtyController.dispose();
    _registryController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Perfil Profissional',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Vamos completar seu perfil para conectar você aos melhores pacientes.',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Dados Profissionais'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialtyController,
              decoration: const InputDecoration(
                labelText: 'Especialidade (ex: Enfermeiro, Cuidador)',
                prefixIcon: Icon(Icons.work_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registryController,
              decoration: const InputDecoration(
                labelText: 'Habilitação (COREN/CRM/Certificado)',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Sobre Você'),
            const SizedBox(height: 8),
            Text(
              'Conte um pouco sobre suas experiências e porque ama cuidar.',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aboutController,
              decoration: const InputDecoration(
                hintText: 'Digite aqui sua bio...',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Seus Interesses & Hobbies'),
            const SizedBox(height: 8),
            Text(
              'Isso ajuda no nosso "Matching Inteligente" para encontrar pacientes com afinidade.',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableHobbies.map((hobby) {
                final isSelected = _selectedHobbies.contains(hobby);
                return FilterChip(
                  label: Text(hobby),
                  selected: isSelected,
                  onSelected: (_) => _toggleHobby(hobby),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.vittaSageLight,
                  checkmarkColor: AppColors.primary,
                  labelStyle: GoogleFonts.inter(
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.border,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text('FINALIZAR CADASTRO'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}
