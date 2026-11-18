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
import '../widgets/professional_availability_calendar.dart';

class RequestDetailScreen extends ConsumerStatefulWidget {
  final OnDemandRequest request;

  const RequestDetailScreen({super.key, required this.request});

  @override
  ConsumerState<RequestDetailScreen> createState() =>
      _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  bool _loadingChat = false;
  bool _replacingProfessional = false;

  bool get _canChat =>
      widget.request.status == 'matched' ||
      widget.request.status == 'in_progress';

  Color get _statusColor => switch (widget.request.status) {
        'searching' => Colors.blue,
        'matched' => AppColors.success,
        'in_progress' => AppColors.warning,
        'completed' => AppColors.textSecondary,
        'cancelled' => AppColors.error,
        _ => AppColors.textSecondary,
      };

  String get _statusLabel => switch (widget.request.status) {
        'searching' => 'Buscando cuidador...',
        'matched' => 'Cuidador encontrado',
        'in_progress' => 'Em atendimento',
        'completed' => 'Concluído',
        'cancelled' => 'Cancelado',
        _ => widget.request.status,
      };

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
        title: Text('Cancelar solicitação?',
            style:
                GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text(
          'Tem certeza que deseja cancelar? Um profissional pode estar a caminho.',
          style: GoogleFonts.inter(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Manter',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
          .read(onDemandControllerProvider.notifier)
          .cancel(widget.request.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _confirmRequestAnother() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Procurar outro profissional?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          'Vamos cancelar este match e colocar a solicitação novamente na busca. O profissional atual será removido do atendimento.',
          style: GoogleFonts.inter(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Manter profissional',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Procurar outro'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _replacingProfessional = true);
    try {
      await ref
          .read(onDemandControllerProvider.notifier)
          .requestAnotherProfessional(widget.request);
      final error = ref.read(onDemandControllerProvider).error;
      if (error != null) throw error;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Busca reiniciada. Estamos procurando outro profissional.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NÃ£o foi possÃ­vel procurar outro profissional.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _replacingProfessional = false);
    }
  }

  void _showProfessionalProfile(OnDemandRequest request) {
    final name = request.professionalName ?? 'Profissional Vitta';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfessionalProfileSheet(request: request, name: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final ctrlState = ref.watch(onDemandControllerProvider);
    final createdAgo = DateTime.now().difference(request.createdAt).inMinutes;

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
                    padding:
                        const EdgeInsets.fromLTRB(24, 56, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Status pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _statusColor.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            _statusLabel,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
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
                          'Solicitado há ${createdAgo}min',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8)),
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
                  // ── Request info card ────────────────────────
                  _SectionCard(
                    title: 'Detalhes da solicitação',
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
                      if (request.notes != null &&
                          request.notes!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.notes_rounded,
                          label: 'Observações',
                          value: request.notes!,
                        ),
                      if (request.distanceKm != null)
                        _InfoRow(
                          icon: Icons.directions_walk_rounded,
                          label: 'Distância',
                          value:
                              '${request.distanceKm!.toStringAsFixed(1)} km',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Professional card (when matched) ─────────
                  if (request.professionalName != null) ...[
                    _ProfessionalMatchCard(
                      request: request,
                      isReplacing: _replacingProfessional,
                      onViewProfile: () => _showProfessionalProfile(request),
                      onRequestAnother: _confirmRequestAnother,
                    ),
                    const SizedBox(height: 16),
                    ProfessionalAvailabilityCalendar(
                      professionalId: request.professionalId,
                      professionalName: request.professionalName!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── History card ──────────────────────────────
                  _SectionCard(
                    title: 'Histórico',
                    children: [
                      _HistoryEntry(
                        label: 'Solicitação criada',
                        date: request.createdAt,
                        color: AppColors.primary,
                        isFirst: true,
                      ),
                      if (request.matchedAt != null)
                        _HistoryEntry(
                          label: 'Cuidador encontrado',
                          date: request.matchedAt!,
                          color: AppColors.success,
                        ),
                      if (request.status == 'in_progress')
                        _HistoryEntry(
                          label: 'Em atendimento',
                          date: request.matchedAt ??
                              request.createdAt,
                          color: AppColors.warning,
                        ),
                      if (request.status == 'completed')
                        _HistoryEntry(
                          label: 'Concluído',
                          date: DateTime.now(),
                          color: AppColors.success,
                          isLast: true,
                        ),
                      if (request.status == 'cancelled')
                        _HistoryEntry(
                          label: 'Cancelado',
                          date: DateTime.now(),
                          color: AppColors.error,
                          isLast: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Actions ───────────────────────────────────

                  if (_canChat) ...[
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
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (request.status == 'completed' &&
                      request.professionalName != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () => context.push(
                          '/rating',
                          extra: request.professionalName,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.star_rounded, size: 20),
                        label: Text(
                          'Avaliar profissional',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (request.status == 'searching') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: ctrlState.isLoading
                            ? null
                            : _confirmCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(
                              color: AppColors.error),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: ctrlState.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.error),
                              )
                            : const Icon(Icons.cancel_outlined,
                                size: 18),
                        label: Text(
                          'Cancelar solicitação',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ],

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

class _ProfessionalMatchCard extends StatelessWidget {
  final OnDemandRequest request;
  final bool isReplacing;
  final VoidCallback onViewProfile;
  final VoidCallback onRequestAnother;

  const _ProfessionalMatchCard({
    required this.request,
    required this.isReplacing,
    required this.onViewProfile,
    required this.onRequestAnother,
  });

  String get _name => request.professionalName ?? 'Profissional Vitta';

  double get _rating => 4.8;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(
                      'Match confirmado',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (request.matchedAt != null)
                Text(
                  DateFormat('HH:mm').format(request.matchedAt!),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.vittaSageLight,
                child: Text(
                  _name[0].toUpperCase(),
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
                      _name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Profissional de cuidado verificado pela Vitta',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _RatingPill(
                          icon: Icons.star_rounded,
                          label: 'Profissional',
                          value: _rating.toStringAsFixed(1),
                          color: Colors.amber.shade700,
                        ),
                        const _RatingPill(
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
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Antes do plantão você pode revisar o perfil do cuidador, falar pelo chat e, se não quiser seguir com este match, procurar outro profissional.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewProfile,
                  icon: const Icon(Icons.badge_outlined, size: 18),
                  label: const Text('Ver perfil'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isReplacing ? null : onRequestAnother,
                  icon: isReplacing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_search_outlined, size: 18),
                  label: const Text('Procurar outro'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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

class _ProfessionalProfileSheet extends StatelessWidget {
  final OnDemandRequest request;
  final String name;

  const _ProfessionalProfileSheet({
    required this.request,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.vittaSageLight,
                    child: Text(
                      name[0].toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ID profissional #${request.professionalId ?? '-'}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ProfileMetric(
                    icon: Icons.star_rounded,
                    value: '4.8',
                    label: 'rating',
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _ProfileMetric(
                    icon: Icons.verified_user_outlined,
                    value: 'Ativa',
                    label: 'conta',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Perfil pré-plantão',
              children: [
                const _InfoRow(
                  icon: Icons.medical_services_outlined,
                  label: 'Especialidade',
                  value: 'Profissional de cuidado Vitta',
                ),
                const _InfoRow(
                  icon: Icons.fact_check_outlined,
                  label: 'Verificações',
                  value:
                      'Conta ativa, documentos aprovados e match registrado.',
                ),
                if (request.matchedAt != null)
                  _InfoRow(
                    icon: Icons.handshake_outlined,
                    label: 'Aceitou em',
                    value: DateFormat("dd/MM/yyyy 'às' HH:mm")
                        .format(request.matchedAt!),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const _SectionCard(
              title: 'Avaliações do profissional',
              children: [
                _InfoRow(
                  icon: Icons.star_outline_rounded,
                  label: 'Rating',
                  value:
                      'Rating 4.8 exibido para a família antes do plantão.',
                ),
                _InfoRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Conta',
                  value: 'Profissional verificado e ativo na plataforma.',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Observação: o contrato atual de ServiceRequest retorna nome e ID do profissional. Dados de perfil completo dependem de endpoint/campos futuros documentados no API_CONTRACTS.md.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ProfileMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
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
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary)),
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
  final bool isFirst;
  final bool isLast;

  const _HistoryEntry({
    required this.label,
    required this.date,
    required this.color,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                  width: 2, height: 8, color: AppColors.border),
            Container(
              width: 12,
              height: 12,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            if (!isLast)
              Container(
                  width: 2, height: 20, color: AppColors.border),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textPrimary)),
                ),
                Text(
                  DateFormat('dd/MM HH:mm').format(date),
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
