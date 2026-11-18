import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/on_demand_request.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/on_demand_repository.dart';

part 'on_demand_provider.g.dart';

@riverpod
OnDemandRepository professionalOnDemandRepository(Ref ref) =>
    OnDemandRepository();

/// Pool de solicitacoes abertas proximas ao profissional.
@riverpod
Future<List<OnDemandRequest>> nearbyRequests(Ref ref) async {
  final token = ref.watch(authStateProvider)?.token ?? '';
  return ref.watch(professionalOnDemandRepositoryProvider).getNearbyRequests(token);
}

/// Solicitacoes aceitas por este profissional.
@riverpod
Future<List<OnDemandRequest>> acceptedServiceRequests(Ref ref) async {
  final token = ref.watch(authStateProvider)?.token ?? '';
  return ref
      .watch(professionalOnDemandRepositoryProvider)
      .getAcceptedRequests(token);
}

/// Controller para acoes do profissional em solicitacoes on-demand aceitas.
@riverpod
class ProfessionalOnDemandController extends _$ProfessionalOnDemandController {
  @override
  FutureOr<void> build() {}

  Future<void> cancelAccepted(int requestId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final token = ref.read(authStateProvider)?.token ?? '';
      await ref
          .read(professionalOnDemandRepositoryProvider)
          .cancelAcceptedRequest(token, requestId);

      ref.invalidate(nearbyRequestsProvider);
      ref.invalidate(acceptedServiceRequestsProvider);
    });
  }
}
