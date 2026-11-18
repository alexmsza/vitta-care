import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/chat_repository.dart';

part 'chat_provider.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) => ChatRepository();
