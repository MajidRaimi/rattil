// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quranLocalDatasourceHash() =>
    r'5a360919820d01a5477ff49a690837b8fffdf867';

/// See also [quranLocalDatasource].
@ProviderFor(quranLocalDatasource)
final quranLocalDatasourceProvider = Provider<QuranLocalDatasource>.internal(
  quranLocalDatasource,
  name: r'quranLocalDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quranLocalDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuranLocalDatasourceRef = ProviderRef<QuranLocalDatasource>;
String _$quranRepositoryHash() => r'46cbf4b3043514a87924131fbf171b5411756bb9';

/// See also [quranRepository].
@ProviderFor(quranRepository)
final quranRepositoryProvider = Provider<QuranRepository>.internal(
  quranRepository,
  name: r'quranRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quranRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuranRepositoryRef = ProviderRef<QuranRepository>;
String _$allSurahsHash() => r'cd2a6898851569e78b91b0d4846112f5d3fcaa49';

/// See also [allSurahs].
@ProviderFor(allSurahs)
final allSurahsProvider = AutoDisposeFutureProvider<List<Surah>>.internal(
  allSurahs,
  name: r'allSurahsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allSurahsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllSurahsRef = AutoDisposeFutureProviderRef<List<Surah>>;
String _$surahAyahsHash() => r'8b946a22251f5528fe38ce669f157c334b8fa88e';

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

/// See also [surahAyahs].
@ProviderFor(surahAyahs)
const surahAyahsProvider = SurahAyahsFamily();

/// See also [surahAyahs].
class SurahAyahsFamily extends Family<AsyncValue<List<Ayah>>> {
  /// See also [surahAyahs].
  const SurahAyahsFamily();

  /// See also [surahAyahs].
  SurahAyahsProvider call(int surahNumber) {
    return SurahAyahsProvider(surahNumber);
  }

  @override
  SurahAyahsProvider getProviderOverride(
    covariant SurahAyahsProvider provider,
  ) {
    return call(provider.surahNumber);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'surahAyahsProvider';
}

/// See also [surahAyahs].
class SurahAyahsProvider extends AutoDisposeFutureProvider<List<Ayah>> {
  /// See also [surahAyahs].
  SurahAyahsProvider(int surahNumber)
    : this._internal(
        (ref) => surahAyahs(ref as SurahAyahsRef, surahNumber),
        from: surahAyahsProvider,
        name: r'surahAyahsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$surahAyahsHash,
        dependencies: SurahAyahsFamily._dependencies,
        allTransitiveDependencies: SurahAyahsFamily._allTransitiveDependencies,
        surahNumber: surahNumber,
      );

  SurahAyahsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.surahNumber,
  }) : super.internal();

  final int surahNumber;

  @override
  Override overrideWith(
    FutureOr<List<Ayah>> Function(SurahAyahsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SurahAyahsProvider._internal(
        (ref) => create(ref as SurahAyahsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        surahNumber: surahNumber,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Ayah>> createElement() {
    return _SurahAyahsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SurahAyahsProvider && other.surahNumber == surahNumber;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, surahNumber.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SurahAyahsRef on AutoDisposeFutureProviderRef<List<Ayah>> {
  /// The parameter `surahNumber` of this provider.
  int get surahNumber;
}

class _SurahAyahsProviderElement
    extends AutoDisposeFutureProviderElement<List<Ayah>>
    with SurahAyahsRef {
  _SurahAyahsProviderElement(super.provider);

  @override
  int get surahNumber => (origin as SurahAyahsProvider).surahNumber;
}

String _$surahHash() => r'bd785d2c56e88a77974c5093590af100c73cb9d6';

/// See also [surah].
@ProviderFor(surah)
const surahProvider = SurahFamily();

/// See also [surah].
class SurahFamily extends Family<AsyncValue<Surah?>> {
  /// See also [surah].
  const SurahFamily();

  /// See also [surah].
  SurahProvider call(int number) {
    return SurahProvider(number);
  }

  @override
  SurahProvider getProviderOverride(covariant SurahProvider provider) {
    return call(provider.number);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'surahProvider';
}

/// See also [surah].
class SurahProvider extends AutoDisposeFutureProvider<Surah?> {
  /// See also [surah].
  SurahProvider(int number)
    : this._internal(
        (ref) => surah(ref as SurahRef, number),
        from: surahProvider,
        name: r'surahProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$surahHash,
        dependencies: SurahFamily._dependencies,
        allTransitiveDependencies: SurahFamily._allTransitiveDependencies,
        number: number,
      );

  SurahProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.number,
  }) : super.internal();

  final int number;

  @override
  Override overrideWith(FutureOr<Surah?> Function(SurahRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: SurahProvider._internal(
        (ref) => create(ref as SurahRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        number: number,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Surah?> createElement() {
    return _SurahProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SurahProvider && other.number == number;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, number.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SurahRef on AutoDisposeFutureProviderRef<Surah?> {
  /// The parameter `number` of this provider.
  int get number;
}

class _SurahProviderElement extends AutoDisposeFutureProviderElement<Surah?>
    with SurahRef {
  _SurahProviderElement(super.provider);

  @override
  int get number => (origin as SurahProvider).number;
}

String _$readingProgressHash() => r'60774242edc258a5b6328db2bc153eaad7e12816';

/// See also [readingProgress].
@ProviderFor(readingProgress)
final readingProgressProvider =
    AutoDisposeFutureProvider<Map<String, int>>.internal(
      readingProgress,
      name: r'readingProgressProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$readingProgressHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReadingProgressRef = AutoDisposeFutureProviderRef<Map<String, int>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
