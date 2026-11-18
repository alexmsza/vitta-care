import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/availability_provider.dart';

class ProfessionalUnavailabilityCalendar extends ConsumerStatefulWidget {
  const ProfessionalUnavailabilityCalendar({super.key});

  @override
  ConsumerState<ProfessionalUnavailabilityCalendar> createState() =>
      _ProfessionalUnavailabilityCalendarState();
}

class _ProfessionalUnavailabilityCalendarState
    extends ConsumerState<ProfessionalUnavailabilityCalendar> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final offDays = ref.watch(unavailableDaysProvider);
    final notifier = ref.read(unavailableDaysProvider.notifier);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _IntroCard(blockedCount: offDays.length),
        const SizedBox(height: 16),
        _CalendarCard(
          month: _viewMonth,
          offDays: offDays,
          onPrev: _canGoPrev ? () => _shiftMonth(-1) : null,
          onNext: () => _shiftMonth(1),
          onTapDay: notifier.toggle,
        ),
        const SizedBox(height: 16),
        _BulkToggles(
          month: _viewMonth,
          offDays: offDays,
          onSetWeek: (days, off) => notifier.setMany(days, off: off),
          onSetMonth: (days, off) => notifier.setMany(days, off: off),
        ),
      ],
    );
  }

  bool get _canGoPrev {
    final now = DateTime.now();
    return _viewMonth.isAfter(DateTime(now.year, now.month));
  }

  void _shiftMonth(int delta) {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + delta);
    });
  }
}

// ─── Intro card ───────────────────────────────────────────────────

class _IntroCard extends StatelessWidget {
  final int blockedCount;
  const _IntroCard({required this.blockedCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.vittaSage],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_busy_outlined,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minha disponibilidade',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  blockedCount == 0
                      ? 'Toque nos dias que você não poderá atender.'
                      : '$blockedCount ${blockedCount == 1 ? 'dia bloqueado' : 'dias bloqueados'} — as famílias não verão você nestes dias.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.3,
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

// ─── Calendar card ────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  final DateTime month;
  final Set<DateTime> offDays;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final ValueChanged<DateTime> onTapDay;

  const _CalendarCard({
    required this.month,
    required this.offDays,
    required this.onPrev,
    required this.onNext,
    required this.onTapDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MonthBar(month: month, onPrev: onPrev, onNext: onNext),
          const SizedBox(height: 12),
          _WeekdayLabels(),
          const SizedBox(height: 4),
          _MonthGrid(
            month: month,
            offDays: offDays,
            onTapDay: onTapDay,
          ),
          const SizedBox(height: 14),
          _Legend(),
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  final DateTime month;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _MonthBar({required this.month, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final label = toBeginningOfSentenceCase(
      DateFormat("MMMM 'de' yyyy", 'pt_BR').format(month),
    );
    return Row(
      children: [
        _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
        Expanded(
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? AppColors.background
          : AppColors.background.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 22,
            color: enabled ? AppColors.primary : AppColors.border,
          ),
        ),
      ),
    );
  }
}

class _WeekdayLabels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const labels = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    return Row(
      children: labels
          .map(
            (l) => Expanded(
              child: Center(
                child: Text(
                  l,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final Set<DateTime> offDays;
  final ValueChanged<DateTime> onTapDay;

  const _MonthGrid({
    required this.month,
    required this.offDays,
    required this.onTapDay,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = firstDay.weekday % 7;
    final totalCells = ((leading + daysInMonth) / 7).ceil() * 7;
    final today = _dateKey(DateTime.now());

    return Column(
      children: List.generate((totalCells / 7).ceil(), (weekIdx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: List.generate(7, (dow) {
              final cell = weekIdx * 7 + dow;
              final dayNum = cell - leading + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 40));
              }
              final date = DateTime(month.year, month.month, dayNum);
              final key = _dateKey(date);
              final isPast = key.isBefore(today);
              final isOff = offDays.contains(key);
              final isToday = key == today;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: _DayCell(
                    day: dayNum,
                    isPast: isPast,
                    isOff: isOff,
                    isToday: isToday,
                    onTap: isPast ? null : () => onTapDay(date),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isPast;
  final bool isOff;
  final bool isToday;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.isPast,
    required this.isOff,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final BoxBorder? border;

    if (isOff) {
      bg = AppColors.error;
      fg = Colors.white;
      border = null;
    } else if (isPast) {
      bg = Colors.transparent;
      fg = AppColors.border;
      border = null;
    } else {
      bg = AppColors.vittaSageLight;
      fg = AppColors.primary;
      border = isToday
          ? Border.all(color: AppColors.primary, width: 1.4)
          : null;
    }

    return SizedBox(
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: border,
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight:
                        (isOff || !isPast) ? FontWeight.bold : FontWeight.w500,
                    color: fg,
                  ),
                ),
                if (isOff)
                  const Positioned(
                    bottom: 4,
                    child: Icon(Icons.close_rounded,
                        size: 10, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendDot(color: AppColors.vittaSageLight, label: 'Disponível'),
        SizedBox(width: 12),
        _LegendDot(color: AppColors.error, label: 'Bloqueado'),
        SizedBox(width: 12),
        _LegendDot(color: AppColors.border, label: 'Passado'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─── Bulk toggles ─────────────────────────────────────────────────

class _BulkToggles extends StatelessWidget {
  final DateTime month;
  final Set<DateTime> offDays;
  final void Function(Iterable<DateTime> days, bool off) onSetWeek;
  final void Function(Iterable<DateTime> days, bool off) onSetMonth;

  const _BulkToggles({
    required this.month,
    required this.offDays,
    required this.onSetWeek,
    required this.onSetMonth,
  });

  List<DateTime> get _weekDays {
    final today = _dateKey(DateTime.now());
    final weekday = today.weekday % 7; // Sunday=0
    final start = today.subtract(Duration(days: weekday));
    return List.generate(7, (i) => start.add(Duration(days: i)))
        .where((d) => !d.isBefore(today))
        .toList();
  }

  List<DateTime> get _monthDays {
    final today = _dateKey(DateTime.now());
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final start = first.isBefore(today) ? today : first;
    final out = <DateTime>[];
    for (var d = start; !d.isAfter(last); d = d.add(const Duration(days: 1))) {
      out.add(_dateKey(d));
    }
    return out;
  }

  bool _allOff(Iterable<DateTime> days) {
    if (days.isEmpty) return false;
    return days.every((d) => offDays.contains(_dateKey(d)));
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _weekDays;
    final monthDays = _monthDays;
    final weekAllOff = _allOff(weekDays);
    final monthAllOff = _allOff(monthDays);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            'Bloqueio rápido',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          _BulkRow(
            title: 'Bloquear semana atual',
            subtitle: weekDays.isEmpty
                ? 'Nenhum dia restante nesta semana.'
                : '${weekDays.length} ${weekDays.length == 1 ? 'dia' : 'dias'} de hoje até domingo',
            value: weekAllOff,
            enabled: weekDays.isNotEmpty,
            onChanged: (v) => onSetWeek(weekDays, v),
          ),
          const Divider(height: 24, color: AppColors.border),
          _BulkRow(
            title: 'Bloquear mês inteiro',
            subtitle: monthDays.isEmpty
                ? 'Nenhum dia restante neste mês.'
                : '${monthDays.length} ${monthDays.length == 1 ? 'dia' : 'dias'} de ${_monthLabel(month)}',
            value: monthAllOff,
            enabled: monthDays.isNotEmpty,
            onChanged: (v) => onSetMonth(monthDays, v),
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime m) =>
      toBeginningOfSentenceCase(DateFormat('MMMM', 'pt_BR').format(m));
}

class _BulkRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _BulkRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? () => onChanged(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged:
                  enabled ? (v) => onChanged(v ?? false) : null,
              activeColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
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

DateTime _dateKey(DateTime d) => DateTime(d.year, d.month, d.day);
