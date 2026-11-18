import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitta/core/theme/app_colors.dart';

class PatientSetupScreen extends StatefulWidget {
  const PatientSetupScreen({super.key});

  @override
  State<PatientSetupScreen> createState() => _PatientSetupScreenState();
}

class _PatientSetupScreenState extends State<PatientSetupScreen> {
  final _clinicalDataController = TextEditingController();
  final _addressController = TextEditingController();
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
    // Mock saving patient profile data
    context.go('/');
  }

  @override
  void dispose() {
    _clinicalDataController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Perfil do Paciente',
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
              'Para um cuidado personalizado, precisamos conhecer melhor o paciente.',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Dados Clínicos'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clinicalDataController,
              decoration: const InputDecoration(
                labelText: 'Condições Clínicas / Limitações',
                hintText: 'Ex: Diabético, Hipertenso, Alzheimer leve...',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.medical_information_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Endereço'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Endereço Completo',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Gostos e Preferências'),
            const SizedBox(height: 8),
            Text(
              'Selecione o que o paciente gosta. Isso ajuda a criar uma conexão humana com o cuidador.',
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
              child: const Text('FINALIZAR PERFIL'),
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
