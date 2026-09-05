// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReviewSchedule _$ReviewScheduleFromJson(Map<String, dynamic> json) {
  return _ReviewSchedule.fromJson(json);
}

/// @nodoc
mixin _$ReviewSchedule {
  ReviewInterval get interval => throw _privateConstructorUsedError;
  DateTime get nextReviewDate => throw _privateConstructorUsedError;
  ReviewStatus get status => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this ReviewSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewScheduleCopyWith<ReviewSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewScheduleCopyWith<$Res> {
  factory $ReviewScheduleCopyWith(
    ReviewSchedule value,
    $Res Function(ReviewSchedule) then,
  ) = _$ReviewScheduleCopyWithImpl<$Res, ReviewSchedule>;
  @useResult
  $Res call({
    ReviewInterval interval,
    DateTime nextReviewDate,
    ReviewStatus status,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$ReviewScheduleCopyWithImpl<$Res, $Val extends ReviewSchedule>
    implements $ReviewScheduleCopyWith<$Res> {
  _$ReviewScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? interval = null,
    Object? nextReviewDate = null,
    Object? status = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            interval: null == interval
                ? _value.interval
                : interval // ignore: cast_nullable_to_non_nullable
                      as ReviewInterval,
            nextReviewDate: null == nextReviewDate
                ? _value.nextReviewDate
                : nextReviewDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReviewStatus,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewScheduleImplCopyWith<$Res>
    implements $ReviewScheduleCopyWith<$Res> {
  factory _$$ReviewScheduleImplCopyWith(
    _$ReviewScheduleImpl value,
    $Res Function(_$ReviewScheduleImpl) then,
  ) = __$$ReviewScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ReviewInterval interval,
    DateTime nextReviewDate,
    ReviewStatus status,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$ReviewScheduleImplCopyWithImpl<$Res>
    extends _$ReviewScheduleCopyWithImpl<$Res, _$ReviewScheduleImpl>
    implements _$$ReviewScheduleImplCopyWith<$Res> {
  __$$ReviewScheduleImplCopyWithImpl(
    _$ReviewScheduleImpl _value,
    $Res Function(_$ReviewScheduleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? interval = null,
    Object? nextReviewDate = null,
    Object? status = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$ReviewScheduleImpl(
        interval: null == interval
            ? _value.interval
            : interval // ignore: cast_nullable_to_non_nullable
                  as ReviewInterval,
        nextReviewDate: null == nextReviewDate
            ? _value.nextReviewDate
            : nextReviewDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReviewStatus,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewScheduleImpl extends _ReviewSchedule {
  const _$ReviewScheduleImpl({
    required this.interval,
    required this.nextReviewDate,
    this.status = ReviewStatus.pending,
    this.completedAt,
  }) : super._();

  factory _$ReviewScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewScheduleImplFromJson(json);

  @override
  final ReviewInterval interval;
  @override
  final DateTime nextReviewDate;
  @override
  @JsonKey()
  final ReviewStatus status;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'ReviewSchedule(interval: $interval, nextReviewDate: $nextReviewDate, status: $status, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewScheduleImpl &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.nextReviewDate, nextReviewDate) ||
                other.nextReviewDate == nextReviewDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, interval, nextReviewDate, status, completedAt);

  /// Create a copy of ReviewSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewScheduleImplCopyWith<_$ReviewScheduleImpl> get copyWith =>
      __$$ReviewScheduleImplCopyWithImpl<_$ReviewScheduleImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewScheduleImplToJson(this);
  }
}

abstract class _ReviewSchedule extends ReviewSchedule {
  const factory _ReviewSchedule({
    required final ReviewInterval interval,
    required final DateTime nextReviewDate,
    final ReviewStatus status,
    final DateTime? completedAt,
  }) = _$ReviewScheduleImpl;
  const _ReviewSchedule._() : super._();

  factory _ReviewSchedule.fromJson(Map<String, dynamic> json) =
      _$ReviewScheduleImpl.fromJson;

  @override
  ReviewInterval get interval;
  @override
  DateTime get nextReviewDate;
  @override
  ReviewStatus get status;
  @override
  DateTime? get completedAt;

  /// Create a copy of ReviewSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewScheduleImplCopyWith<_$ReviewScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeCapsule _$TimeCapsuleFromJson(Map<String, dynamic> json) {
  return _TimeCapsule.fromJson(json);
}

/// @nodoc
mixin _$TimeCapsule {
  String get id => throw _privateConstructorUsedError; // UUID
  String get questionId =>
      throw _privateConstructorUsedError; // "stage_3_001_q1"
  String get stageId => throw _privateConstructorUsedError; // "stage_3_001"
  int get questionNumber => throw _privateConstructorUsedError; // 1-10
  String get questionTitle => throw _privateConstructorUsedError; // 問題タイトル
  DateTime get firstCorrectDate => throw _privateConstructorUsedError; // 初回正解日時
  List<ReviewSchedule> get schedules =>
      throw _privateConstructorUsedError; // 復習スケジュール
  int get completedCount => throw _privateConstructorUsedError; // 完了した復習数（0-4）
  bool get isFullyCompleted => throw _privateConstructorUsedError;

  /// Serializes this TimeCapsule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeCapsule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeCapsuleCopyWith<TimeCapsule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeCapsuleCopyWith<$Res> {
  factory $TimeCapsuleCopyWith(
    TimeCapsule value,
    $Res Function(TimeCapsule) then,
  ) = _$TimeCapsuleCopyWithImpl<$Res, TimeCapsule>;
  @useResult
  $Res call({
    String id,
    String questionId,
    String stageId,
    int questionNumber,
    String questionTitle,
    DateTime firstCorrectDate,
    List<ReviewSchedule> schedules,
    int completedCount,
    bool isFullyCompleted,
  });
}

/// @nodoc
class _$TimeCapsuleCopyWithImpl<$Res, $Val extends TimeCapsule>
    implements $TimeCapsuleCopyWith<$Res> {
  _$TimeCapsuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeCapsule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionId = null,
    Object? stageId = null,
    Object? questionNumber = null,
    Object? questionTitle = null,
    Object? firstCorrectDate = null,
    Object? schedules = null,
    Object? completedCount = null,
    Object? isFullyCompleted = null,
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
            questionTitle: null == questionTitle
                ? _value.questionTitle
                : questionTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            firstCorrectDate: null == firstCorrectDate
                ? _value.firstCorrectDate
                : firstCorrectDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            schedules: null == schedules
                ? _value.schedules
                : schedules // ignore: cast_nullable_to_non_nullable
                      as List<ReviewSchedule>,
            completedCount: null == completedCount
                ? _value.completedCount
                : completedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isFullyCompleted: null == isFullyCompleted
                ? _value.isFullyCompleted
                : isFullyCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimeCapsuleImplCopyWith<$Res>
    implements $TimeCapsuleCopyWith<$Res> {
  factory _$$TimeCapsuleImplCopyWith(
    _$TimeCapsuleImpl value,
    $Res Function(_$TimeCapsuleImpl) then,
  ) = __$$TimeCapsuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String questionId,
    String stageId,
    int questionNumber,
    String questionTitle,
    DateTime firstCorrectDate,
    List<ReviewSchedule> schedules,
    int completedCount,
    bool isFullyCompleted,
  });
}

/// @nodoc
class __$$TimeCapsuleImplCopyWithImpl<$Res>
    extends _$TimeCapsuleCopyWithImpl<$Res, _$TimeCapsuleImpl>
    implements _$$TimeCapsuleImplCopyWith<$Res> {
  __$$TimeCapsuleImplCopyWithImpl(
    _$TimeCapsuleImpl _value,
    $Res Function(_$TimeCapsuleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimeCapsule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionId = null,
    Object? stageId = null,
    Object? questionNumber = null,
    Object? questionTitle = null,
    Object? firstCorrectDate = null,
    Object? schedules = null,
    Object? completedCount = null,
    Object? isFullyCompleted = null,
  }) {
    return _then(
      _$TimeCapsuleImpl(
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
        questionTitle: null == questionTitle
            ? _value.questionTitle
            : questionTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        firstCorrectDate: null == firstCorrectDate
            ? _value.firstCorrectDate
            : firstCorrectDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        schedules: null == schedules
            ? _value._schedules
            : schedules // ignore: cast_nullable_to_non_nullable
                  as List<ReviewSchedule>,
        completedCount: null == completedCount
            ? _value.completedCount
            : completedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isFullyCompleted: null == isFullyCompleted
            ? _value.isFullyCompleted
            : isFullyCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeCapsuleImpl extends _TimeCapsule {
  const _$TimeCapsuleImpl({
    required this.id,
    required this.questionId,
    required this.stageId,
    required this.questionNumber,
    required this.questionTitle,
    required this.firstCorrectDate,
    final List<ReviewSchedule> schedules = const [],
    this.completedCount = 0,
    this.isFullyCompleted = false,
  }) : _schedules = schedules,
       super._();

  factory _$TimeCapsuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeCapsuleImplFromJson(json);

  @override
  final String id;
  // UUID
  @override
  final String questionId;
  // "stage_3_001_q1"
  @override
  final String stageId;
  // "stage_3_001"
  @override
  final int questionNumber;
  // 1-10
  @override
  final String questionTitle;
  // 問題タイトル
  @override
  final DateTime firstCorrectDate;
  // 初回正解日時
  final List<ReviewSchedule> _schedules;
  // 初回正解日時
  @override
  @JsonKey()
  List<ReviewSchedule> get schedules {
    if (_schedules is EqualUnmodifiableListView) return _schedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedules);
  }

  // 復習スケジュール
  @override
  @JsonKey()
  final int completedCount;
  // 完了した復習数（0-4）
  @override
  @JsonKey()
  final bool isFullyCompleted;

  @override
  String toString() {
    return 'TimeCapsule(id: $id, questionId: $questionId, stageId: $stageId, questionNumber: $questionNumber, questionTitle: $questionTitle, firstCorrectDate: $firstCorrectDate, schedules: $schedules, completedCount: $completedCount, isFullyCompleted: $isFullyCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeCapsuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.stageId, stageId) || other.stageId == stageId) &&
            (identical(other.questionNumber, questionNumber) ||
                other.questionNumber == questionNumber) &&
            (identical(other.questionTitle, questionTitle) ||
                other.questionTitle == questionTitle) &&
            (identical(other.firstCorrectDate, firstCorrectDate) ||
                other.firstCorrectDate == firstCorrectDate) &&
            const DeepCollectionEquality().equals(
              other._schedules,
              _schedules,
            ) &&
            (identical(other.completedCount, completedCount) ||
                other.completedCount == completedCount) &&
            (identical(other.isFullyCompleted, isFullyCompleted) ||
                other.isFullyCompleted == isFullyCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    questionId,
    stageId,
    questionNumber,
    questionTitle,
    firstCorrectDate,
    const DeepCollectionEquality().hash(_schedules),
    completedCount,
    isFullyCompleted,
  );

  /// Create a copy of TimeCapsule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeCapsuleImplCopyWith<_$TimeCapsuleImpl> get copyWith =>
      __$$TimeCapsuleImplCopyWithImpl<_$TimeCapsuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeCapsuleImplToJson(this);
  }
}

abstract class _TimeCapsule extends TimeCapsule {
  const factory _TimeCapsule({
    required final String id,
    required final String questionId,
    required final String stageId,
    required final int questionNumber,
    required final String questionTitle,
    required final DateTime firstCorrectDate,
    final List<ReviewSchedule> schedules,
    final int completedCount,
    final bool isFullyCompleted,
  }) = _$TimeCapsuleImpl;
  const _TimeCapsule._() : super._();

  factory _TimeCapsule.fromJson(Map<String, dynamic> json) =
      _$TimeCapsuleImpl.fromJson;

  @override
  String get id; // UUID
  @override
  String get questionId; // "stage_3_001_q1"
  @override
  String get stageId; // "stage_3_001"
  @override
  int get questionNumber; // 1-10
  @override
  String get questionTitle; // 問題タイトル
  @override
  DateTime get firstCorrectDate; // 初回正解日時
  @override
  List<ReviewSchedule> get schedules; // 復習スケジュール
  @override
  int get completedCount; // 完了した復習数（0-4）
  @override
  bool get isFullyCompleted;

  /// Create a copy of TimeCapsule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeCapsuleImplCopyWith<_$TimeCapsuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
