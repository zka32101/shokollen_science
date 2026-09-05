// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_mystery.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyMystery _$DailyMysteryFromJson(Map<String, dynamic> json) {
  return _DailyMystery.fromJson(json);
}

/// @nodoc
mixin _$DailyMystery {
  int get id => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  String get answer => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get grade => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DailyMystery to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyMystery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyMysteryCopyWith<DailyMystery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyMysteryCopyWith<$Res> {
  factory $DailyMysteryCopyWith(
    DailyMystery value,
    $Res Function(DailyMystery) then,
  ) = _$DailyMysteryCopyWithImpl<$Res, DailyMystery>;
  @useResult
  $Res call({
    int id,
    String question,
    String answer,
    String category,
    int grade,
    DateTime createdAt,
  });
}

/// @nodoc
class _$DailyMysteryCopyWithImpl<$Res, $Val extends DailyMystery>
    implements $DailyMysteryCopyWith<$Res> {
  _$DailyMysteryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyMystery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? answer = null,
    Object? category = null,
    Object? grade = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            question: null == question
                ? _value.question
                : question // ignore: cast_nullable_to_non_nullable
                      as String,
            answer: null == answer
                ? _value.answer
                : answer // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            grade: null == grade
                ? _value.grade
                : grade // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyMysteryImplCopyWith<$Res>
    implements $DailyMysteryCopyWith<$Res> {
  factory _$$DailyMysteryImplCopyWith(
    _$DailyMysteryImpl value,
    $Res Function(_$DailyMysteryImpl) then,
  ) = __$$DailyMysteryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String question,
    String answer,
    String category,
    int grade,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$DailyMysteryImplCopyWithImpl<$Res>
    extends _$DailyMysteryCopyWithImpl<$Res, _$DailyMysteryImpl>
    implements _$$DailyMysteryImplCopyWith<$Res> {
  __$$DailyMysteryImplCopyWithImpl(
    _$DailyMysteryImpl _value,
    $Res Function(_$DailyMysteryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyMystery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? answer = null,
    Object? category = null,
    Object? grade = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$DailyMysteryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        question: null == question
            ? _value.question
            : question // ignore: cast_nullable_to_non_nullable
                  as String,
        answer: null == answer
            ? _value.answer
            : answer // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        grade: null == grade
            ? _value.grade
            : grade // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyMysteryImpl implements _DailyMystery {
  const _$DailyMysteryImpl({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.grade,
    required this.createdAt,
  });

  factory _$DailyMysteryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyMysteryImplFromJson(json);

  @override
  final int id;
  @override
  final String question;
  @override
  final String answer;
  @override
  final String category;
  @override
  final int grade;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'DailyMystery(id: $id, question: $question, answer: $answer, category: $category, grade: $grade, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyMysteryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    question,
    answer,
    category,
    grade,
    createdAt,
  );

  /// Create a copy of DailyMystery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyMysteryImplCopyWith<_$DailyMysteryImpl> get copyWith =>
      __$$DailyMysteryImplCopyWithImpl<_$DailyMysteryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyMysteryImplToJson(this);
  }
}

abstract class _DailyMystery implements DailyMystery {
  const factory _DailyMystery({
    required final int id,
    required final String question,
    required final String answer,
    required final String category,
    required final int grade,
    required final DateTime createdAt,
  }) = _$DailyMysteryImpl;

  factory _DailyMystery.fromJson(Map<String, dynamic> json) =
      _$DailyMysteryImpl.fromJson;

  @override
  int get id;
  @override
  String get question;
  @override
  String get answer;
  @override
  String get category;
  @override
  int get grade;
  @override
  DateTime get createdAt;

  /// Create a copy of DailyMystery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyMysteryImplCopyWith<_$DailyMysteryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyMysteryRecord _$DailyMysteryRecordFromJson(Map<String, dynamic> json) {
  return _DailyMysteryRecord.fromJson(json);
}

/// @nodoc
mixin _$DailyMysteryRecord {
  String get userId => throw _privateConstructorUsedError;
  int get mysteryId => throw _privateConstructorUsedError;
  DateTime get revealedAt => throw _privateConstructorUsedError;
  DateTime? get answeredAt => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;

  /// Serializes this DailyMysteryRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyMysteryRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyMysteryRecordCopyWith<DailyMysteryRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyMysteryRecordCopyWith<$Res> {
  factory $DailyMysteryRecordCopyWith(
    DailyMysteryRecord value,
    $Res Function(DailyMysteryRecord) then,
  ) = _$DailyMysteryRecordCopyWithImpl<$Res, DailyMysteryRecord>;
  @useResult
  $Res call({
    String userId,
    int mysteryId,
    DateTime revealedAt,
    DateTime? answeredAt,
    bool isCorrect,
  });
}

/// @nodoc
class _$DailyMysteryRecordCopyWithImpl<$Res, $Val extends DailyMysteryRecord>
    implements $DailyMysteryRecordCopyWith<$Res> {
  _$DailyMysteryRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyMysteryRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? mysteryId = null,
    Object? revealedAt = null,
    Object? answeredAt = freezed,
    Object? isCorrect = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            mysteryId: null == mysteryId
                ? _value.mysteryId
                : mysteryId // ignore: cast_nullable_to_non_nullable
                      as int,
            revealedAt: null == revealedAt
                ? _value.revealedAt
                : revealedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            answeredAt: freezed == answeredAt
                ? _value.answeredAt
                : answeredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyMysteryRecordImplCopyWith<$Res>
    implements $DailyMysteryRecordCopyWith<$Res> {
  factory _$$DailyMysteryRecordImplCopyWith(
    _$DailyMysteryRecordImpl value,
    $Res Function(_$DailyMysteryRecordImpl) then,
  ) = __$$DailyMysteryRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    int mysteryId,
    DateTime revealedAt,
    DateTime? answeredAt,
    bool isCorrect,
  });
}

/// @nodoc
class __$$DailyMysteryRecordImplCopyWithImpl<$Res>
    extends _$DailyMysteryRecordCopyWithImpl<$Res, _$DailyMysteryRecordImpl>
    implements _$$DailyMysteryRecordImplCopyWith<$Res> {
  __$$DailyMysteryRecordImplCopyWithImpl(
    _$DailyMysteryRecordImpl _value,
    $Res Function(_$DailyMysteryRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyMysteryRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? mysteryId = null,
    Object? revealedAt = null,
    Object? answeredAt = freezed,
    Object? isCorrect = null,
  }) {
    return _then(
      _$DailyMysteryRecordImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        mysteryId: null == mysteryId
            ? _value.mysteryId
            : mysteryId // ignore: cast_nullable_to_non_nullable
                  as int,
        revealedAt: null == revealedAt
            ? _value.revealedAt
            : revealedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        answeredAt: freezed == answeredAt
            ? _value.answeredAt
            : answeredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyMysteryRecordImpl implements _DailyMysteryRecord {
  const _$DailyMysteryRecordImpl({
    required this.userId,
    required this.mysteryId,
    required this.revealedAt,
    required this.answeredAt,
    required this.isCorrect,
  });

  factory _$DailyMysteryRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyMysteryRecordImplFromJson(json);

  @override
  final String userId;
  @override
  final int mysteryId;
  @override
  final DateTime revealedAt;
  @override
  final DateTime? answeredAt;
  @override
  final bool isCorrect;

  @override
  String toString() {
    return 'DailyMysteryRecord(userId: $userId, mysteryId: $mysteryId, revealedAt: $revealedAt, answeredAt: $answeredAt, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyMysteryRecordImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.mysteryId, mysteryId) ||
                other.mysteryId == mysteryId) &&
            (identical(other.revealedAt, revealedAt) ||
                other.revealedAt == revealedAt) &&
            (identical(other.answeredAt, answeredAt) ||
                other.answeredAt == answeredAt) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    mysteryId,
    revealedAt,
    answeredAt,
    isCorrect,
  );

  /// Create a copy of DailyMysteryRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyMysteryRecordImplCopyWith<_$DailyMysteryRecordImpl> get copyWith =>
      __$$DailyMysteryRecordImplCopyWithImpl<_$DailyMysteryRecordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyMysteryRecordImplToJson(this);
  }
}

abstract class _DailyMysteryRecord implements DailyMysteryRecord {
  const factory _DailyMysteryRecord({
    required final String userId,
    required final int mysteryId,
    required final DateTime revealedAt,
    required final DateTime? answeredAt,
    required final bool isCorrect,
  }) = _$DailyMysteryRecordImpl;

  factory _DailyMysteryRecord.fromJson(Map<String, dynamic> json) =
      _$DailyMysteryRecordImpl.fromJson;

  @override
  String get userId;
  @override
  int get mysteryId;
  @override
  DateTime get revealedAt;
  @override
  DateTime? get answeredAt;
  @override
  bool get isCorrect;

  /// Create a copy of DailyMysteryRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyMysteryRecordImplCopyWith<_$DailyMysteryRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
