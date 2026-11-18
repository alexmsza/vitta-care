import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/shift.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/shift_provider.dart';

class ShiftCard extends StatelessWidget {
  final Shift shift;
  final bool showApplyButton;

  const ShiftCard({
    required this.shift,
    this.showApplyButton = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    shift.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.petrol,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'R\$ ${shift.value.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.sage,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: shift.address,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.schedule_outlined,
              text:
                  '${_formatDateTime(shift.dateStart)} · ${shift.duration.inHours}h',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatusChip(status: shift.status),
                const Spacer(),
                if (showApplyButton) _ApplyButton(shiftId: shift.id),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month às $hour:$minute';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.sage),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Chip(
      label: Text(
        _statusLabel(status),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
      side: BorderSide(color: color.withValues(alpha: 0.25)),
      backgroundColor: color.withValues(alpha: 0.12),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _statusColor(String status) => switch (status) {
        'open' => Colors.green,
        'assigned' => Colors.blue,
        'in_progress' => AppColors.warning,
        'completed' => Colors.grey,
        _ => Colors.grey,
      };

  String _statusLabel(String status) => switch (status) {
        'open' => 'Disponível',
        'assigned' => 'Aceito',
        'in_progress' => 'Em andamento',
        'completed' => 'Concluído',
        _ => status,
      };
}

class _ApplyButton extends ConsumerWidget {
  final int shiftId;

  const _ApplyButton({required this.shiftId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applyState = ref.watch(applyControllerProvider);
    final isLoading = applyState.isLoading;

    return FilledButton(
      onPressed: isLoading
          ? null
          : () async {
              await ref.read(applyControllerProvider.notifier).apply(shiftId);
              if (!context.mounted) return;

              final result = ref.read(applyControllerProvider);
              if (result.hasError) {
                final error =
                    result.error.toString().replaceFirst('Exception: ', '');
                final message = error.contains('não está disponível')
                    ? 'Esse plantão não está mais disponível.'
                    : 'Erro ao aceitar plantão. Tente novamente.';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppTheme.error,
                  ),
                );
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Plantão aceito!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
      child: isLoading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('Aceitar Plantão'),
    );
  }
}
