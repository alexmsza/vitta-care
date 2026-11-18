import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';

class ProfessionalAvailabilityCalendar extends StatefulWidget {
  final int? professionalId;
  final String professionalName;

  const ProfessionalAvailabilityCalendar({
    super.key,
    required this.professionalId,
    required this.professionalName,
  });

  @override
  State<ProfessionalAvailabilityCalendar> createState() =>
      _ProfessionalAvailabilityCalendarState();
}

class _ProfessionalAvailabilityCalendarState
    extends State<ProfessionalAvailabilityCalendar> {
  late DateTime _viewMonth;
  DateTime? _selectedDay;
  late final Map<DateTime, List<_Slot>> _availability;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
    _availability = _buildMockAvailability(widget.professionalId ?? 0);
    _selectedDay = _firstAvailableFrom(now);
  }

  DateTime? _firstAvailableFrom(DateTime from) {
    final keys = _availability.keys.toList()..sort();
    for (final d in keys) {
      if (!d.isBefore(DateTime(from.year, from.month, from.day))) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(name: widget.professionalName),
          const SizedBox(height: 16),
          _MonthBar(
            month: _viewMonth,
            onPrev: _canGoPrev ? () => _shiftMonth(-1) : null,
            onNext: () => _shiftMonth(1),
          ),
          const SizedBox(height: 12),
          _WeekdayLabels(),
          const SizedBox(height: 4),
          _MonthGrid(
            month: _viewMonth,
            selected: _selectedDay,
            availability: _availability,
            onSelect: (d) => setState(() => _selectedDay = d),
          ),
          const SizedBox(height: 18),
          _Divider(),
          const SizedBox(height: 14),
          _SlotsSection(
            day: _selectedDay,
            slots: _selectedDay == null
                ? const []
                : (_availability[_dateKey(_selectedDay!)] ?? const []),
          ),
          const SizedBox(height: 10),
          _Legend(),
        ],
      ),
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

// ─── Internal widgets ─────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String name;
  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.vittaSageLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.event_available_outlined,
              color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Disponibilidade',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Dias e horários em que $name pode atender',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
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
      color: enabled ? AppColors.background : AppColors.background.withValues(alpha: 0.5),
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
  final DateTime? selected;
  final Map<DateTime, List<_Slot>> availability;
  final ValueChanged<DateTime> onSelect;

  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.availability,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = firstDay.weekday % 7; // Sunday=0
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
              final hasAvail =
                  !isPast && (availability[key]?.isNotEmpty ?? false);
              final isSelected = selected != null && _dateKey(selected!) == key;
              final isToday = key == today;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: _DayCell(
                    day: dayNum,
                    isPast: isPast,
                    hasAvailability: hasAvail,
                    isSelected: isSelected,
                    isToday: isToday,
                    onTap: hasAvail ? () => onSelect(date) : null,
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
  final bool hasAvailability;
  final bool isSelected;
  final bool isToday;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.isPast,
    required this.hasAvailability,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final BoxBorder? border;

    if (isSelected) {
      bg = AppColors.primary;
      fg = Colors.white;
      border = null;
    } else if (hasAvailability) {
      bg = AppColors.vittaSageLight;
      fg = AppColors.primary;
      border = isToday
          ? Border.all(color: AppColors.primary, width: 1.4)
          : null;
    } else {
      bg = Colors.transparent;
      fg = isPast ? AppColors.border : AppColors.textSecondary;
      border = isToday
          ? Border.all(color: AppColors.border, width: 1)
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
            child: Text(
              '$day',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight:
                    isSelected || hasAvailability ? FontWeight.bold : FontWeight.w500,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.border,
    );
  }
}

class _SlotsSection extends StatelessWidget {
  final DateTime? day;
  final List<_Slot> slots;

  const _SlotsSection({required this.day, required this.slots});

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return const _EmptyHint(
        text: 'Selecione um dia para ver os horários disponíveis.',
      );
    }
    if (slots.isEmpty) {
      return const _EmptyHint(
        text: 'Sem horários disponíveis neste dia.',
      );
    }
    final dayLabel = toBeginningOfSentenceCase(
      DateFormat("EEEE, dd 'de' MMM", 'pt_BR').format(day!),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horários em $dayLabel',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((s) => _SlotChip(slot: s)).toList(),
        ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  final _Slot slot;
  const _SlotChip({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(slot.icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            '${slot.label} · ${slot.range}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
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
        _LegendDot(color: AppColors.primary, label: 'Selecionado', filled: true),
        SizedBox(width: 12),
        _LegendDot(color: AppColors.border, label: 'Indisponível'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool filled;

  const _LegendDot({required this.color, required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: filled ? color : color.withValues(alpha: 0.8),
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

// ─── Mock data ────────────────────────────────────────────────────

class _Slot {
  final String label;
  final String range;
  final IconData icon;

  const _Slot({required this.label, required this.range, required this.icon});
}

const _morning =
    _Slot(label: 'Manhã', range: '08:00–12:00', icon: Icons.wb_sunny_outlined);
const _afternoon =
    _Slot(label: 'Tarde', range: '14:00–18:00', icon: Icons.wb_cloudy_outlined);
const _evening = _Slot(
    label: 'Noite', range: '19:00–22:00', icon: Icons.nightlight_outlined);

DateTime _dateKey(DateTime d) => DateTime(d.year, d.month, d.day);

/// Deterministic mock schedule for the next 45 days, seeded by professionalId
/// so each caregiver gets a distinct pattern. Replace with API data when the
/// availability endpoint is exposed.
Map<DateTime, List<_Slot>> _buildMockAvailability(int professionalId) {
  final result = <DateTime, List<_Slot>>{};
  final today = _dateKey(DateTime.now());
  for (var i = 0; i < 45; i++) {
    final day = today.add(Duration(days: i));
    final seed = (professionalId * 7 + i * 3 + day.weekday) % 7;
    final slots = <_Slot>[];
    if (seed == 0) continue; // folga
    if (seed % 2 == 1) slots.add(_morning);
    if (seed % 3 != 0) slots.add(_afternoon);
    if (seed >= 4) slots.add(_evening);
    if (slots.isEmpty) slots.add(_afternoon);
    result[day] = slots;
  }
  return result;
}
