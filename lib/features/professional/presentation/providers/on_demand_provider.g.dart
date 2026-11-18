// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'on_demand_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$professionalOnDemandRepositoryHash() =>
    r'81d209a34fdcf1789e9962976c9a8ad5cb076e04';

/// See also [professionalOnDemandRepository].
@ProviderFor(professionalOnDemandRepository)
final professionalOnDemandRepositoryProvider =
    AutoDisposeProvider<OnDemandRepository>.internal(
  professionalOnDemandRepository,
  name: r'professionalOnDemandRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$professionalOnDemandRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfessionalOnDemandRepositoryRef
    = AutoDisposeProviderRef<OnDemandRepository>;
String _$nearbyRequestsHash() => r'30f78c2b4e3739d39b286d688f4e627f73646bb9';

/// Pool de solicitações abertas próximas ao profissional.
///
/// Copied from [nearbyRequests].
@ProviderFor(nearbyRequests)
final nearbyRequestsProvider =
    AutoDisposeFutureProvider<List<OnDemandRequest>>.internal(
  nearbyRequests,
  name: r'nearbyRequestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nearbyRequestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NearbyRequestsRef = AutoDisposeFutureProviderRef<List<OnDemandRequest>>;
String _$acceptedServiceRequestsHash() =>
    r'b3dde297d0147ec6de79bc41953cc6191f4dd3e0';

/// Solicitações urgentes aceitas por este profissional.
///
/// Copied from [acceptedServiceRequests].
@ProviderFor(acceptedServiceRequests)
final acceptedServiceRequestsProvider =
    AutoDisposeFutureProvider<List<OnDemandRequest>>.internal(
  acceptedServiceRequests,
  name: r'acceptedServiceRequestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$acceptedServiceRequestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AcceptedServiceRequestsRef
    = AutoDisposeFutureProviderRef<List<OnDemandRequest>>;
String _$professionalOnDemandControllerHash() =>
    r'219d36e3dd9a363ae78dc0c67d6dd3e2f9650bb2';

/// Controller para ações do profissional sobre solicitações on-demand.
///
/// Copied from [ProfessionalOnDemandController].
@ProviderFor(ProfessionalOnDemandController)
final professionalOnDemandControllerProvider = AutoDisposeAsyncNotifierProvider<
    ProfessionalOnDemandController, void>.internal(
  ProfessionalOnDemandController.new,
  name: r'professionalOnDemandControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$professionalOnDemandControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfessionalOnDemandController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
