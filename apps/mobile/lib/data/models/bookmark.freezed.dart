// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmark.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Bookmark _$BookmarkFromJson(Map<String, dynamic> json) {
  return _Bookmark.fromJson(json);
}

/// @nodoc
mixin _$Bookmark {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'surah_number')
  int get surahNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'ayah_number')
  int get ayahNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Bookmark to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Bookmark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookmarkCopyWith<Bookmark> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookmarkCopyWith<$Res> {
  factory $BookmarkCopyWith(Bookmark value, $Res Function(Bookmark) then) =
      _$BookmarkCopyWithImpl<$Res, Bookmark>;
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'surah_number') int surahNumber,
    @JsonKey(name: 'ayah_number') int ayahNumber,
    @JsonKey(name: 'created_at') String? createdAt,
  });
}

/// @nodoc
class _$BookmarkCopyWithImpl<$Res, $Val extends Bookmark>
    implements $BookmarkCopyWith<$Res> {
  _$BookmarkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Bookmark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? surahNumber = null,
    Object? ayahNumber = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            surahNumber: null == surahNumber
                ? _value.surahNumber
                : surahNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            ayahNumber: null == ayahNumber
                ? _value.ayahNumber
                : ayahNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookmarkImplCopyWith<$Res>
    implements $BookmarkCopyWith<$Res> {
  factory _$$BookmarkImplCopyWith(
    _$BookmarkImpl value,
    $Res Function(_$BookmarkImpl) then,
  ) = __$$BookmarkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'surah_number') int surahNumber,
    @JsonKey(name: 'ayah_number') int ayahNumber,
    @JsonKey(name: 'created_at') String? createdAt,
  });
}

/// @nodoc
class __$$BookmarkImplCopyWithImpl<$Res>
    extends _$BookmarkCopyWithImpl<$Res, _$BookmarkImpl>
    implements _$$BookmarkImplCopyWith<$Res> {
  __$$BookmarkImplCopyWithImpl(
    _$BookmarkImpl _value,
    $Res Function(_$BookmarkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Bookmark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? surahNumber = null,
    Object? ayahNumber = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$BookmarkImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        surahNumber: null == surahNumber
            ? _value.surahNumber
            : surahNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        ayahNumber: null == ayahNumber
            ? _value.ayahNumber
            : ayahNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookmarkImpl implements _Bookmark {
  const _$BookmarkImpl({
    this.id,
    @JsonKey(name: 'surah_number') required this.surahNumber,
    @JsonKey(name: 'ayah_number') required this.ayahNumber,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$BookmarkImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookmarkImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'surah_number')
  final int surahNumber;
  @override
  @JsonKey(name: 'ayah_number')
  final int ayahNumber;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @override
  String toString() {
    return 'Bookmark(id: $id, surahNumber: $surahNumber, ayahNumber: $ayahNumber, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookmarkImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.surahNumber, surahNumber) ||
                other.surahNumber == surahNumber) &&
            (identical(other.ayahNumber, ayahNumber) ||
                other.ayahNumber == ayahNumber) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, surahNumber, ayahNumber, createdAt);

  /// Create a copy of Bookmark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookmarkImplCopyWith<_$BookmarkImpl> get copyWith =>
      __$$BookmarkImplCopyWithImpl<_$BookmarkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookmarkImplToJson(this);
  }
}

abstract class _Bookmark implements Bookmark {
  const factory _Bookmark({
    final int? id,
    @JsonKey(name: 'surah_number') required final int surahNumber,
    @JsonKey(name: 'ayah_number') required final int ayahNumber,
    @JsonKey(name: 'created_at') final String? createdAt,
  }) = _$BookmarkImpl;

  factory _Bookmark.fromJson(Map<String, dynamic> json) =
      _$BookmarkImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'surah_number')
  int get surahNumber;
  @override
  @JsonKey(name: 'ayah_number')
  int get ayahNumber;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of Bookmark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookmarkImplCopyWith<_$BookmarkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
