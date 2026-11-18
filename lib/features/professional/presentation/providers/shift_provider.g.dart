// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shiftRepositoryHash() => r'43db0603e81f40f3caf04a06571f6d50610af7e0';

/// See also [shiftRepository].
@ProviderFor(shiftRepository)
final shiftRepositoryProvider = AutoDisposeProvider<ShiftRepository>.internal(
  shiftRepository,
  name: r'shiftRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shiftRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShiftRepositoryRef = AutoDisposeProviderRef<ShiftRepository>;
String _$openShiftsHash() => r'e7375f2d00031341ff6947da9ecbaa55f8161cbe';

/// See also [openShifts].
@ProviderFor(openShifts)
final openShiftsProvider = AutoDisposeFutureProvider<List<Shift>>.internal(
  openShifts,
  name: r'openShiftsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$openShiftsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OpenShiftsRef = AutoDisposeFutureProviderRef<List<Shift>>;
String _$myShiftsHash() => r'498c80236439a4be6bcdd0ce28100b70fd641821';

/// See also [myShifts].
@ProviderFor(myShifts)
final myShiftsProvider = AutoDisposeFutureProvider<List<Shift>>.internal(
  myShifts,
  name: r'myShiftsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myShiftsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyShiftsRef = AutoDisposeFutureProviderRef<List<Shift>>;
String _$applyControllerHash() => r'128c6d213c6231aa622c471faa6626c64ebbae49';

/// See also [ApplyController].
@ProviderFor(ApplyController)
final applyControllerProvider =
    AutoDisposeAsyncNotifierProvider<ApplyController, void>.internal(
  ApplyController.new,
  name: r'applyControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$applyControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ApplyController = AutoDisposeAsyncNotifier<void>;
String _$cancelShiftControllerHash() =>
    r'8517efa3c41d074bd07b61e1017959ceac8c0890';

/// See also [CancelShiftController].
@ProviderFor(CancelShiftController)
final cancelShiftControllerProvider =
    AutoDisposeAsyncNotifierProvider<CancelShiftController, void>.internal(
  CancelShiftController.new,
  name: r'cancelShiftControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cancelShiftControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CancelShiftController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
