import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/chat_message.dart';
import '../../../../core/models/conversation.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/chat_provider.dart';

part 'chat_provider.g.dart';

@riverpod
Future<List<Conversation>> conversations(Ref ref) async {
  final token = ref.watch(authStateProvider)?.token ?? '';
  return ref.watch(chatRepositoryProvider).getConversations(token);
}

@riverpod
Future<List<ChatMessage>> messages(Ref ref, int conversationId) async {
  final token = ref.watch(authStateProvider)?.token ?? '';
  return ref
      .watch(chatRepositoryProvider)
      .getMessages(token, conversationId);
}

@riverpod
class SendMessageController extends _$SendMessageController {
  @override
  FutureOr<void> build() {}

  Future<void> send(int conversationId, String content) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateProvider);
      final token = user?.token ?? '';
      await ref.read(chatRepositoryProvider).sendMessage(
            token,
            conversationId,
            content,
            senderIdHint: user?.id ?? 0,
            senderNameHint: user?.name ?? 'Você',
            senderRoleHint: user?.role ?? 'family',
          );
      ref.invalidate(messagesProvider(conversationId));
    });
  }
}
