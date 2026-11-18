import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/on_demand_request.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/on_demand_provider.dart';

class ProfessionalServiceRequestDetailScreen extends ConsumerStatefulWidget {
  final OnDemandRequest request;

  const ProfessionalServiceRequestDetailScreen({
    super.key,
    required this.request,
  });

  @override
  ConsumerState<ProfessionalServiceRequestDetailScreen> createState() =>
      _ProfessionalServiceRequestDetailScreenState();
}

class _ProfessionalServiceRequestDetailScreenState
    extends ConsumerState<ProfessionalServiceRequestDetailScreen> {
  bool _loadingChat = false;

  Future<void> _openChat() async {
    setState(() => _loadingChat = true);
    try {
      final token = ref.read(authStateProvider)?.token ?? '';
      final conversation = await ref
          .read(chatRepositoryProvider)
          .getConversationByRequest(token, widget.request.id, 'service_request');
      if (mounted) {
        context.push('/chat/${conversation.id}', extra: conversation);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir a conversa.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingChat = false);
    }
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cancelar consulta?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          'Isso libera a família para buscar outro profissional. '
          'Cancelamentos podem impactar sua confiabilidade.',
          style: GoogleFonts.inter(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Manter consulta',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref
        .read(professionalOnDemandControllerProvider.notifier)
        .cancelAccepted(widget.request.id);
    final error = ref.read(professionalOnDemandControllerProvider).error;
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().contains('403')
                ? 'O cancelamento desta solicitação é permitido apenas pela família.'
                : 'Não foi possível cancelar a consulta.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consulta cancelada.'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  Color get _statusColor => switch (widget.request.status) {
        'matched' => AppColors.success,
        'in_progress' => AppColors.warning,
        'completed' => AppColors.textSecondary,
        _ => AppColors.textSecondary,
      };

  String get _statusLabel => switch (widget.request.status) {
        'matched' => 'Consulta aceita',
        'in_progress' => 'Em atendimento',
        'completed' => 'Concluído',
        _ => widget.request.status,
      };

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final controller = ref.watch(professionalOnDemandControllerProvider);
    final createdAgo = DateTime.now().difference(request.createdAt).inMinutes;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.vittaSage],
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
                        _StatusPill(label: _statusLabel, color: _statusColor),
                        const SizedBox(height: 12),
                        Text(
                          request.patientName,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Solicitada há ${createdAgo}min',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ClientCard(request: request),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'DADOS DA CONSULTA',
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Paciente',
                        value: request.patientName,
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Endereço',
                        value: request.address,
                      ),
                      if (request.notes != null && request.notes!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.notes_rounded,
                          label: 'Observações',
                          value: request.notes!,
                        ),
                      if (request.distanceKm != null)
                        _InfoRow(
                          icon: Icons.near_me_outlined,
                          label: 'Distância',
                          value: '${request.distanceKm!.toStringAsFixed(1)} km',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'LINHA DO TEMPO',
                    children: [
                      _HistoryEntry(
                        label: 'Solicitação criada',
                        date: request.createdAt,
                        color: AppColors.primary,
                      ),
                      if (request.matchedAt != null)
                        _HistoryEntry(
                          label: 'Aceita por você',
                          date: request.matchedAt!,
                          color: AppColors.success,
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _loadingChat ? null : _openChat,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _loadingChat
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.chat_rounded, size: 20),
                      label: Text(
                        'Abrir chat com a família',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (request.status != 'completed')
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed:
                            controller.isLoading ? null : _confirmCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: controller.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.error,
                                ),
                              )
                            : const Icon(Icons.cancel_outlined, size: 18),
                        label: Text(
                          'Cancelar consulta',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
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

class _ClientCard extends StatelessWidget {
  final OnDemandRequest request;

  const _ClientCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.vittaSageLight,
            child: Text(
              request.patientName[0].toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Família #${request.familyId}',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Conta verificada para atendimento on-demand',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RatingPill(
                      icon: Icons.star_rounded,
                      label: 'Cliente',
                      value: '4.9',
                      color: AppColors.warning,
                    ),
                    _RatingPill(
                      icon: Icons.verified_user_outlined,
                      label: 'Conta',
                      value: 'verificada',
                      color: AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RatingPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            '$label $value',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

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

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

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
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
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

  const _HistoryEntry({
    required this.label,
    required this.date,
    required this.color,
  });

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
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            DateFormat('dd/MM HH:mm').format(date),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
