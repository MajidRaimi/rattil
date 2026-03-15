// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'surah.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Surah _$SurahFromJson(Map<String, dynamic> json) {
  return _Surah.fromJson(json);
}

/// @nodoc
mixin _$Surah {
  int get number => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_arabic')
  String get nameArabic => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_english')
  String get nameEnglish => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_translation')
  String get nameTranslation => throw _privateConstructorUsedError;
  @JsonKey(name: 'revelation_type')
  String get revelationType => throw _privateConstructorUsedError;
  @JsonKey(name: 'ayah_count')
  int get ayahCount => throw _privateConstructorUsedError;

  /// Serializes this Surah to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Surah
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SurahCopyWith<Surah> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SurahCopyWith<$Res> {
  factory $SurahCopyWith(Surah value, $Res Function(Surah) then) =
      _$SurahCopyWithImpl<$Res, Surah>;
  @useResult
  $Res call({
    int number,
    @JsonKey(name: 'name_arabic') String nameArabic,
    @JsonKey(name: 'name_english') String nameEnglish,
    @JsonKey(name: 'name_translation') String nameTranslation,
    @JsonKey(name: 'revelation_type') String revelationType,
    @JsonKey(name: 'ayah_count') int ayahCount,
  });
}

/// @nodoc
class _$SurahCopyWithImpl<$Res, $Val extends Surah>
    implements $SurahCopyWith<$Res> {
  _$SurahCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Surah
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? number = null,
    Object? nameArabic = null,
    Object? nameEnglish = null,
    Object? nameTranslation = null,
    Object? revelationType = null,
    Object? ayahCount = null,
  }) {
    return _then(
      _value.copyWith(
            number: null == number
                ? _value.number
                : number // ignore: cast_nullable_to_non_nullable
                      as int,
            nameArabic: null == nameArabic
                ? _value.nameArabic
                : nameArabic // ignore: cast_nullable_to_non_nullable
                      as String,
            nameEnglish: null == nameEnglish
                ? _value.nameEnglish
                : nameEnglish // ignore: cast_nullable_to_non_nullable
                      as String,
            nameTranslation: null == nameTranslation
                ? _value.nameTranslation
                : nameTranslation // ignore: cast_nullable_to_non_nullable
                      as String,
            revelationType: null == revelationType
                ? _value.revelationType
                : revelationType // ignore: cast_nullable_to_non_nullable
                      as String,
            ayahCount: null == ayahCount
                ? _value.ayahCount
                : ayahCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SurahImplCopyWith<$Res> implements $SurahCopyWith<$Res> {
  factory _$$SurahImplCopyWith(
    _$SurahImpl value,
    $Res Function(_$SurahImpl) then,
  ) = __$$SurahImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int number,
    @JsonKey(name: 'name_arabic') String nameArabic,
    @JsonKey(name: 'name_english') String nameEnglish,
    @JsonKey(name: 'name_translation') String nameTranslation,
    @JsonKey(name: 'revelation_type') String revelationType,
    @JsonKey(name: 'ayah_count') int ayahCount,
  });
}

/// @nodoc
class __$$SurahImplCopyWithImpl<$Res>
    extends _$SurahCopyWithImpl<$Res, _$SurahImpl>
    implements _$$SurahImplCopyWith<$Res> {
  __$$SurahImplCopyWithImpl(
    _$SurahImpl _value,
    $Res Function(_$SurahImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Surah
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? number = null,
    Object? nameArabic = null,
    Object? nameEnglish = null,
    Object? nameTranslation = null,
    Object? revelationType = null,
    Object? ayahCount = null,
  }) {
    return _then(
      _$SurahImpl(
        number: null == number
            ? _value.number
            : number // ignore: cast_nullable_to_non_nullable
                  as int,
        nameArabic: null == nameArabic
            ? _value.nameArabic
            : nameArabic // ignore: cast_nullable_to_non_nullable
                  as String,
        nameEnglish: null == nameEnglish
            ? _value.nameEnglish
            : nameEnglish // ignore: cast_nullable_to_non_nullable
                  as String,
        nameTranslation: null == nameTranslation
            ? _value.nameTranslation
            : nameTranslation // ignore: cast_nullable_to_non_nullable
                  as String,
        revelationType: null == revelationType
            ? _value.revelationType
            : revelationType // ignore: cast_nullable_to_non_nullable
                  as String,
        ayahCount: null == ayahCount
            ? _value.ayahCount
            : ayahCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SurahImpl implements _Surah {
  const _$SurahImpl({
    required this.number,
    @JsonKey(name: 'name_arabic') required this.nameArabic,
    @JsonKey(name: 'name_english') required this.nameEnglish,
    @JsonKey(name: 'name_translation') required this.nameTranslation,
    @JsonKey(name: 'revelation_type') required this.revelationType,
    @JsonKey(name: 'ayah_count') required this.ayahCount,
  });

  factory _$SurahImpl.fromJson(Map<String, dynamic> json) =>
      _$$SurahImplFromJson(json);

  @override
  final int number;
  @override
  @JsonKey(name: 'name_arabic')
  final String nameArabic;
  @override
  @JsonKey(name: 'name_english')
  final String nameEnglish;
  @override
  @JsonKey(name: 'name_translation')
  final String nameTranslation;
  @override
  @JsonKey(name: 'revelation_type')
  final String revelationType;
  @override
  @JsonKey(name: 'ayah_count')
  final int ayahCount;

  @override
  String toString() {
    return 'Surah(number: $number, nameArabic: $nameArabic, nameEnglish: $nameEnglish, nameTranslation: $nameTranslation, revelationType: $revelationType, ayahCount: $ayahCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SurahImpl &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.nameArabic, nameArabic) ||
                other.nameArabic == nameArabic) &&
            (identical(other.nameEnglish, nameEnglish) ||
                other.nameEnglish == nameEnglish) &&
            (identical(other.nameTranslation, nameTranslation) ||
                other.nameTranslation == nameTranslation) &&
            (identical(other.revelationType, revelationType) ||
                other.revelationType == revelationType) &&
            (identical(other.ayahCount, ayahCount) ||
                other.ayahCount == ayahCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    number,
    nameArabic,
    nameEnglish,
    nameTranslation,
    revelationType,
    ayahCount,
  );

  /// Create a copy of Surah
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SurahImplCopyWith<_$SurahImpl> get copyWith =>
      __$$SurahImplCopyWithImpl<_$SurahImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SurahImplToJson(this);
  }
}

abstract class _Surah implements Surah {
  const factory _Surah({
    required final int number,
    @JsonKey(name: 'name_arabic') required final String nameArabic,
    @JsonKey(name: 'name_english') required final String nameEnglish,
    @JsonKey(name: 'name_translation') required final String nameTranslation,
    @JsonKey(name: 'revelation_type') required final String revelationType,
    @JsonKey(name: 'ayah_count') required final int ayahCount,
  }) = _$SurahImpl;

  factory _Surah.fromJson(Map<String, dynamic> json) = _$SurahImpl.fromJson;

  @override
  int get number;
  @override
  @JsonKey(name: 'name_arabic')
  String get nameArabic;
  @override
  @JsonKey(name: 'name_english')
  String get nameEnglish;
  @override
  @JsonKey(name: 'name_translation')
  String get nameTranslation;
  @override
  @JsonKey(name: 'revelation_type')
  String get revelationType;
  @override
  @JsonKey(name: 'ayah_count')
  int get ayahCount;

  /// Create a copy of Surah
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SurahImplCopyWith<_$SurahImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
