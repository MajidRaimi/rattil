// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nastaleeq_text_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nastaleeqTextHash() => r'8b76025908a5658cbb28c18eeb6713bdf15c91a6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [nastaleeqText].
@ProviderFor(nastaleeqText)
const nastaleeqTextProvider = NastaleeqTextFamily();

/// See also [nastaleeqText].
class NastaleeqTextFamily extends Family<AsyncValue<NastaleeqText>> {
  /// See also [nastaleeqText].
  const NastaleeqTextFamily();

  /// See also [nastaleeqText].
  NastaleeqTextProvider call(NastaleeqEdition edition) {
    return NastaleeqTextProvider(edition);
  }

  @override
  NastaleeqTextProvider getProviderOverride(
    covariant NastaleeqTextProvider provider,
  ) {
    return call(provider.edition);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'nastaleeqTextProvider';
}

/// See also [nastaleeqText].
class NastaleeqTextProvider extends FutureProvider<NastaleeqText> {
  /// See also [nastaleeqText].
  NastaleeqTextProvider(NastaleeqEdition edition)
    : this._internal(
        (ref) => nastaleeqText(ref as NastaleeqTextRef, edition),
        from: nastaleeqTextProvider,
        name: r'nastaleeqTextProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$nastaleeqTextHash,
        dependencies: NastaleeqTextFamily._dependencies,
        allTransitiveDependencies:
            NastaleeqTextFamily._allTransitiveDependencies,
        edition: edition,
      );

  NastaleeqTextProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.edition,
  }) : super.internal();

  final NastaleeqEdition edition;

  @override
  Override overrideWith(
    FutureOr<NastaleeqText> Function(NastaleeqTextRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NastaleeqTextProvider._internal(
        (ref) => create(ref as NastaleeqTextRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        edition: edition,
      ),
    );
  }

  @override
  FutureProviderElement<NastaleeqText> createElement() {
    return _NastaleeqTextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NastaleeqTextProvider && other.edition == edition;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, edition.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NastaleeqTextRef on FutureProviderRef<NastaleeqText> {
  /// The parameter `edition` of this provider.
  NastaleeqEdition get edition;
}

class _NastaleeqTextProviderElement extends FutureProviderElement<NastaleeqText>
    with NastaleeqTextRef {
  _NastaleeqTextProviderElement(super.provider);

  @override
  NastaleeqEdition get edition => (origin as NastaleeqTextProvider).edition;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
