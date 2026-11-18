import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/shift.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/shift_repository.dart';

part 'shift_provider.g.dart';

@riverpod
ShiftRepository shiftRepository(Ref ref) => ShiftRepository();

@riverpod
Future<List<Shift>> openShifts(Ref ref) async {
  final token = ref.watch(authStateProvider)?.token ?? '';
  return ref.watch(shiftRepositoryProvider).getOpenShifts(token);
}

@riverpod
Future<List<Shift>> myShifts(Ref ref) async {
  final token = ref.watch(authStateProvider)?.token ?? '';
  return ref.watch(shiftRepositoryProvider).getMyShifts(token);
}

@riverpod
class ApplyController extends _$ApplyController {
  @override
  FutureOr<void> build() {}

  Future<void> apply(int shiftId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final token = ref.read(authStateProvider)?.token ?? '';
      await ref.read(shiftRepositoryProvider).applyForShift(shiftId, token);
      ref.invalidate(openShiftsProvider);
      ref.invalidate(myShiftsProvider);
    });
  }
}

@riverpod
class CancelShiftController extends _$CancelShiftController {
  @override
  FutureOr<void> build() {}

  Future<void> cancel(int shiftId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final token = ref.read(authStateProvider)?.token ?? '';
      await ref.read(shiftRepositoryProvider).cancelShift(shiftId, token);
      ref.invalidate(myShiftsProvider);
    });
  }
}
