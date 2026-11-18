import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:vitta/core/theme/app_colors.dart';

class RatingScreen extends StatefulWidget {
  final String patientName;

  const RatingScreen({required this.patientName, super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  // Humanized Metrics
  int _punctualityScore = 0; // 1-3 (Bad, Ok, Good)
  bool? _orientationExchange; // Yes/No
  int _affinityScore = 0; // 1-5 Hearts

  final TextEditingController _commentController = TextEditingController();

  void _submitRating() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avaliação de vínculo registrada! A Vitta agradece.'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text('Avaliação de Vínculo',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 32),

            // 1. Technical (Punctuality)
            _buildQuestionCard(
              title: '1. O profissional foi pontual?',
              subtitle: 'Compromisso técnico',
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSelectableIcon(
                      Icons.timer_off_outlined,
                      'Atrasou',
                      1,
                      _punctualityScore,
                      (val) => setState(() => _punctualityScore = val)),
                  _buildSelectableIcon(
                      Icons.timer_outlined,
                      'No horário',
                      3,
                      _punctualityScore,
                      (val) => setState(() => _punctualityScore = val)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Educational (Exchange)
            _buildQuestionCard(
              title: '2. Houve troca de orientações?',
              subtitle: 'Você aprendeu algo novo sobre o cuidado hoje?',
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSelectableChip(
                      'Não houve troca',
                      false,
                      _orientationExchange,
                      (val) => setState(() => _orientationExchange = val)),
                  _buildSelectableChip(
                      'Sim, aprendi algo!',
                      true,
                      _orientationExchange,
                      (val) => setState(() => _orientationExchange = val)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Human (Bond)
            _buildQuestionCard(
              title: '3. Como foi o acolhimento?',
              subtitle: 'Houve respeito e afinidade com o paciente?',
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => _affinityScore = index + 1),
                    icon: Icon(
                      index < _affinityScore
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: AppColors.error, // Red hearts
                      size: 32,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 32),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Algum recado especial ou observação?',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_punctualityScore > 0 && _affinityScore > 0)
                    ? _submitRating
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('ENVIAR AVALIAÇÃO'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.vittaSageLight,
          child: Text('CM',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 20)),
        ),
        const SizedBox(height: 16),
        Text(
          'Avalie o plantão com\nDr. Carlos Mendes',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Sua opinião fortalece nossa comunidade de cuidado.',
          textAlign: TextAlign.center,
          style:
              GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(
      {required String title,
      required String subtitle,
      required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          Text(subtitle,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildSelectableIcon(IconData icon, String label, int value,
      int groupValue, Function(int) onTap) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vittaSageLight : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? AppColors.vittaSage : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon,
                color:
                    isSelected ? AppColors.vittaSage : AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppColors.vittaSage
                        : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableChip(
      String label, bool value, bool? groupValue, Function(bool) onTap) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
  }
}
