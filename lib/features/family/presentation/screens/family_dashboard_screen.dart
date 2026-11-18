import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/on_demand_request.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/on_demand_provider.dart';

// ─────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────

class FamilyDashboard extends ConsumerWidget {
  const FamilyDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final requestsAsync = ref.watch(myOnDemandRequestsProvider);
    final initials =
        (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'F';

    return PopScope(
      canPop: false,
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(myOnDemandRequestsProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── HERO HEADER ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _FamilyHeader(
                userName: user?.name ?? 'Família',
                initials: initials,
                onMenuSelected: (value) {
                  if (value == 'profile') context.push('/profile');
                  if (value == 'logout') {
                    ref.read(authStateProvider.notifier).logout();
                  }
                },
              ),
            ),

            // ── SOLICITAÇÕES ATIVAS ───────────────────────────────
            SliverToBoxAdapter(
              child: requestsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (requests) {
                  final active = requests
                      .where((r) =>
                          r.status != 'completed' && r.status != 'cancelled')
                      .toList();
                  if (active.isEmpty) return const SizedBox.shrink();
                  return _ActiveRequestsSection(requests: active);
                },
              ),
            ),

            // ── CTA PRINCIPAL ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: _RequestNowButton(
                  onTap: () => _showNewRequestSheet(context),
                ),
              ),
            ),

            // ── ACESSO RÁPIDO ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acesso Rápido',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _QuickCard(
                          icon: Icons.history,
                          label: 'Histórico',
                          color: AppColors.primary,
                          onTap: () => context.push('/history'),
                        ),
                        const SizedBox(width: 12),
                        _QuickCard(
                          icon: Icons.chat_bubble_outline,
                          label: 'Mensagens',
                          color: AppColors.vittaSage,
                          onTap: () => context.push('/conversations'),
                        ),
                        const SizedBox(width: 12),
                        _QuickCard(
                          icon: Icons.help_outline,
                          label: 'Ajuda',
                          color: AppColors.accent,
                          onTap: () => context.push('/faq'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _QuickCard(
                          icon: Icons.medical_information_outlined,
                          label: 'Anamnese',
                          color: AppColors.vittaSage,
                          onTap: () => context.push('/clinical-record'),
                        ),
                        const SizedBox(width: 12),
                        _QuickCard(
                          icon: Icons.person_outline,
                          label: 'Meu Perfil',
                          color: AppColors.accent,
                          onTap: () => context.push('/profile'),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showNewRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewRequestSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────────────────────────────

class _FamilyHeader extends StatelessWidget {
  final String userName;
  final String initials;
  final void Function(String) onMenuSelected;

  const _FamilyHeader({
    required this.userName,
    required this.initials,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.vittaPetrol, AppColors.vittaPetrolLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 12, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: avatar + name + menu ──
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, $userName!',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Como podemos ajudar hoje?',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon:
                        const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: onMenuSelected,
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'profile',
                        child: Row(children: [
                          Icon(Icons.person_outline, size: 20),
                          SizedBox(width: 12),
                          Text('Meu Perfil'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 12),
                          Text('Sair'),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Hero copy ──
              Text(
                'Cuidado humanizado\npara quem você ama.',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Conectamos sua família ao cuidador ideal em minutos.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SOLICITAÇÕES ATIVAS
// ─────────────────────────────────────────────────────────────────

class _ActiveRequestsSection extends StatelessWidget {
  final List<OnDemandRequest> requests;

  const _ActiveRequestsSection({required this.requests});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solicitações Ativas',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...requests.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/request-detail', extra: r),
                child: _ActiveRequestCard(request: r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveRequestCard extends ConsumerWidget {
  final OnDemandRequest request;

  const _ActiveRequestCard({required this.request});

  Color get _statusColor => switch (request.status) {
        'searching' => Colors.blue,
        'matched' => AppColors.success,
        'in_progress' => AppColors.warning,
        _ => Colors.grey,
      };

  String get _statusLabel => switch (request.status) {
        'searching' => 'Buscando cuidador...',
        'matched' => 'Cuidador encontrado!',
        'in_progress' => 'Em atendimento',
        _ => request.status,
      };

  IconData get _statusIcon => switch (request.status) {
        'searching' => Icons.search,
        'matched' => Icons.check_circle_outline,
        'in_progress' => Icons.favorite_outline,
        _ => Icons.info_outline,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutesAgo =
        DateTime.now().difference(request.createdAt).inMinutes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status pill + time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon, size: 14, color: _statusColor),
                    const SizedBox(width: 6),
                    Text(
                      _statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'há ${minutesAgo}min',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Patient
          Row(children: [
            const Icon(Icons.person_outline,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              request.patientName,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ]),
          const SizedBox(height: 6),

          // Address
          Row(children: [
            const Icon(Icons.location_on_outlined,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                request.address,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),

          // Professional (when matched)
          if (request.status == 'matched' &&
              request.professionalName != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.medical_services_outlined,
                  size: 16, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                request.professionalName!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ]),
          ],

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Toque para ver detalhes',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BOTÃO CTA
// ─────────────────────────────────────────────────────────────────

class _RequestNowButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RequestNowButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.vittaPetrol, AppColors.vittaPetrolLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_circle_outline,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solicitar Cuidado Agora',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Cuidador em até 30 minutos',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ACESSO RÁPIDO
// ─────────────────────────────────────────────────────────────────

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BOTTOM SHEET — NOVA SOLICITAÇÃO
// ─────────────────────────────────────────────────────────────────

class _NewRequestSheet extends ConsumerStatefulWidget {
  const _NewRequestSheet();

  @override
  ConsumerState<_NewRequestSheet> createState() => _NewRequestSheetState();
}

class _NewRequestSheetState extends ConsumerState<_NewRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _patientNameCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrlState = ref.watch(onDemandControllerProvider);

    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              const SizedBox(height: 20),

              Text(
                'Nova Solicitação',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Preencha os dados e encontraremos o cuidador ideal.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _patientNameCtrl,
                decoration: _inputDeco(
                    'Nome do Paciente', 'Ex: Minha mãe, João Silva'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressCtrl,
                decoration: _inputDeco(
                    'Endereço de Atendimento', 'Rua, número, bairro'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: _inputDeco(
                  'Observações (opcional)',
                  'Condições do paciente, cuidados específicos...',
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: ctrlState.isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          await ref
                              .read(onDemandControllerProvider.notifier)
                              .create(
                                patientName:
                                    _patientNameCtrl.text.trim(),
                                address: _addressCtrl.text.trim(),
                                notes: _notesCtrl.text.trim().isEmpty
                                    ? null
                                    : _notesCtrl.text.trim(),
                              );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                  child: ctrlState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Confirmar Solicitação',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      );
}
