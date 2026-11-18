import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/conversation.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final user = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.vittaPetrol,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Mensagens',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(conversationsProvider),
          ),
        ],
      ),
      body: conversationsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                'Não foi possível carregar as mensagens.',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(conversationsProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (conversations) {
          if (conversations.isEmpty) return const _EmptyConversations();

          final open = conversations.where((c) => !c.isChatLocked).toList();
          final locked = conversations.where((c) => c.isChatLocked).toList();

          return ListView(
            children: [
              if (open.isNotEmpty) ...[
                const _SectionLabel(label: 'Conversas ativas'),
                ...open.map((c) => _ConversationTile(
                      conversation: c,
                      userRole: user?.role ?? 'family',
                    )),
              ],
              if (locked.isNotEmpty) ...[
                const _SectionLabel(label: 'Próximas visitas'),
                ...locked.map((c) => _LockedConversationTile(
                      conversation: c,
                      userRole: user?.role ?? 'family',
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              color: AppColors.vittaSageLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 52, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhuma conversa ainda',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'As conversas aparecem aqui quando uma visita agendada se aproximar.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// UNLOCKED CONVERSATION TILE
// ─────────────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String userRole;

  const _ConversationTile({
    required this.conversation,
    required this.userRole,
  });

  String get _otherName => userRole == 'professional'
      ? conversation.familyName
      : conversation.professionalName;

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    final timeStr = conversation.lastMessageAt != null
        ? _formatTime(conversation.lastMessageAt!)
        : '';

    return InkWell(
      onTap: () => context.push('/chat/${conversation.id}', extra: conversation),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Avatar with online dot
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.vittaSageLight,
                    child: Text(
                      _otherName.isNotEmpty ? _otherName[0].toUpperCase() : '?',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _otherName,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          timeStr,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: hasUnread
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    if (conversation.patientName != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        conversation.patientName!,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage ?? 'Nenhuma mensagem ainda.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: hasUnread
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (conversation.visitDate != null) ...[
                      const SizedBox(height: 6),
                      _VisitBadge(visitDate: conversation.visitDate!),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24 && now.day == dt.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'ontem';
    return DateFormat('dd/MM').format(dt);
  }
}

// ─────────────────────────────────────────────────────────────────
// LOCKED CONVERSATION TILE
// ─────────────────────────────────────────────────────────────────

class _LockedConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String userRole;

  const _LockedConversationTile({
    required this.conversation,
    required this.userRole,
  });

  String get _otherName => userRole == 'professional'
      ? conversation.familyName
      : conversation.professionalName;

  @override
  Widget build(BuildContext context) {
    final timeUntil = conversation.timeUntilUnlock;
    final unlockLabel = timeUntil != null
        ? _formatUntilUnlock(timeUntil)
        : 'em breve';

    return InkWell(
      onTap: () => _showLockedDialog(context, unlockLabel),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.background,
                    child: Text(
                      _otherName.isNotEmpty ? _otherName[0].toUpperCase() : '?',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Icon(Icons.lock_rounded,
                          size: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _otherName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (conversation.patientName != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        conversation.patientName!,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.lock_clock_rounded,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 5),
                        Text(
                          'Chat disponível 24h antes da visita',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    if (conversation.visitDate != null) ...[
                      const SizedBox(height: 6),
                      _VisitBadge(visitDate: conversation.visitDate!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context, String unlockLabel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.vittaSageLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Chat bloqueado',
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Text(
          'O chat com $_otherName será liberado 24 horas antes da visita.\n\nIsso garante que a conversa seja relevante e focada no atendimento.',
          style: GoogleFonts.inter(fontSize: 14, height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  String _formatUntilUnlock(Duration d) {
    if (d.inDays >= 2) return '${d.inDays} dias';
    if (d.inHours >= 2) return '${d.inHours}h';
    return 'algumas horas';
  }
}

// ─────────────────────────────────────────────────────────────────
// VISIT BADGE
// ─────────────────────────────────────────────────────────────────

class _VisitBadge extends StatelessWidget {
  final DateTime visitDate;
  const _VisitBadge({required this.visitDate});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = visitDate.difference(now);
    String label;
    Color color;

    if (diff.isNegative) {
      label = 'Em andamento';
      color = AppColors.warning;
    } else if (diff.inHours < 2) {
      label = 'Em ${diff.inMinutes}min';
      color = AppColors.error;
    } else if (diff.inHours < 24) {
      label = 'Hoje às ${DateFormat('HH:mm').format(visitDate)}';
      color = AppColors.success;
    } else {
      label = DateFormat("dd/MM 'às' HH:mm").format(visitDate);
      color = AppColors.textSecondary;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_rounded, size: 11, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 11, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
