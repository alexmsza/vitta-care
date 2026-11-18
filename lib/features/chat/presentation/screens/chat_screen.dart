import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/chat_message.dart';
import '../../../../core/models/conversation.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;
  final Conversation? conversation;

  const ChatScreen({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _pollingTimer;
  bool _sending = false;
  bool _initialScrollDone = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) ref.invalidate(messagesProvider(widget.conversationId));
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _textController.text.trim();
    if (content.isEmpty || _sending) return;

    setState(() => _sending = true);
    _textController.clear();

    try {
      await ref
          .read(sendMessageControllerProvider.notifier)
          .send(widget.conversationId, content);
      _lastMessageCount = 0;
      _scrollToBottom();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar mensagem. Tente novamente.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _otherName() {
    final user = ref.read(authStateProvider);
    final conv = widget.conversation;
    if (conv == null) return 'Chat #${widget.conversationId}';
    return user?.role == 'professional'
        ? conv.familyName
        : conv.professionalName;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final conv = widget.conversation;
    final otherName = _otherName();

    messagesAsync.whenData((msgs) {
      final isNew = msgs.length > _lastMessageCount;
      if (!_initialScrollDone || isNew) {
        _lastMessageCount = msgs.length;
        _initialScrollDone = true;
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD), // WhatsApp-style warm background
      appBar: _buildAppBar(context, otherName, conv),
      body: Column(
        children: [
          // Visit info banner
          if (conv != null && conv.visitDate != null)
            _VisitBanner(conversation: conv),

          // Messages
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.textSecondary, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'Não foi possível carregar as mensagens.',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) return _EmptyChat(otherName: otherName);

                final items = _buildChatItems(messages);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    if (item is _DateDivider) return _DateSeparator(label: item.label);
                    if (item is ChatMessage) {
                      final isOwn = item.senderId == user?.id;
                      return _MessageBubble(
                        message: item,
                        isOwn: isOwn,
                        showSenderName: !isOwn,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),

          // Input
          _MessageInput(
            controller: _textController,
            sending: _sending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String otherName, Conversation? conv) {
    return AppBar(
      backgroundColor: AppColors.vittaPetrol,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherName,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                if (conv?.patientName != null)
                  Text(
                    conv!.patientName!,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8)),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build a flat list mixing DateDivider and ChatMessage objects
  List<Object> _buildChatItems(List<ChatMessage> messages) {
    final items = <Object>[];
    DateTime? lastDate;
    for (final msg in messages) {
      final msgDay =
          DateTime(msg.sentAt.year, msg.sentAt.month, msg.sentAt.day);
      if (lastDate == null || msgDay != lastDate) {
        items.add(_DateDivider(label: _dayLabel(msgDay)));
        lastDate = msgDay;
      }
      items.add(msg);
    }
    return items;
  }

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == today) return 'Hoje';
    if (day == yesterday) return 'Ontem';
    return DateFormat("d 'de' MMMM", 'pt_BR').format(day);
  }
}

class _DateDivider {
  final String label;
  const _DateDivider({required this.label});
}

// ─────────────────────────────────────────────────────────────────
// VISIT BANNER
// ─────────────────────────────────────────────────────────────────

class _VisitBanner extends StatelessWidget {
  final Conversation conversation;
  const _VisitBanner({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final diff = conversation.visitDate!.difference(DateTime.now());
    String label;
    Color bg;
    Color fg;

    if (diff.isNegative) {
      label = 'Visita em andamento';
      bg = AppColors.warning.withValues(alpha: 0.15);
      fg = AppColors.warning;
    } else if (diff.inHours < 2) {
      label = 'Visita em ${diff.inMinutes} minutos';
      bg = AppColors.error.withValues(alpha: 0.1);
      fg = AppColors.error;
    } else {
      label = DateFormat("Visita: dd/MM 'às' HH:mm").format(conversation.visitDate!);
      bg = AppColors.primary.withValues(alpha: 0.08);
      fg = AppColors.primary;
    }

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.event_available_rounded, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 12, color: fg, fontWeight: FontWeight.w600),
            ),
          ),
          if (conversation.patientName != null)
            Text(
              conversation.patientName!,
              style: GoogleFonts.inter(
                  fontSize: 11, color: fg.withValues(alpha: 0.8)),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DATE SEPARATOR
// ─────────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFD0C8C0))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D5CE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF5A5147),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFD0C8C0))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EMPTY CHAT
// ─────────────────────────────────────────────────────────────────

class _EmptyChat extends StatelessWidget {
  final String otherName;
  const _EmptyChat({required this.otherName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.waving_hand_rounded,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Olá! Inicie a conversa com $otherName.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14, color: const Color(0xFF5A5147)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// MESSAGE BUBBLE
// ─────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isOwn;
  final bool showSenderName;

  const _MessageBubble({
    required this.message,
    required this.isOwn,
    this.showSenderName = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(
        bottom: 3,
        left: isOwn ? 60 : 8,
        right: isOwn ? 8 : 60,
      ),
      child: Align(
        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            color: isOwn ? AppColors.vittaPetrol : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft:
                  Radius.circular(isOwn ? 18 : 4),
              bottomRight:
                  Radius.circular(isOwn ? 4 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isOwn
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSenderName && !isOwn) ...[
                Text(
                  message.senderName,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.vittaSage,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                message.content,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  color: isOwn ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isOwn
                          ? Colors.white.withValues(alpha: 0.65)
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (isOwn) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.read
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 13,
                      color: message.read
                          ? Colors.lightBlueAccent
                          : Colors.white.withValues(alpha: 0.65),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// MESSAGE INPUT
// ─────────────────────────────────────────────────────────────────

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _MessageInput({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0EBE3),
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                maxLines: 5,
                minLines: 1,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.inter(fontSize: 15),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Mensagem',
                  hintStyle: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: sending
                ? const SizedBox(
                    width: 48,
                    height: 48,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.primary),
                    ),
                  )
                : GestureDetector(
                    onTap: onSend,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.vittaPetrol,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
