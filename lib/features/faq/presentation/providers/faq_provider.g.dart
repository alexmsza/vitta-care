// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$faqRepositoryHash() => r'1a9ca7ed456807484b2e265ac44d9f86df418075';

/// See also [faqRepository].
@ProviderFor(faqRepository)
final faqRepositoryProvider = AutoDisposeProvider<FaqRepository>.internal(
  faqRepository,
  name: r'faqRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$faqRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FaqRepositoryRef = AutoDisposeProviderRef<FaqRepository>;
String _$faqItemsHash() => r'bb2c64279873acc6ab32b81949ec1c446c5acb90';

/// See also [faqItems].
@ProviderFor(faqItems)
final faqItemsProvider = AutoDisposeFutureProvider<List<FaqItem>>.internal(
  faqItems,
  name: r'faqItemsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$faqItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FaqItemsRef = AutoDisposeFutureProviderRef<List<FaqItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
