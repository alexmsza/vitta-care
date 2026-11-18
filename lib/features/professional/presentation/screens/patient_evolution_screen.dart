import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:vitta/core/theme/app_colors.dart';

class PatientEvolutionScreen extends StatefulWidget {
  const PatientEvolutionScreen({super.key});

  @override
  State<PatientEvolutionScreen> createState() => _PatientEvolutionScreenState();
}

class _PatientEvolutionScreenState extends State<PatientEvolutionScreen> {
  // RDC 11 - Sinais Vitais
  final _bpController = TextEditingController();
  final _hrController = TextEditingController();
  final _tempController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _hgtController = TextEditingController(); // Glicemia
  final _painController = TextEditingController(); // Escala de Dor 0-10

  // Humanização e Técnica
  final _orientationController =
      TextEditingController(); // O que ensinou à família
  final _technicalEvolutionController =
      TextEditingController(); // Respaldo legal

  // Checklists
  bool _bath = false;
  bool _oralHygiene = false;
  bool _changePosition = false;
  bool _medicationAdministered = false;
  bool _lowStockAlert = false;

  @override
  void dispose() {
    _bpController.dispose();
    _hrController.dispose();
    _tempController.dispose();
    _spo2Controller.dispose();
    _hgtController.dispose();
    _painController.dispose();
    _orientationController.dispose();
    _technicalEvolutionController.dispose();
    super.dispose();
  }

  void _signAndFinish() {
    // Simulação de Assinatura Digital (Senha ou Biometria)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assinatura Digital'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Confirme sua senha para assinar o prontuário:'),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Senha / PIN',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prontuário assinado e salvo com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.pop(); // Retorna para Agenda
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('ASSINAR E FINALIZAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading:
            const BackButton(color: AppColors.textPrimary), // Garantindo botão voltar
        title: Text('Diário de Bordo & Evolução',
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
            _buildPatientHeader(),
            const SizedBox(height: 24),
            _buildSectionTitle('1. Sinais Vitais (RDC 11/2006)'),
            const SizedBox(height: 16),
            _buildVitalsGrid(),
            const SizedBox(height: 24),
            _buildSectionTitle('2. Cuidados Realizados'),
            const SizedBox(height: 8),
            _buildChecklist(),
            const SizedBox(height: 24),
            _buildSectionTitle('3. Humanização & Educação'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.vittaSageLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.vittaSage),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.diversity_1,
                          color: AppColors.vittaSage, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Troca de Saberes (Teoria da Dádiva)",
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.vittaSage),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _orientationController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'O que você ensinou à família hoje? (Ex: Como realizar a mudança de decúbito)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('4. Evolução Técnica (Obrigatório)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _technicalEvolutionController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText:
                    'Descreva a evolução clínica, intercorrências e resposta ao tratamento...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('5. Materiais e Insumos'),
            SwitchListTile(
              title: const Text('Solicitar Reposição de Estoque'),
              subtitle: const Text('Marque se algum insumo está acabando'),
              value: _lowStockAlert,
              activeThumbColor: Colors.orange,
              onChanged: (val) => setState(() => _lowStockAlert = val),
              secondary: const Icon(Icons.inventory_2_outlined),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _signAndFinish,
                icon: const Icon(Icons.fingerprint),
                label: const Text('ASSINAR DIGITALMENTE E FINALIZAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.vittaSageLight,
          child: Text('MO',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sra. Maria Oliveira',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            Text('PAD: Atenção Domiciliar - Alta Complexidade',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary));
  }

  Widget _buildVitalsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildVitalInput(
                    'PA (mmHg)', _bpController, Icons.favorite_border)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildVitalInput(
                    'FC (bpm)', _hrController, Icons.monitor_heart_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildVitalInput(
                    'Temp (°C)', _tempController, Icons.thermostat)),
            const SizedBox(width: 12),
            Expanded(
                child:
                    _buildVitalInput('SpO2 (%)', _spo2Controller, Icons.air)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildVitalInput(
                    'HGT (mg/dL)', _hgtController, Icons.bloodtype)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildVitalInput('Dor (0-10)', _painController,
                    Icons.sentiment_dissatisfied)),
          ],
        ),
      ],
    );
  }

  Widget _buildVitalInput(
      String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildChecklist() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            title: const Text('Administração de Medicamentos'),
            value: _medicationAdministered,
            onChanged: (val) => setState(() => _medicationAdministered = val!),
            activeColor: AppColors.primary,
          ),
          const Divider(height: 1),
          CheckboxListTile(
            title: const Text('Banho (Leito/Aspersão)'),
            value: _bath,
            onChanged: (val) => setState(() => _bath = val!),
            activeColor: AppColors.primary,
          ),
          const Divider(height: 1),
          CheckboxListTile(
            title: const Text('Higiene Oral'),
            value: _oralHygiene,
            onChanged: (val) => setState(() => _oralHygiene = val!),
            activeColor: AppColors.primary,
          ),
          const Divider(height: 1),
          CheckboxListTile(
            title: const Text('Mudança de Decúbito'),
            value: _changePosition,
            onChanged: (val) => setState(() => _changePosition = val!),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
