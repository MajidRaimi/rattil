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
String _$bookmarkKeysHash() => r'ca797d5e5c2e8ab0c953ff2b36f8ea4a1ab7f23e';

/// See also [bookmarkKeys].
@ProviderFor(bookmarkKeys)
final bookmarkKeysProvider = AutoDisposeFutureProvider<Set<String>>.internal(
  bookmarkKeys,
  name: r'bookmarkKeysProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookmarkKeysHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookmarkKeysRef = AutoDisposeFutureProviderRef<Set<String>>;
String _$allBookmarksHash() => r'c2f343c6cc58c464f2336a645fe2a15bf0b1e8cd';

/// See also [allBookmarks].
@ProviderFor(allBookmarks)
final allBookmarksProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      allBookmarks,
      name: r'allBookmarksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allBookmarksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllBookmarksRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$memorizedPagesHash() => r'845d797fe77decebd9b6dc447445ed0d69ed1f92';

/// See also [memorizedPages].
@ProviderFor(memorizedPages)
final memorizedPagesProvider = AutoDisposeFutureProvider<Set<int>>.internal(
  memorizedPages,
  name: r'memorizedPagesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$memorizedPagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemorizedPagesRef = AutoDisposeFutureProviderRef<Set<int>>;
String _$juzPageRangesHash() => r'85b5fd87dea7517d409d4e5314677b20398ffbaf';

/// See also [juzPageRanges].
@ProviderFor(juzPageRanges)
final juzPageRangesProvider =
    AutoDisposeFutureProvider<List<Map<String, int>>>.internal(
      juzPageRanges,
      name: r'juzPageRangesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$juzPageRangesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JuzPageRangesRef = AutoDisposeFutureProviderRef<List<Map<String, int>>>;
String _$juzSurahPageRangesHash() =>
    r'd905710c1312c099b43677f6a4863ace35060e23';

/// See also [juzSurahPageRanges].
@ProviderFor(juzSurahPageRanges)
final juzSurahPageRangesProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      juzSurahPageRanges,
      name: r'juzSurahPageRangesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$juzSurahPageRangesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JuzSurahPageRangesRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$hizbPageRangesHash() => r'10d1f5592b8ccd6c5e7a8f7ee87d965b48ee8c46';

/// See also [hizbPageRanges].
@ProviderFor(hizbPageRanges)
final hizbPageRangesProvider =
    AutoDisposeFutureProvider<List<Map<String, int>>>.internal(
      hizbPageRanges,
      name: r'hizbPageRangesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$hizbPageRangesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HizbPageRangesRef =
    AutoDisposeFutureProviderRef<List<Map<String, int>>>;
String _$wirdCompletedTodayHash() =>
    r'f5b302464bfe0c788dc72b12b434497ac0132025';

/// See also [wirdCompletedToday].
@ProviderFor(wirdCompletedToday)
final wirdCompletedTodayProvider = AutoDisposeFutureProvider<bool>.internal(
  wirdCompletedToday,
  name: r'wirdCompletedTodayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wirdCompletedTodayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WirdCompletedTodayRef = AutoDisposeFutureProviderRef<bool>;
String _$searchResultsHash() => r'e7732f45dcf7c7171c17bbad219310b81b5d818e';

/// See also [searchResults].
@ProviderFor(searchResults)
const searchResultsProvider = SearchResultsFamily();

/// See also [searchResults].
class SearchResultsFamily extends Family<AsyncValue<SearchState>> {
  /// See also [searchResults].
  const SearchResultsFamily();

  /// See also [searchResults].
  SearchResultsProvider call(String query) {
    return SearchResultsProvider(query);
  }

  @override
  SearchResultsProvider getProviderOverride(
    covariant SearchResultsProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchResultsProvider';
}

/// See also [searchResults].
class SearchResultsProvider extends AutoDisposeFutureProvider<SearchState> {
  /// See also [searchResults].
  SearchResultsProvider(String query)
    : this._internal(
        (ref) => searchResults(ref as SearchResultsRef, query),
        from: searchResultsProvider,
        name: r'searchResultsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchResultsHash,
        dependencies: SearchResultsFamily._dependencies,
        allTransitiveDependencies:
            SearchResultsFamily._allTransitiveDependencies,
        query: query,
      );

  SearchResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<SearchState> Function(SearchResultsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchResultsProvider._internal(
        (ref) => create(ref as SearchResultsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SearchState> createElement() {
    return _SearchResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchResultsRef on AutoDisposeFutureProviderRef<SearchState> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchResultsProviderElement
    extends AutoDisposeFutureProviderElement<SearchState>
    with SearchResultsRef {
  _SearchResultsProviderElement(super.provider);

  @override
  String get query => (origin as SearchResultsProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
