import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/on_demand_request.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/service_request_repository.dart';

part 'on_demand_provider.g.dart';

@riverpod
OnDemandRequestRepository onDemandRepository(Ref ref) =>
    OnDemandRequestRepository();

/// Solicitações ativas da família autenticada.
@riverpod
Future<List<OnDemandRequest>> myOnDemandRequests(Ref ref) async {
  final token = ref.watch(authStateProvider)?.token ?? '';
  return ref.watch(onDemandRepositoryProvider).getMyRequests(token);
}

/// Controller assíncrono para criar e cancelar solicitações (Família).
@riverpod
class OnDemandController extends _$OnDemandController {
  @override
  FutureOr<void> build() {}

  Future<void> create({
    required String patientName,
    required String address,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final token = ref.read(authStateProvider)?.token ?? '';
      await ref.read(onDemandRepositoryProvider).createRequest(
            token,
            patientName: patientName,
            address: address,
            notes: notes,
          );
      ref.invalidate(myOnDemandRequestsProvider);
    });
  }

  Future<void> cancel(int requestId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final token = ref.read(authStateProvider)?.token ?? '';
      await ref
          .read(onDemandRepositoryProvider)
          .cancelRequest(token, requestId);
      ref.invalidate(myOnDemandRequestsProvider);
    });
  }

  Future<OnDemandRequest?> requestAnotherProfessional(
    OnDemandRequest request,
  ) async {
    state = const AsyncValue.loading();
    OnDemandRequest? newRequest;
    state = await AsyncValue.guard(() async {
      final token = ref.read(authStateProvider)?.token ?? '';
      newRequest = await ref
          .read(onDemandRepositoryProvider)
          .requestAnotherProfessional(token, request);
      ref.invalidate(myOnDemandRequestsProvider);
    });
    return newRequest;
  }
}
