import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/faq_item.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/faq_repository.dart';

part 'faq_provider.g.dart';

@riverpod
FaqRepository faqRepository(Ref ref) => FaqRepository();

@riverpod
Future<List<FaqItem>> faqItems(Ref ref) async {
  final token = ref.watch(authStateProvider)?.token ?? '';
  return ref.watch(faqRepositoryProvider).listFaq(token);
}
