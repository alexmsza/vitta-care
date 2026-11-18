import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vitta/core/theme/app_colors.dart';
import 'package:vitta/features/family/presentation/providers/service_request_provider.dart';

class PaymentSummaryScreen extends ConsumerWidget {
  const PaymentSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serviceRequestControllerProvider);
    final controller = ref.read(serviceRequestControllerProvider.notifier);
    final price = controller.estimatedPrice;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Resumo e Pagamento',
            style:
                GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(context, state, price),
            const SizedBox(height: 24),
            _buildGuaranteeCard(context),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Mock Payment
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text('Processando',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                            color: AppColors.primary),
                        const SizedBox(height: 24),
                        Text('Conectando com segurança...',
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                );

                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close dialog
                    context.go('/'); // Back to home
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Pagamento confirmado! Profissionais serão notificados.',
                            style: GoogleFonts.inter()),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: Text('PAGAR E CONFIRMAR',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, ServiceRequestState state, double price) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Resumo do Pedido',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const Divider(height: 32),
          _buildRow(
              'Data',
              state.selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(state.selectedDate!)
                  : '-'),
          _buildRow('Hora', state.selectedTime?.format(context) ?? '-'),
          _buildRow('Duração', _getDurationLabel(state.duration)),
          if (state.selectedTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.selectedTags
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.vittaSageLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(t,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
            ),
          ],
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary)),
              Text(
                NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                    .format(price),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuaranteeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.vittaSageLight,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.verified, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Garantia Vitta',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Se o profissional não comparecer, garantimos a substituição em até 1 hora.',
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      height: 1.4,
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary)),
          Text(value,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  String _getDurationLabel(dynamic duration) {
    if (duration == null) return '-';
    return duration.toString().split('.').last == 'eightHours'
        ? '8h'
        : duration.toString().split('.').last == 'twelveHours'
            ? '12h'
            : '24h';
  }
}
