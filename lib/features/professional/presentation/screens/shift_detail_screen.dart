import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/shift.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/shift_provider.dart';

class ShiftDetailScreen extends ConsumerStatefulWidget {
  final Shift shift;

  const ShiftDetailScreen({super.key, required this.shift});

  @override
  ConsumerState<ShiftDetailScreen> createState() => _ShiftDetailScreenState();
}

class _ShiftDetailScreenState extends ConsumerState<ShiftDetailScreen> {
  bool _loadingChat = false;

  bool get _isChatUnlocked {
    final diff = widget.shift.dateStart.difference(DateTime.now());
    return diff <= const Duration(hours: 24) &&
        widget.shift.status != 'completed';
  }

  Future<void> _openChat() async {
    setState(() => _loadingChat = true);
    try {
      final token = ref.read(authStateProvider)?.token ?? '';
      final conversation = await ref
          .read(chatRepositoryProvider)
          .getConversationByRequest(token, widget.shift.id, 'shift');
      if (mounted) {
        context.push('/chat/${conversation.id}', extra: conversation);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir a conversa.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingChat = false);
    }
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Cancelar plantão?',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atenção: cancelamentos reduzem sua pontuação de confiabilidade.',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                  height: 1.4),
            ),
            const SizedBox(height: 10),
            Text(
              'Cuidadores com pontuação baixa ficam menos visíveis para as famílias e podem ser suspensos da plataforma.',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Manter plantão',
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(cancelShiftControllerProvider.notifier)
          .cancel(widget.shift.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shift = widget.shift;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final cancelState = ref.watch(cancelShiftControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.vittaPetrol,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.vittaPetrol, AppColors.vittaPetrolLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Status chip
                        _StatusChip(status: shift.status),
                        const SizedBox(height: 10),
                        Text(
                          shift.title,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currency.format(shift.value),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Patient / client info card ─────────────────
                  _InfoCard(
                    title: 'Informações do atendimento',
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Local / Responsável',
                        value: shift.hospitalName,
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Endereço',
                        value: shift.address,
                      ),
                      if (shift.description != null &&
                          shift.description!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.notes_rounded,
                          label: 'Observações',
                          value: shift.description!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Date / time card ──────────────────────────
                  _InfoCard(
                    title: 'Data e horário',
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Início',
                        value: DateFormat("dd/MM/yyyy 'às' HH:mm")
                            .format(shift.dateStart),
                      ),
                      _InfoRow(
                        icon: Icons.flag_outlined,
                        label: 'Término',
                        value: DateFormat("dd/MM/yyyy 'às' HH:mm")
                            .format(shift.dateEnd),
                      ),
                      _InfoRow(
                        icon: Icons.timelapse_rounded,
                        label: 'Duração',
                        value: '${shift.duration.inHours}h',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── History card ──────────────────────────────
                  _InfoCard(
                    title: 'Histórico',
                    children: [
                      _HistoryEntry(
                        label: 'Plantão criado',
                        date: shift.dateStart
                            .subtract(const Duration(days: 2)),
                        color: AppColors.textSecondary,
                      ),
                      _HistoryEntry(
                        label: 'Aceito por você',
                        date: shift.dateStart
                            .subtract(const Duration(days: 1)),
                        color: AppColors.primary,
                      ),
                      if (shift.status == 'in_progress')
                        _HistoryEntry(
                          label: 'Em andamento',
                          date: shift.dateStart,
                          color: AppColors.warning,
                        ),
                      if (shift.status == 'completed')
                        _HistoryEntry(
                          label: 'Concluído',
                          date: shift.dateEnd,
                          color: AppColors.success,
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Action buttons ────────────────────────────

                  // Chat button — only within 24h
                  if (_isChatUnlocked) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _loadingChat ? null : _openChat,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.vittaPetrol,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: _loadingChat
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.chat_rounded, size: 20),
                        label: Text(
                          'Enviar mensagem',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else if (shift.status != 'completed') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_clock_rounded,
                              size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Chat disponível 24h antes da visita',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Cancel button — not for completed shifts
                  if (shift.status != 'completed')
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: cancelState.isLoading
                            ? null
                            : _confirmCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: cancelState.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.error),
                              )
                            : const Icon(Icons.cancel_outlined, size: 18),
                        label: Text(
                          'Cancelar plantão',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'assigned' => ('Aceito', AppColors.success),
      'in_progress' => ('Em andamento', AppColors.warning),
      'completed' => ('Concluído', AppColors.textSecondary),
      _ => (status, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  final String label;
  final DateTime date;
  final Color color;
  const _HistoryEntry(
      {required this.label, required this.date, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textPrimary)),
          ),
          Text(
            DateFormat('dd/MM HH:mm').format(date),
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
