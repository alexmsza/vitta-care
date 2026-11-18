import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitta/core/theme/app_colors.dart';

class PatientProfileViewScreen extends StatelessWidget {
  const PatientProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    const patientData = {
      'name': 'Sra. Maria Oliveira',
      'age': '78 anos',
      'allergies': 'Dipirona',
      'medications': 'Losartana 50mg (Manhã), AAS 100mg (Almoço)',
      'routine':
          'Acorda às 07:00, Café às 08:00. Gosta de caminhar no jardim às 10:00.',
      'preferences':
          'Ama música clássica (Chopin). Gosta de conversar sobre viagens antigas. Não gosta de ser interrompida durante a novela.',
      'surgeries': 'Apendicectomia (1990), Prótese de Quadril (2018)',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Ficha do Paciente',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.vittaSageLight,
                    child:
                        Icon(Icons.person, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    patientData['name']!,
                    style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  Text(
                    patientData['age']!,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              'Alergias & Alertas',
              Icons.warning_amber_rounded,
              patientData['allergies']!,
              isAlert: true,
            ),
            _buildSection(
                'Medicamentos', Icons.medication, patientData['medications']!),
            _buildSection('Histórico Cirúrgico', Icons.medical_services,
                patientData['surgeries']!),
            _buildSection(
                'Rotina Diária', Icons.schedule, patientData['routine']!),
            _buildSection('Gostos & Preferências (Humanização)', Icons.favorite,
                patientData['preferences']!,
                highlight: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, String content,
      {bool isAlert = false, bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert
            ? AppColors.error.withValues(alpha: 0.05)
            : (highlight ? AppColors.vittaCream : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert
              ? AppColors.error.withValues(alpha: 0.3)
              : (highlight
                  ? AppColors.secondary.withValues(alpha: 0.3)
                  : AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  color: isAlert ? AppColors.error : AppColors.primary,
                  size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isAlert ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textPrimary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
