import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/on_demand_request.dart';
import '../../../../core/models/shift.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/on_demand_provider.dart';
import '../providers/shift_provider.dart';
import '../widgets/professional_unavailability_calendar.dart';

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// MAIN SCREEN �?" Top-Nav layout
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class ProfessionalDashboard extends ConsumerStatefulWidget {
  const ProfessionalDashboard({super.key});

  @override
  ConsumerState<ProfessionalDashboard> createState() =>
      _ProfessionalDashboardState();
}

class _ProfessionalDashboardState extends ConsumerState<ProfessionalDashboard> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  static const _navItems = <_NavItem>[
    _NavItem('Início', Icons.home_rounded),
    _NavItem('Plantões', Icons.medical_services_rounded),
    _NavItem('Avisos', Icons.warning_amber_rounded),
    _NavItem('Lembretes', Icons.notifications_active_rounded),
    _NavItem('Agenda', Icons.calendar_month_rounded),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _switchTo(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final fullName = user?.name ?? 'Profissional';
    final firstName = fullName.trim().split(' ').first;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _DashboardHeader(firstName: firstName),
              _TopNav(
                currentIndex: _currentIndex,
                items: _navItems,
                onTap: _switchTo,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  children: [
                    _HomeTab(onJumpTo: _switchTo, firstName: firstName),
                    const _ShiftsTab(),
                    const _AvisosTab(),
                    const _LembretesTab(),
                    const ProfessionalUnavailabilityCalendar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// HEADER
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class _DashboardHeader extends ConsumerWidget {
  final String firstName;
  const _DashboardHeader({required this.firstName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.vittaPetrol, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.vittaSageLight,
              child: Text(
                firstName.isNotEmpty ? firstName[0].toUpperCase() : 'V',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Olá, $firstName',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Pronta para cuidar com afeto?',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Lembretes',
            icon: const Icon(Icons.notifications_none_rounded,
                color: Colors.white),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const LembretesPreviewSheet(),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'chat':
                  context.push('/conversations');
                  break;
                case 'faq':
                  context.push('/faq');
                  break;
                case 'profile':
                  context.push('/profile');
                  break;
                case 'logout':
                  ref.read(authStateProvider.notifier).logout();
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'chat',
                child: Row(children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 20),
                  SizedBox(width: 12),
                  Text('Mensagens'),
                ]),
              ),
              PopupMenuItem(
                value: 'faq',
                child: Row(children: [
                  Icon(Icons.help_outline_rounded, size: 20),
                  SizedBox(width: 12),
                  Text('Ajuda'),
                ]),
              ),
              PopupMenuItem(
                value: 'profile',
                child: Row(children: [
                  Icon(Icons.person_outline_rounded, size: 20),
                  SizedBox(width: 12),
                  Text('Meu Perfil'),
                ]),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Sair', style: TextStyle(color: AppColors.error)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// TOP NAV
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

class _TopNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _TopNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final item = items[i];
            final isSelected = i == currentIndex;
            return _NavPill(
              label: item.label,
              icon: item.icon,
              isSelected: isSelected,
              onTap: () => onTap(i),
            );
          },
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavPill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected ? Colors.transparent : AppColors.border,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// TAB 1 �?" INÍCIO (resumo do dia)
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class _HomeTab extends ConsumerWidget {
  final ValueChanged<int> onJumpTo;
  final String firstName;
  const _HomeTab({required this.onJumpTo, required this.firstName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myShiftsAsync = ref.watch(myShiftsProvider);
    final acceptedRequestsAsync = ref.watch(acceptedServiceRequestsProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(myShiftsProvider);
        ref.invalidate(acceptedServiceRequestsProvider);
        await Future.wait([
          ref.read(myShiftsProvider.future),
          ref.read(acceptedServiceRequestsProvider.future),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // �"?�"? Quick actions �"?�"?
          _QuickActionsRow(onJumpTo: onJumpTo),
          const SizedBox(height: 20),

          // �"?�"? Próximas assistências �"?�"?
          _SectionHeader(
            title: 'Minhas Assistências',
            badge: _assistenciasCount(myShiftsAsync, acceptedRequestsAsync),
            badgeColor: AppColors.primary,
          ),
          const SizedBox(height: 8),
          _ProximasAssistencias(
            myShiftsAsync: myShiftsAsync,
            acceptedAsync: acceptedRequestsAsync,
            onJumpTo: onJumpTo,
          ),

          const SizedBox(height: 20),

          // �"?�"? Meu último plantão (relatório pós-plantão) �"?�"?
          _UltimoPlantaoSection(myShiftsAsync: myShiftsAsync),
        ],
      ),
    );
  }

  String _assistenciasCount(
    AsyncValue<List<Shift>> shifts,
    AsyncValue<List<OnDemandRequest>> requests,
  ) {
    final s = (shifts.valueOrNull ?? const <Shift>[])
        .where((sh) => sh.status != 'completed' && sh.status != 'cancelled')
        .length;
    final r = requests.valueOrNull?.length ?? 0;
    return '${s + r}';
  }
}

class _QuickActionsRow extends StatelessWidget {
  final ValueChanged<int> onJumpTo;
  const _QuickActionsRow({required this.onJumpTo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickActionTile(
          icon: Icons.medical_services_rounded,
          label: 'Plantões',
          color: AppColors.primary,
          onTap: () => onJumpTo(1),
        ),
        const SizedBox(width: 12),
        _QuickActionTile(
          icon: Icons.warning_amber_rounded,
          label: 'Avisos',
          color: AppColors.warning,
          onTap: () => onJumpTo(2),
        ),
        const SizedBox(width: 12),
        _QuickActionTile(
          icon: Icons.calendar_month_rounded,
          label: 'Agenda',
          color: AppColors.accent,
          onTap: () => onJumpTo(4),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
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

class _ProximasAssistencias extends StatelessWidget {
  final AsyncValue<List<Shift>> myShiftsAsync;
  final AsyncValue<List<OnDemandRequest>> acceptedAsync;
  final ValueChanged<int> onJumpTo;

  const _ProximasAssistencias({
    required this.myShiftsAsync,
    required this.acceptedAsync,
    required this.onJumpTo,
  });

  @override
  Widget build(BuildContext context) {
    if (myShiftsAsync.isLoading || acceptedAsync.isLoading) {
      return Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        decoration: _cardDecoration(),
        child: const CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final shifts = (myShiftsAsync.valueOrNull ?? const <Shift>[])
        .where((s) => s.status != 'completed' && s.status != 'cancelled')
        .toList();
    final requests = acceptedAsync.valueOrNull ?? const <OnDemandRequest>[];

    if (shifts.isEmpty && requests.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            const Icon(Icons.event_available_rounded,
                size: 44, color: AppColors.secondary),
            const SizedBox(height: 12),
            Text(
              'Nenhuma assistência hoje.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Veja oportunidades disponíveis e aceite o próximo plantão.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => onJumpTo(1),
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Buscar plantões'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          ...requests.take(2).map(
                (r) => Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => OnDemandDetailsDialog(request: r),
                    ),
                    child: _OnDemandCard(request: r),
                  ),
                ),
              ),
          ...shifts.take(3).map(
                (s) => Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: _MyShiftListItem(shift: s),
                ),
              ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => onJumpTo(1),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Ver todos os plantões'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// TAB 2 �?" PLANT�.ES (Oportunidades + Meus)
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class _UltimoPlantaoSection extends StatelessWidget {
  final AsyncValue<List<Shift>> myShiftsAsync;

  const _UltimoPlantaoSection({required this.myShiftsAsync});

  @override
  Widget build(BuildContext context) {
    if (myShiftsAsync.isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (myShiftsAsync.hasError) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.warning),
            const SizedBox(height: 8),
            Text(
              'Não foi possível carregar seu último plantão.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final completed = (myShiftsAsync.valueOrNull ?? const <Shift>[])
        .where((s) => s.status == 'completed')
        .toList()
      ..sort((a, b) => b.dateEnd.compareTo(a.dateEnd));

    if (completed.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meu último plantão',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quando você finalizar um plantão, o formulário de relatório aparece aqui.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final shift = completed.first;
    final patientName = shift.patient?.name ?? shift.hospitalName;
    final finishedAt =
        DateFormat("dd/MM 'às' HH:mm", 'pt_BR').format(shift.dateEnd);
    final shiftWindow =
        '${DateFormat("dd/MM 'das' HH:mm", 'pt_BR').format(shift.dateStart)} - ${DateFormat('HH:mm').format(shift.dateEnd)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.post_add_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meu último plantão',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Finalizado em $finishedAt',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _timeAgo(shift.dateEnd),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            patientName,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  shiftWindow,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  shift.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => PatientDetailsDialog(shift: shift),
                  ),
                  icon: const Icon(Icons.person_outline_rounded, size: 18),
                  label: const Text('Ver perfil'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ShiftReportSheet(shift: shift),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text('Escrever relatório'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours} h';
    return 'há ${diff.inDays} d';
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
}

class _ShiftsTab extends ConsumerStatefulWidget {
  const _ShiftsTab();

  @override
  ConsumerState<_ShiftsTab> createState() => _ShiftsTabState();
}

class _ShiftsTabState extends ConsumerState<_ShiftsTab> {
  int _segment = 0; // 0 = oportunidades, 1 = meus
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _SegmentedToggle(
            current: _segment,
            options: const ['Oportunidades', 'Meus Plantões'],
            onChanged: (i) => setState(() => _segment = i),
          ),
        ),
        Expanded(
          child: _segment == 0
              ? _AvailableTab(
                  searchQuery: _searchQuery,
                  selectedFilter: _selectedFilter,
                  onSearchChanged: (v) => setState(() => _searchQuery = v),
                  onFilterChanged: (f) => setState(() => _selectedFilter = f),
                  onAccepted: () => setState(() => _segment = 1),
                )
              : const _MyShiftsTab(),
        ),
      ],
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  final int current;
  final List<String> options;
  final ValueChanged<int> onChanged;

  const _SegmentedToggle({
    required this.current,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final selected = i == current;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    options[i],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AvailableTab extends ConsumerWidget {
  final String searchQuery;
  final String selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onAccepted;

  const _AvailableTab({
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onAccepted,
  });

  List<Shift> _applyFilters(List<Shift> shifts) {
    final filtered = shifts.where((shift) {
      final matchesSearch = searchQuery.isEmpty ||
          shift.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          shift.address.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (shift.description ?? '')
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          (shift.patient?.name ?? '')
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
      final matchesFilter = switch (selectedFilter) {
        'Valor R\$ 500+' => shift.value >= 500,
        _ => true,
      };
      return matchesSearch && matchesFilter;
    }).toList();

    filtered.sort((a, b) {
      if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
      return a.dateStart.compareTo(b.dateStart);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openShiftsAsync = ref.watch(openShiftsProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(openShiftsProvider);
        await ref.read(openShiftsProvider.future);
      },
      child: openShiftsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: const [
            SizedBox(height: 120),
            Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            SizedBox(height: 16),
            Center(
              child: Text(
                  'Erro ao carregar oportunidades. Puxe para tentar novamente.'),
            ),
          ],
        ),
        data: (allShifts) {
          final filtered = _applyFilters(allShifts);

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onChanged: onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Buscar paciente, bairro ou tag...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textSecondary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'Todos',
                              isSelected: selectedFilter == 'Todos',
                              onTap: () => onFilterChanged('Todos'),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Valor R\$ 500+',
                              isSelected: selectedFilter == 'Valor R\$ 500+',
                              onTap: () => onFilterChanged('Valor R\$ 500+'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Plantões disponíveis',
                  badge: '${filtered.length}',
                  badgeColor: AppColors.primary,
                ),
              ),
              if (filtered.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    icon: Icons.search_off_rounded,
                    message: 'Nenhum plantão disponível no momento.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AvailableShiftCard(
                            shift: filtered[i], onAccepted: onAccepted),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MyShiftsTab extends ConsumerWidget {
  const _MyShiftsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myShiftsAsync = ref.watch(myShiftsProvider);
    final acceptedRequestsAsync = ref.watch(acceptedServiceRequestsProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(myShiftsProvider);
        ref.invalidate(acceptedServiceRequestsProvider);
        await Future.wait([
          ref.read(myShiftsProvider.future),
          ref.read(acceptedServiceRequestsProvider.future),
        ]);
      },
      child: Builder(
        builder: (context) {
          if (myShiftsAsync.isLoading || acceptedRequestsAsync.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final shifts = myShiftsAsync.valueOrNull ?? [];
          final requests = acceptedRequestsAsync.valueOrNull ?? [];

          if (shifts.isEmpty && requests.isEmpty) {
            return const _EmptyState(
              icon: Icons.calendar_month_outlined,
              message: 'Você ainda não aceitou nenhum plantão.',
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (requests.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Solicitações Imediatas',
                  badge: '${requests.length}',
                  badgeColor: AppColors.accent,
                ),
                ...requests.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => context.push(
                          '/professional-request-detail',
                          extra: r,
                        ),
                        child: _OnDemandCard(request: r),
                      ),
                    )),
              ],
              if (shifts.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Plantões Programados',
                  badge: '${shifts.length}',
                  badgeColor: AppColors.primary,
                ),
                ...shifts.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MyShiftListItem(shift: s),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// TAB 3 �?" AVISOS / OCORR�SNCIAS
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class _AvisosTab extends StatelessWidget {
  const _AvisosTab();

  void _openReport(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReportarOcorrenciaSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const _SectionHeader(
          title: 'Avisos e Ocorrências',
          badge: '0',
          badgeColor: AppColors.warning,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.warning,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Sem ocorrências por enquanto',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Reporte qualquer situação que precise da atenção da equipe Vitta — atendimento humanizado começa pela escuta.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => _openReport(context),
                icon: const Icon(Icons.add_alert_rounded, size: 18),
                label: const Text('Reportar ocorrência'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// TAB 4 �?" LEMBRETES
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class _LembretesTab extends StatelessWidget {
  const _LembretesTab();

  void _openCreate(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AdicionarLembreteSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const _SectionHeader(
          title: 'Meus Lembretes',
          badge: '0',
          badgeColor: AppColors.primary,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Nenhum lembrete cadastrado',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Crie lembretes para medicações, exames ou tarefas do plantão. Você receberá notificações no horário marcado.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => _openCreate(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Adicionar lembrete'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// CARDS reused
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class _OnDemandCard extends StatelessWidget {
  final OnDemandRequest request;
  final bool showAcceptButton;
  final VoidCallback? onAccepted;

  const _OnDemandCard({
    required this.request,
    // ignore: unused_element_parameter
    this.showAcceptButton = false,
    // ignore: unused_element_parameter
    this.onAccepted,
  });

  String _timeAgo() {
    final diff = DateTime.now().difference(request.createdAt);
    if (diff.inMinutes < 1) return 'agora mesmo';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return 'há ${diff.inDays}d';
  }

  String get _statusLabel => switch (request.status) {
        'in_progress' => 'Em andamento',
        'matched' => 'Atribuído',
        _ => 'Aceito',
      };

  Color get _statusColor => request.status == 'in_progress'
      ? AppColors.success
      : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'IMEDIATO',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _timeAgo(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 12, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (request.distanceKm != null) ...[
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Text(
                        '${request.distanceKm!.toStringAsFixed(1)} km',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.vittaSageLight,
                  child: Text(
                    request.patientName[0].toUpperCase(),
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
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
                        request.patientName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            request.address,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                      if (request.notes != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          request.notes!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableShiftCard extends StatelessWidget {
  final Shift shift;
  final VoidCallback? onAccepted;

  const _AvailableShiftCard({required this.shift, this.onAccepted});

  String _neighborhood(String address) {
    final parts = address.split(' - ');
    if (parts.length >= 2) return parts[1].split(',').first.trim();
    return address;
  }

  Future<void> _showAcceptDialog(BuildContext context) async {
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AcceptShiftDialog(shift: shift),
    );
    if (accepted == true) onAccepted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showAcceptDialog(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: shift.isUrgent
                ? AppColors.warning.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: shift.isUrgent
                    ? AppColors.warning.withValues(alpha: 0.12)
                    : AppColors.vittaSageLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('dd').format(shift.dateStart),
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: shift.isUrgent
                          ? AppColors.warning
                          : AppColors.primary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM', 'pt_BR')
                        .format(shift.dateStart)
                        .toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (shift.isUrgent) ...[
                        const Icon(Icons.bolt_rounded,
                            size: 16, color: AppColors.warning),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          _neighborhood(shift.address),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        DateFormat('HH:mm').format(shift.dateStart),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              currency.format(shift.value),
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            if (shift.isUrgent) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'URGENTE x${shift.urgencyMultiplier.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class AcceptShiftDialog extends ConsumerStatefulWidget {
  final Shift shift;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const AcceptShiftDialog({
    super.key,
    required this.shift,
    this.onAccept,
    this.onDecline,
  });

  @override
  ConsumerState<AcceptShiftDialog> createState() => _AcceptShiftDialogState();
}

class _AcceptShiftDialogState extends ConsumerState<AcceptShiftDialog>
    with SingleTickerProviderStateMixin {
  static const _countdown = Duration(seconds: 15);
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _countdown)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          Navigator.of(context).pop(false);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _neighborhood(String address) {
    final parts = address.split(' - ');
    if (parts.length >= 2) return parts[1].split(',').first.trim();
    return address;
  }

  Future<void> _accept() async {
    _controller.stop();
    await ref.read(applyControllerProvider.notifier).apply(widget.shift.id);
    final error = ref.read(applyControllerProvider).error;
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().contains('409')
                ? 'Esse plantão não está mais disponível.'
                : 'Erro ao aceitar plantão. Tente novamente.',
          ),
          backgroundColor: AppTheme.error,
        ),
      );
      _controller.forward();
      return;
    }

    widget.onAccept?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plantão aceito! Veja em Meus Plantões.'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final shift = widget.shift;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final applyState = ref.watch(applyControllerProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Aceitar plantão?',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final remaining =
                        (_countdown.inSeconds * (1 - _controller.value))
                            .ceil();
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: CircularProgressIndicator(
                            value: 1 - _controller.value,
                            strokeWidth: 5,
                            backgroundColor: AppColors.border,
                            color: remaining <= 5
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                        Text(
                          '${remaining}s',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => LinearProgressIndicator(
                value: 1 - _controller.value,
                minHeight: 6,
                borderRadius: BorderRadius.circular(99),
                backgroundColor: AppColors.border,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            _DialogInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Data e hora',
              value:
                  DateFormat("dd/MM/yyyy 'às' HH:mm").format(shift.dateStart),
            ),
            _DialogInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Bairro',
              value: _neighborhood(shift.address),
            ),
            _DialogInfoRow(
              icon: Icons.timelapse_rounded,
              label: 'Duração',
              value: '${shift.duration.inHours}h',
            ),
            _DialogInfoRow(
              icon: Icons.payments_outlined,
              label: 'Valor total',
              value: currency.format(shift.value),
            ),
            if (shift.isUrgent)
              _DialogInfoRow(
                icon: Icons.bolt_rounded,
                label: 'Urgência',
                value:
                    'Plantão urgente com multiplicador x${shift.urgencyMultiplier.toStringAsFixed(2)} já aplicado ao valor.',
              ),
            if (shift.description != null && shift.description!.isNotEmpty)
              _DialogInfoRow(
                icon: Icons.notes_rounded,
                label: 'Detalhes',
                value: shift.description!,
              ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: applyState.isLoading
                        ? null
                        : () {
                            widget.onDecline?.call();
                            Navigator.of(context).pop(false);
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Recusar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: applyState.isLoading ? null : _accept,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: applyState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Aceitar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DialogInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// CARD: MEU PLANT�fO
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class _MyShiftListItem extends StatelessWidget {
  final Shift shift;

  const _MyShiftListItem({required this.shift});

  String get _patientName => shift.patient?.name ?? shift.hospitalName;

  void _showPatientDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PatientDetailsDialog(shift: shift),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.vittaSageLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(shift.dateStart),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  DateFormat('EEE', 'pt_BR')
                      .format(shift.dateStart)
                      .toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () => _showPatientDetails(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text(
                    _patientName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      '${DateFormat('HH:mm').format(shift.dateStart)} · ${shift.duration.inHours}h',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(shift.value),
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/shift-detail', extra: shift),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Detalhes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PatientDetailsDialog extends StatelessWidget {
  final Shift shift;

  const PatientDetailsDialog({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    final patient = shift.patient;
    final patientName = patient?.name ?? shift.hospitalName;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.84,
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
            const _SheetHandle(),
            const SizedBox(height: 22),
            Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.vittaSageLight,
                  child: Text(
                    patientName[0].toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 24,
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
                        patientName,
                        style: GoogleFonts.inter(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (patient?.age != null)
                        Text(
                          '${patient!.age} anos',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            if (patient?.rating != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      patient!.rating!.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'avaliação de cuidadores anteriores',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
            if (patient?.age != null)
              _DialogInfoRow(
                icon: Icons.cake_outlined,
                label: 'Idade',
                value: '${patient!.age} anos',
              ),
            _DialogInfoRow(
              icon: Icons.medical_services_outlined,
              label: 'Descrição do atendimento',
              value: shift.description?.isNotEmpty == true
                  ? shift.description!
                  : 'Cuidados gerais durante o plantão.',
            ),
            _DialogInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Endereço',
              value: shift.address,
            ),
            if (patient?.medicalHistory != null) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                initiallyExpanded: true,
                title: Text(
                  'Histórico Médico',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      patient!.medicalHistory!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => HealthAssessmentSheet(shift: shift),
                      );
                    },
                    icon: const Icon(Icons.health_and_safety_rounded,
                        size: 18),
                    label: const Text('Avaliação'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => MedicationsSheet(shift: shift),
                      );
                    },
                    icon: const Icon(Icons.medication_rounded, size: 18),
                    label: const Text('Medicamentos'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// POPUP: DETALHES DA SOLICITA�?�fO IMEDIATA (on-demand)
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class OnDemandDetailsDialog extends StatelessWidget {
  final OnDemandRequest request;

  const OnDemandDetailsDialog({super.key, required this.request});

  String _statusLabel() => switch (request.status) {
        'in_progress' => 'Em andamento',
        'matched' => 'Atribuído',
        'searching' => 'Buscando profissional',
        _ => 'Aceito',
      };

  Color _statusColor() => request.status == 'in_progress'
      ? AppColors.success
      : AppColors.primary;

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'agora mesmo';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return 'há ${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final patientName = request.patientName;
    final initial = patientName.isNotEmpty ? patientName[0].toUpperCase() : '?';
    final statusColor = _statusColor();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.84,
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
            const _SheetHandle(),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'IMEDIATO',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _timeAgo(request.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.vittaSageLight,
                  child: Text(
                    initial,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    patientName,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _DialogInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Endereço',
              value: request.address,
            ),
            if (request.distanceKm != null)
              _DialogInfoRow(
                icon: Icons.near_me_outlined,
                label: 'Distância',
                value: '${request.distanceKm!.toStringAsFixed(1)} km',
              ),
            if (request.notes != null && request.notes!.isNotEmpty)
              _DialogInfoRow(
                icon: Icons.notes_rounded,
                label: 'Observações',
                value: request.notes!,
              ),
            if (request.matchedAt != null)
              _DialogInfoRow(
                icon: Icons.event_available_outlined,
                label: 'Aceita',
                value: _timeAgo(request.matchedAt!),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/conversations');
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 18),
                    label: const Text('Mensagens'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/professional-request-detail',
                          extra: request);
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('Ver tudo'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// SHEET: AVALIA�?�fO DE SA�sDE (anamnese, sinais vitais, exames)
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class HealthAssessmentSheet extends StatelessWidget {
  final Shift shift;
  const HealthAssessmentSheet({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    final patient = shift.patient;
    final history = patient?.medicalHistory ??
        'Sem registros clínicos detalhados disponíveis para esta assistência.';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
            const _SheetHandle(),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    color: AppColors.success,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avaliação de Saúde',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        patient?.name ?? shift.hospitalName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SheetSection(
              title: 'Anamnese',
              icon: Icons.assignment_outlined,
              child: Text(
                history,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const _SheetSection(
              title: 'Sinais Vitais',
              icon: Icons.monitor_heart_outlined,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _VitalChip(label: 'PA', value: '—'),
                  _VitalChip(label: 'FC', value: '—'),
                  _VitalChip(label: 'FR', value: '—'),
                  _VitalChip(label: 'T°', value: '—'),
                  _VitalChip(label: 'SatO₂', value: '—'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SheetSection(
              title: 'Atividades do Assistido',
              icon: Icons.directions_walk_rounded,
              child: Text(
                'Caminhada, banho, alimentação e demais atividades a serem registradas no plantão.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Entendi'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalChip extends StatelessWidget {
  final String label;
  final String value;
  const _VitalChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.vittaSageLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// SHEET: MEDICAMENTOS
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class MedicationsSheet extends StatelessWidget {
  final Shift shift;
  const MedicationsSheet({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    const meds = [
      _Med('Omeprazol', '20 mg', '1-0-0'),
      _Med('Hidroclorotiazida', '25 mg', '1-0-0'),
      _Med('Cloridrato de Sertralina', '50 mg', '1-0-0'),
      _Med('Glifage', '500 mg', '0-1-0'),
      _Med('Ácido Acetilsalicílico', '100 mg', '0-1-0'),
      _Med('Sinvastatina', '40 mg', '0-0-1'),
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
            const _SheetHandle(),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.medication_rounded,
                      color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medicamentos',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${meds.length} medicações ativas',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 18, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Posologia: manhã - tarde - noite',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...meds.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MedRow(med: m),
                )),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Fechar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Med {
  final String name;
  final String dosage;
  final String schedule;
  const _Med(this.name, this.dosage, this.schedule);
}

class _MedRow extends StatelessWidget {
  final _Med med;
  const _MedRow({required this.med});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medication_liquid_rounded,
                color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  med.dosage,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              med.schedule,
              style: GoogleFonts.robotoMono(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// SHEET: RELATO DE CUIDADOS
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

enum _ShiftReportTab {
  medicacao,
  sinaisVitais,
  sono,
  alimentacao,
  atividadeFisica,
  horarios,
  relatoFinal,
}

extension _ShiftReportTabData on _ShiftReportTab {
  String get label => switch (this) {
        _ShiftReportTab.medicacao => 'Medicação',
        _ShiftReportTab.sinaisVitais => 'Sinais vitais',
        _ShiftReportTab.sono => 'Sono',
        _ShiftReportTab.alimentacao => 'Alimentação',
        _ShiftReportTab.atividadeFisica => 'Atividade física',
        _ShiftReportTab.horarios => 'Horários',
        _ShiftReportTab.relatoFinal => 'Relato',
      };

  IconData get icon => switch (this) {
        _ShiftReportTab.medicacao => Icons.medication_rounded,
        _ShiftReportTab.sinaisVitais => Icons.monitor_heart_rounded,
        _ShiftReportTab.sono => Icons.bedtime_rounded,
        _ShiftReportTab.alimentacao => Icons.restaurant_rounded,
        _ShiftReportTab.atividadeFisica => Icons.directions_walk_rounded,
        _ShiftReportTab.horarios => Icons.schedule_rounded,
        _ShiftReportTab.relatoFinal => Icons.notes_rounded,
      };
}

class RelatoCuidadosSheet extends StatelessWidget {
  final Shift shift;

  const RelatoCuidadosSheet({super.key, required this.shift});

  @override
  Widget build(BuildContext context) => ShiftReportSheet(shift: shift);
}

class ShiftReportSheet extends StatefulWidget {
  final Shift shift;

  const ShiftReportSheet({super.key, required this.shift});

  @override
  State<ShiftReportSheet> createState() => _ShiftReportSheetState();
}

class _ShiftReportSheetState extends State<ShiftReportSheet> {
  _ShiftReportTab _activeTab = _ShiftReportTab.medicacao;

  final _medicacaoController = TextEditingController();
  final _pressaoController = TextEditingController();
  final _frequenciaCardiacaController = TextEditingController();
  final _temperaturaController = TextEditingController();
  final _saturacaoController = TextEditingController();
  final _sonoHorasController = TextEditingController();
  final _sonoObsController = TextEditingController();
  final _alimentacaoController = TextEditingController();
  final _atividadeController = TextEditingController();
  final _atividadeMinutosController = TextEditingController();
  final _horariosController = TextEditingController();
  final _relatoFinalController = TextEditingController();

  String? _qualidadeSono;

  @override
  void dispose() {
    _medicacaoController.dispose();
    _pressaoController.dispose();
    _frequenciaCardiacaController.dispose();
    _temperaturaController.dispose();
    _saturacaoController.dispose();
    _sonoHorasController.dispose();
    _sonoObsController.dispose();
    _alimentacaoController.dispose();
    _atividadeController.dispose();
    _atividadeMinutosController.dispose();
    _horariosController.dispose();
    _relatoFinalController.dispose();
    super.dispose();
  }

  bool _hasText(TextEditingController controller) =>
      controller.text.trim().isNotEmpty;

  int get _filledSections {
    var filled = 0;
    if (_hasText(_medicacaoController)) filled++;
    if (_hasText(_pressaoController) ||
        _hasText(_frequenciaCardiacaController) ||
        _hasText(_temperaturaController) ||
        _hasText(_saturacaoController)) {
      filled++;
    }
    if (_hasText(_sonoHorasController) ||
        _hasText(_sonoObsController) ||
        _qualidadeSono != null) {
      filled++;
    }
    if (_hasText(_alimentacaoController)) filled++;
    if (_hasText(_atividadeController) || _hasText(_atividadeMinutosController)) {
      filled++;
    }
    if (_hasText(_horariosController)) filled++;
    if (_hasText(_relatoFinalController)) filled++;
    return filled;
  }

  void _touch() => setState(() {});

  void _saveReport() {
    if (!_hasText(_relatoFinalController)) {
      setState(() => _activeTab = _ShiftReportTab.relatoFinal);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o relato final para concluir o relatório.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Relatório do plantão da família de ${widget.shift.patient?.name ?? widget.shift.hospitalName} salvo com sucesso (mock).',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.shift.patient?.name ?? widget.shift.hospitalName;
    final subtitle =
        "${DateFormat("dd/MM 'das' HH:mm", 'pt_BR').format(widget.shift.dateStart)} - ${DateFormat('HH:mm').format(widget.shift.dateEnd)}";

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.93,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.post_add_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Relatório pós-plantão',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          patientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$_filledSections/7 seções',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _ShiftReportTab.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final tab = _ShiftReportTab.values[i];
                    return _ReportTabChip(
                      label: tab.label,
                      icon: tab.icon,
                      selected: _activeTab == tab,
                      onTap: () => setState(() => _activeTab = tab),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: SingleChildScrollView(
                    key: ValueKey(_activeTab),
                    physics: const BouncingScrollPhysics(),
                    child: _buildTabBody(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saveReport,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Salvar relatório'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBody() {
    return switch (_activeTab) {
      _ShiftReportTab.medicacao => _SheetSection(
          title: 'Medicação administrada',
          icon: Icons.medication_rounded,
          child: _textField(
            controller: _medicacaoController,
            hint: 'Ex.: Losartana 50mg às 08:00. Sem efeitos adversos.',
            lines: 5,
          ),
        ),
      _ShiftReportTab.sinaisVitais => _SheetSection(
          title: 'Sinais vitais',
          icon: Icons.monitor_heart_rounded,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      controller: _pressaoController,
                      label: 'Pressão',
                      hint: '12x8',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _textField(
                      controller: _frequenciaCardiacaController,
                      label: 'FC',
                      hint: '72 bpm',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      controller: _temperaturaController,
                      label: 'Temperatura',
                      hint: '36.4 C',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _textField(
                      controller: _saturacaoController,
                      label: 'Saturação',
                      hint: '97%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      _ShiftReportTab.sono => _SheetSection(
          title: 'Sono',
          icon: Icons.bedtime_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textField(
                controller: _sonoHorasController,
                label: 'Horas de sono',
                hint: 'Ex.: 6h30',
              ),
              const SizedBox(height: 10),
              Text(
                'Qualidade do sono',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Boa', 'Regular', 'Ruim'].map((item) {
                  return _FilterChip(
                    label: item,
                    isSelected: _qualidadeSono == item,
                    onTap: () => setState(() => _qualidadeSono = item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              _textField(
                controller: _sonoObsController,
                hint: 'Observações sobre despertares, inquietação, cochilos...',
                lines: 4,
              ),
            ],
          ),
        ),
      _ShiftReportTab.alimentacao => _SheetSection(
          title: 'Alimentação e hidratação',
          icon: Icons.restaurant_rounded,
          child: _textField(
            controller: _alimentacaoController,
            hint:
                'Ex.: Café completo, almoço parcial, 1.2L de água no período.',
            lines: 5,
          ),
        ),
      _ShiftReportTab.atividadeFisica => _SheetSection(
          title: 'Atividade física e mobilização',
          icon: Icons.directions_walk_rounded,
          child: Column(
            children: [
              _textField(
                controller: _atividadeController,
                hint:
                    'Ex.: Caminhada assistida no corredor e alongamento leve.',
                lines: 4,
              ),
              const SizedBox(height: 10),
              _textField(
                controller: _atividadeMinutosController,
                label: 'Duração',
                hint: 'Ex.: 30 min',
              ),
            ],
          ),
        ),
      _ShiftReportTab.horarios => _SheetSection(
          title: 'Horários importantes',
          icon: Icons.schedule_rounded,
          child: _textField(
            controller: _horariosController,
            hint:
                'Registre os horários relevantes do plantão (medicação, refeições, banho, repouso).',
            lines: 5,
          ),
        ),
      _ShiftReportTab.relatoFinal => _SheetSection(
          title: 'Relato final para a família',
          icon: Icons.notes_rounded,
          child: _textField(
            controller: _relatoFinalController,
            hint:
                'Escreva um resumo claro e humanizado do plantão para a família.',
            lines: 7,
          ),
        ),
    };
  }

  Widget _textField({
    required TextEditingController controller,
    String? label,
    required String hint,
    int lines = 1,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => _touch(),
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _ReportTabChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ReportTabChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ReportarOcorrenciaSheet extends StatefulWidget {
  const ReportarOcorrenciaSheet({super.key});

  @override
  State<ReportarOcorrenciaSheet> createState() =>
      _ReportarOcorrenciaSheetState();
}

class _ReportarOcorrenciaSheetState extends State<ReportarOcorrenciaSheet> {
  String? _category;
  final _description = TextEditingController();

  static const _categories = [
    'Saúde do paciente',
    'Logística',
    'Conduta',
    'Outros',
  ];

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reportar ocorrência',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Categoria',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final selected = _category == c;
                  return _FilterChip(
                    label: c,
                    isSelected: selected,
                    onTap: () => setState(() => _category = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Text(
                'Descrição',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _description,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Descreva a ocorrência...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  if (_category == null || _description.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Escolha uma categoria e descreva a ocorrência.'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Ocorrência enviada para a equipe Vitta. Obrigada!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Enviar ocorrência'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// SHEET: ADICIONAR LEMBRETE
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class AdicionarLembreteSheet extends StatefulWidget {
  const AdicionarLembreteSheet({super.key});

  @override
  State<AdicionarLembreteSheet> createState() => _AdicionarLembreteSheetState();
}

class _AdicionarLembreteSheetState extends State<AdicionarLembreteSheet> {
  final _title = TextEditingController();
  DateTime? _when;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _when ?? now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when ?? now),
    );
    if (time == null) return;
    setState(() {
      _when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_active_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Novo lembrete',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: 'Título do lembrete',
                  hintText: 'Ex.: Medicar paciente',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded,
                          color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _when == null
                              ? 'Quando?'
                              : DateFormat("dd/MM/yyyy 'às' HH:mm")
                                  .format(_when!),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _when == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  if (_title.text.trim().isEmpty || _when == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Preencha um título e escolha uma data/hora.'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lembrete criado!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Salvar lembrete'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// SHEET: PREVIEW DOS LEMBRETES (sino do header)
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class LembretesPreviewSheet extends StatelessWidget {
  const LembretesPreviewSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 18),
            Text(
              'Lembretes',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_off_outlined,
                      color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Não há lembretes pendentes.',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?
// SHARED WIDGETS
// �"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?�"?

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SheetSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String badge;
  final Color badgeColor;

  const _SectionHeader({
    required this.title,
    required this.badge,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppTheme.sage.withValues(alpha: 0.7)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

