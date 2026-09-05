// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'incorrect_monster.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

IncorrectMonster _$IncorrectMonsterFromJson(Map<String, dynamic> json) {
  return _IncorrectMonster.fromJson(json);
}

/// @nodoc
mixin _$IncorrectMonster {
  String get id => throw _privateConstructorUsedError; // UUID
  String get questionId =>
      throw _privateConstructorUsedError; // "stage_3_001_q1" など
  String get stageId => throw _privateConstructorUsedError; // "stage_3_001"
  int get questionNumber => throw _privateConstructorUsedError; // 1-10
  String get monsterName =>
      throw _privateConstructorUsedError; // 自動生成: 問題タイトルから
  DateTime get firstIncorrectDate =>
      throw _privateConstructorUsedError; // 初回間違い日時
  int get correctionsCount =>
      throw _privateConstructorUsedError; // 正解した回数（進化段階）
  EvolutionState get evolutionState =>
      throw _privateConstructorUsedError; // baby/juvenile/adult/sage
  List<DateTime> get correctionDates => throw _privateConstructorUsedError;

  /// Serializes this IncorrectMonster to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IncorrectMonster
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IncorrectMonsterCopyWith<IncorrectMonster> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncorrectMonsterCopyWith<$Res> {
  factory $IncorrectMonsterCopyWith(
    IncorrectMonster value,
    $Res Function(IncorrectMonster) then,
  ) = _$IncorrectMonsterCopyWithImpl<$Res, IncorrectMonster>;
  @useResult
  $Res call({
    String id,
    String questionId,
    String stageId,
    int questionNumber,
    String monsterName,
    DateTime firstIncorrectDate,
    int correctionsCount,
    EvolutionState evolutionState,
    List<DateTime> correctionDates,
  });
}

/// @nodoc
class _$IncorrectMonsterCopyWithImpl<$Res, $Val extends IncorrectMonster>
    implements $IncorrectMonsterCopyWith<$Res> {
  _$IncorrectMonsterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IncorrectMonster
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionId = null,
    Object? stageId = null,
    Object? questionNumber = null,
    Object? monsterName = null,
    Object? firstIncorrectDate = null,
    Object? correctionsCount = null,
    Object? evolutionState = null,
    Object? correctionDates = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            questionId: null == questionId
                ? _value.questionId
                : questionId // ignore: cast_nullable_to_non_nullable
                      as String,
            stageId: null == stageId
                ? _value.stageId
                : stageId // ignore: cast_nullable_to_non_nullable
                      as String,
            questionNumber: null == questionNumber
                ? _value.questionNumber
                : questionNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            monsterName: null == monsterName
                ? _value.monsterName
                : monsterName // ignore: cast_nullable_to_non_nullable
                      as String,
            firstIncorrectDate: null == firstIncorrectDate
                ? _value.firstIncorrectDate
                : firstIncorrectDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            correctionsCount: null == correctionsCount
                ? _value.correctionsCount
                : correctionsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            evolutionState: null == evolutionState
                ? _value.evolutionState
                : evolutionState // ignore: cast_nullable_to_non_nullable
                      as EvolutionState,
            correctionDates: null == correctionDates
                ? _value.correctionDates
                : correctionDates // ignore: cast_nullable_to_non_nullable
                      as List<DateTime>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IncorrectMonsterImplCopyWith<$Res>
    implements $IncorrectMonsterCopyWith<$Res> {
  factory _$$IncorrectMonsterImplCopyWith(
    _$IncorrectMonsterImpl value,
    $Res Function(_$IncorrectMonsterImpl) then,
  ) = __$$IncorrectMonsterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String questionId,
    String stageId,
    int questionNumber,
    String monsterName,
    DateTime firstIncorrectDate,
    int correctionsCount,
    EvolutionState evolutionState,
    List<DateTime> correctionDates,
  });
}

/// @nodoc
class __$$IncorrectMonsterImplCopyWithImpl<$Res>
    extends _$IncorrectMonsterCopyWithImpl<$Res, _$IncorrectMonsterImpl>
    implements _$$IncorrectMonsterImplCopyWith<$Res> {
  __$$IncorrectMonsterImplCopyWithImpl(
    _$IncorrectMonsterImpl _value,
    $Res Function(_$IncorrectMonsterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IncorrectMonster
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionId = null,
    Object? stageId = null,
    Object? questionNumber = null,
    Object? monsterName = null,
    Object? firstIncorrectDate = null,
    Object? correctionsCount = null,
    Object? evolutionState = null,
    Object? correctionDates = null,
  }) {
    return _then(
      _$IncorrectMonsterImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        questionId: null == questionId
            ? _value.questionId
            : questionId // ignore: cast_nullable_to_non_nullable
                  as String,
        stageId: null == stageId
            ? _value.stageId
            : stageId // ignore: cast_nullable_to_non_nullable
                  as String,
        questionNumber: null == questionNumber
            ? _value.questionNumber
            : questionNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        monsterName: null == monsterName
            ? _value.monsterName
            : monsterName // ignore: cast_nullable_to_non_nullable
                  as String,
        firstIncorrectDate: null == firstIncorrectDate
            ? _value.firstIncorrectDate
            : firstIncorrectDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        correctionsCount: null == correctionsCount
            ? _value.correctionsCount
            : correctionsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        evolutionState: null == evolutionState
            ? _value.evolutionState
            : evolutionState // ignore: cast_nullable_to_non_nullable
                  as EvolutionState,
        correctionDates: null == correctionDates
            ? _value._correctionDates
            : correctionDates // ignore: cast_nullable_to_non_nullable
                  as List<DateTime>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IncorrectMonsterImpl extends _IncorrectMonster {
  const _$IncorrectMonsterImpl({
    required this.id,
    required this.questionId,
    required this.stageId,
    required this.questionNumber,
    required this.monsterName,
    required this.firstIncorrectDate,
    this.correctionsCount = 0,
    this.evolutionState = EvolutionState.baby,
    final List<DateTime> correctionDates = const [],
  }) : _correctionDates = correctionDates,
       super._();

  factory _$IncorrectMonsterImpl.fromJson(Map<String, dynamic> json) =>
      _$$IncorrectMonsterImplFromJson(json);

  @override
  final String id;
  // UUID
  @override
  final String questionId;
  // "stage_3_001_q1" など
  @override
  final String stageId;
  // "stage_3_001"
  @override
  final int questionNumber;
  // 1-10
  @override
  final String monsterName;
  // 自動生成: 問題タイトルから
  @override
  final DateTime firstIncorrectDate;
  // 初回間違い日時
  @override
  @JsonKey()
  final int correctionsCount;
  // 正解した回数（進化段階）
  @override
  @JsonKey()
  final EvolutionState evolutionState;
  // baby/juvenile/adult/sage
  final List<DateTime> _correctionDates;
  // baby/juvenile/adult/sage
  @override
  @JsonKey()
  List<DateTime> get correctionDates {
    if (_correctionDates is EqualUnmodifiableListView) return _correctionDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_correctionDates);
  }

  @override
  String toString() {
    return 'IncorrectMonster(id: $id, questionId: $questionId, stageId: $stageId, questionNumber: $questionNumber, monsterName: $monsterName, firstIncorrectDate: $firstIncorrectDate, correctionsCount: $correctionsCount, evolutionState: $evolutionState, correctionDates: $correctionDates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncorrectMonsterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.stageId, stageId) || other.stageId == stageId) &&
            (identical(other.questionNumber, questionNumber) ||
                other.questionNumber == questionNumber) &&
            (identical(other.monsterName, monsterName) ||
                other.monsterName == monsterName) &&
            (identical(other.firstIncorrectDate, firstIncorrectDate) ||
                other.firstIncorrectDate == firstIncorrectDate) &&
            (identical(other.correctionsCount, correctionsCount) ||
                other.correctionsCount == correctionsCount) &&
            (identical(other.evolutionState, evolutionState) ||
                other.evolutionState == evolutionState) &&
            const DeepCollectionEquality().equals(
              other._correctionDates,
              _correctionDates,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    questionId,
    stageId,
    questionNumber,
    monsterName,
    firstIncorrectDate,
    correctionsCount,
    evolutionState,
    const DeepCollectionEquality().hash(_correctionDates),
  );

  /// Create a copy of IncorrectMonster
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IncorrectMonsterImplCopyWith<_$IncorrectMonsterImpl> get copyWith =>
      __$$IncorrectMonsterImplCopyWithImpl<_$IncorrectMonsterImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$IncorrectMonsterImplToJson(this);
  }
}

abstract class _IncorrectMonster extends IncorrectMonster {
  const factory _IncorrectMonster({
    required final String id,
    required final String questionId,
    required final String stageId,
    required final int questionNumber,
    required final String monsterName,
    required final DateTime firstIncorrectDate,
    final int correctionsCount,
    final EvolutionState evolutionState,
    final List<DateTime> correctionDates,
  }) = _$IncorrectMonsterImpl;
  const _IncorrectMonster._() : super._();

  factory _IncorrectMonster.fromJson(Map<String, dynamic> json) =
      _$IncorrectMonsterImpl.fromJson;

  @override
  String get id; // UUID
  @override
  String get questionId; // "stage_3_001_q1" など
  @override
  String get stageId; // "stage_3_001"
  @override
  int get questionNumber; // 1-10
  @override
  String get monsterName; // 自動生成: 問題タイトルから
  @override
  DateTime get firstIncorrectDate; // 初回間違い日時
  @override
  int get correctionsCount; // 正解した回数（進化段階）
  @override
  EvolutionState get evolutionState; // baby/juvenile/adult/sage
  @override
  List<DateTime> get correctionDates;

  /// Create a copy of IncorrectMonster
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IncorrectMonsterImplCopyWith<_$IncorrectMonsterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
