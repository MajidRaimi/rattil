// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ayah.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Ayah _$AyahFromJson(Map<String, dynamic> json) {
  return _Ayah.fromJson(json);
}

/// @nodoc
mixin _$Ayah {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'surah_number')
  int get surahNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'ayah_number')
  int get ayahNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'text_uthmani')
  String get textUthmani => throw _privateConstructorUsedError;
  @JsonKey(name: 'text_simple')
  String get textSimple => throw _privateConstructorUsedError;
  int get juz => throw _privateConstructorUsedError;
  int get hizb => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  String? get translation => throw _privateConstructorUsedError;

  /// Serializes this Ayah to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Ayah
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AyahCopyWith<Ayah> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AyahCopyWith<$Res> {
  factory $AyahCopyWith(Ayah value, $Res Function(Ayah) then) =
      _$AyahCopyWithImpl<$Res, Ayah>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'surah_number') int surahNumber,
    @JsonKey(name: 'ayah_number') int ayahNumber,
    @JsonKey(name: 'text_uthmani') String textUthmani,
    @JsonKey(name: 'text_simple') String textSimple,
    int juz,
    int hizb,
    int page,
    String? translation,
  });
}

/// @nodoc
class _$AyahCopyWithImpl<$Res, $Val extends Ayah>
    implements $AyahCopyWith<$Res> {
  _$AyahCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Ayah
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? surahNumber = null,
    Object? ayahNumber = null,
    Object? textUthmani = null,
    Object? textSimple = null,
    Object? juz = null,
    Object? hizb = null,
    Object? page = null,
    Object? translation = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            surahNumber: null == surahNumber
                ? _value.surahNumber
                : surahNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            ayahNumber: null == ayahNumber
                ? _value.ayahNumber
                : ayahNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            textUthmani: null == textUthmani
                ? _value.textUthmani
                : textUthmani // ignore: cast_nullable_to_non_nullable
                      as String,
            textSimple: null == textSimple
                ? _value.textSimple
                : textSimple // ignore: cast_nullable_to_non_nullable
                      as String,
            juz: null == juz
                ? _value.juz
                : juz // ignore: cast_nullable_to_non_nullable
                      as int,
            hizb: null == hizb
                ? _value.hizb
                : hizb // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            translation: freezed == translation
                ? _value.translation
                : translation // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AyahImplCopyWith<$Res> implements $AyahCopyWith<$Res> {
  factory _$$AyahImplCopyWith(
    _$AyahImpl value,
    $Res Function(_$AyahImpl) then,
  ) = __$$AyahImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'surah_number') int surahNumber,
    @JsonKey(name: 'ayah_number') int ayahNumber,
    @JsonKey(name: 'text_uthmani') String textUthmani,
    @JsonKey(name: 'text_simple') String textSimple,
    int juz,
    int hizb,
    int page,
    String? translation,
  });
}

/// @nodoc
class __$$AyahImplCopyWithImpl<$Res>
    extends _$AyahCopyWithImpl<$Res, _$AyahImpl>
    implements _$$AyahImplCopyWith<$Res> {
  __$$AyahImplCopyWithImpl(_$AyahImpl _value, $Res Function(_$AyahImpl) _then)
    : super(_value, _then);

  /// Create a copy of Ayah
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? surahNumber = null,
    Object? ayahNumber = null,
    Object? textUthmani = null,
    Object? textSimple = null,
    Object? juz = null,
    Object? hizb = null,
    Object? page = null,
    Object? translation = freezed,
  }) {
    return _then(
      _$AyahImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        surahNumber: null == surahNumber
            ? _value.surahNumber
            : surahNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        ayahNumber: null == ayahNumber
            ? _value.ayahNumber
            : ayahNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        textUthmani: null == textUthmani
            ? _value.textUthmani
            : textUthmani // ignore: cast_nullable_to_non_nullable
                  as String,
        textSimple: null == textSimple
            ? _value.textSimple
            : textSimple // ignore: cast_nullable_to_non_nullable
                  as String,
        juz: null == juz
            ? _value.juz
            : juz // ignore: cast_nullable_to_non_nullable
                  as int,
        hizb: null == hizb
            ? _value.hizb
            : hizb // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        translation: freezed == translation
            ? _value.translation
            : translation // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AyahImpl implements _Ayah {
  const _$AyahImpl({
    required this.id,
    @JsonKey(name: 'surah_number') required this.surahNumber,
    @JsonKey(name: 'ayah_number') required this.ayahNumber,
    @JsonKey(name: 'text_uthmani') required this.textUthmani,
    @JsonKey(name: 'text_simple') required this.textSimple,
    required this.juz,
    required this.hizb,
    required this.page,
    this.translation,
  });

  factory _$AyahImpl.fromJson(Map<String, dynamic> json) =>
      _$$AyahImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'surah_number')
  final int surahNumber;
  @override
  @JsonKey(name: 'ayah_number')
  final int ayahNumber;
  @override
  @JsonKey(name: 'text_uthmani')
  final String textUthmani;
  @override
  @JsonKey(name: 'text_simple')
  final String textSimple;
  @override
  final int juz;
  @override
  final int hizb;
  @override
  final int page;
  @override
  final String? translation;

  @override
  String toString() {
    return 'Ayah(id: $id, surahNumber: $surahNumber, ayahNumber: $ayahNumber, textUthmani: $textUthmani, textSimple: $textSimple, juz: $juz, hizb: $hizb, page: $page, translation: $translation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AyahImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.surahNumber, surahNumber) ||
                other.surahNumber == surahNumber) &&
            (identical(other.ayahNumber, ayahNumber) ||
                other.ayahNumber == ayahNumber) &&
            (identical(other.textUthmani, textUthmani) ||
                other.textUthmani == textUthmani) &&
            (identical(other.textSimple, textSimple) ||
                other.textSimple == textSimple) &&
            (identical(other.juz, juz) || other.juz == juz) &&
            (identical(other.hizb, hizb) || other.hizb == hizb) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.translation, translation) ||
                other.translation == translation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    surahNumber,
    ayahNumber,
    textUthmani,
    textSimple,
    juz,
    hizb,
    page,
    translation,
  );

  /// Create a copy of Ayah
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AyahImplCopyWith<_$AyahImpl> get copyWith =>
      __$$AyahImplCopyWithImpl<_$AyahImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AyahImplToJson(this);
  }
}

abstract class _Ayah implements Ayah {
  const factory _Ayah({
    required final int id,
    @JsonKey(name: 'surah_number') required final int surahNumber,
    @JsonKey(name: 'ayah_number') required final int ayahNumber,
    @JsonKey(name: 'text_uthmani') required final String textUthmani,
    @JsonKey(name: 'text_simple') required final String textSimple,
    required final int juz,
    required final int hizb,
    required final int page,
    final String? translation,
  }) = _$AyahImpl;

  factory _Ayah.fromJson(Map<String, dynamic> json) = _$AyahImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'surah_number')
  int get surahNumber;
  @override
  @JsonKey(name: 'ayah_number')
  int get ayahNumber;
  @override
  @JsonKey(name: 'text_uthmani')
  String get textUthmani;
  @override
  @JsonKey(name: 'text_simple')
  String get textSimple;
  @override
  int get juz;
  @override
  int get hizb;
  @override
  int get page;
  @override
  String? get translation;

  /// Create a copy of Ayah
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AyahImplCopyWith<_$AyahImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
