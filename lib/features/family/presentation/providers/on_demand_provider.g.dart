// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'on_demand_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onDemandRepositoryHash() =>
    r'e0249fc8ae11e363a17c6ce6dd5f0b0e8f843e58';

/// See also [onDemandRepository].
@ProviderFor(onDemandRepository)
final onDemandRepositoryProvider =
    AutoDisposeProvider<OnDemandRequestRepository>.internal(
  onDemandRepository,
  name: r'onDemandRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onDemandRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnDemandRepositoryRef
    = AutoDisposeProviderRef<OnDemandRequestRepository>;
String _$myOnDemandRequestsHash() =>
    r'7828b9126d4c19d5435c3209287baf01727f69fd';

/// Solicitações ativas da família autenticada.
///
/// Copied from [myOnDemandRequests].
@ProviderFor(myOnDemandRequests)
final myOnDemandRequestsProvider =
    AutoDisposeFutureProvider<List<OnDemandRequest>>.internal(
  myOnDemandRequests,
  name: r'myOnDemandRequestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myOnDemandRequestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyOnDemandRequestsRef
    = AutoDisposeFutureProviderRef<List<OnDemandRequest>>;
String _$onDemandControllerHash() =>
    r'68748930cb2568300dee5328e5cb950d5ccb9c11';

/// Controller assíncrono para criar e cancelar solicitações (Família).
///
/// Copied from [OnDemandController].
@ProviderFor(OnDemandController)
final onDemandControllerProvider =
    AutoDisposeAsyncNotifierProvider<OnDemandController, void>.internal(
  OnDemandController.new,
  name: r'onDemandControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onDemandControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OnDemandController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
