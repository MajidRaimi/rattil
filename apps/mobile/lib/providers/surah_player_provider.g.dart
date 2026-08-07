// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surah_player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$surahPlayerStateHash() => r'19508b7b40933c478e6ed0db5a26b4dd2bb3d7dc';

/// See also [surahPlayerState].
@ProviderFor(surahPlayerState)
final surahPlayerStateProvider = StreamProvider<imad.AudioPlayerState>.internal(
  surahPlayerState,
  name: r'surahPlayerStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$surahPlayerStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SurahPlayerStateRef = StreamProviderRef<imad.AudioPlayerState>;
String _$surahCompletedHash() => r'84044b366b736a7f187f3b89ec18eb39d12cde0f';

/// See also [surahCompleted].
@ProviderFor(surahCompleted)
final surahCompletedProvider = StreamProvider<int>.internal(
  surahCompleted,
  name: r'surahCompletedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$surahCompletedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SurahCompletedRef = StreamProviderRef<int>;
String _$selectedReciterIdHash() => r'67393ed8feffba36304bf9cfc6b9ed848b4656d1';

/// See also [SelectedReciterId].
@ProviderFor(SelectedReciterId)
final selectedReciterIdProvider =
    NotifierProvider<SelectedReciterId, int>.internal(
      SelectedReciterId.new,
      name: r'selectedReciterIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedReciterIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedReciterId = Notifier<int>;
String _$surahPlayerHash() => r'7b42828efe12bc56792597f6af9d514622e582c6';

/// See also [SurahPlayer].
@ProviderFor(SurahPlayer)
final surahPlayerProvider =
    NotifierProvider<SurahPlayer, SurahPlayerSession>.internal(
      SurahPlayer.new,
      name: r'surahPlayerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$surahPlayerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SurahPlayer = Notifier<SurahPlayerSession>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
