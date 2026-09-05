// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyStats _$DailyStatsFromJson(Map<String, dynamic> json) {
  return _DailyStats.fromJson(json);
}

/// @nodoc
mixin _$DailyStats {
  String get date => throw _privateConstructorUsedError; // YYYY-MM-DD
  int get questsCompleted => throw _privateConstructorUsedError;
  int get correctAnswers => throw _privateConstructorUsedError;
  int get totalAnswers => throw _privateConstructorUsedError;
  int get coinsEarned => throw _privateConstructorUsedError;
  int get studyMinutes => throw _privateConstructorUsedError;
  Map<String, dynamic> get categoryStats => throw _privateConstructorUsedError;

  /// Serializes this DailyStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyStatsCopyWith<DailyStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyStatsCopyWith<$Res> {
  factory $DailyStatsCopyWith(
    DailyStats value,
    $Res Function(DailyStats) then,
  ) = _$DailyStatsCopyWithImpl<$Res, DailyStats>;
  @useResult
  $Res call({
    String date,
    int questsCompleted,
    int correctAnswers,
    int totalAnswers,
    int coinsEarned,
    int studyMinutes,
    Map<String, dynamic> categoryStats,
  });
}

/// @nodoc
class _$DailyStatsCopyWithImpl<$Res, $Val extends DailyStats>
    implements $DailyStatsCopyWith<$Res> {
  _$DailyStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? questsCompleted = null,
    Object? correctAnswers = null,
    Object? totalAnswers = null,
    Object? coinsEarned = null,
    Object? studyMinutes = null,
    Object? categoryStats = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            questsCompleted: null == questsCompleted
                ? _value.questsCompleted
                : questsCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            correctAnswers: null == correctAnswers
                ? _value.correctAnswers
                : correctAnswers // ignore: cast_nullable_to_non_nullable
                      as int,
            totalAnswers: null == totalAnswers
                ? _value.totalAnswers
                : totalAnswers // ignore: cast_nullable_to_non_nullable
                      as int,
            coinsEarned: null == coinsEarned
                ? _value.coinsEarned
                : coinsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
            studyMinutes: null == studyMinutes
                ? _value.studyMinutes
                : studyMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryStats: null == categoryStats
                ? _value.categoryStats
                : categoryStats // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyStatsImplCopyWith<$Res>
    implements $DailyStatsCopyWith<$Res> {
  factory _$$DailyStatsImplCopyWith(
    _$DailyStatsImpl value,
    $Res Function(_$DailyStatsImpl) then,
  ) = __$$DailyStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    int questsCompleted,
    int correctAnswers,
    int totalAnswers,
    int coinsEarned,
    int studyMinutes,
    Map<String, dynamic> categoryStats,
  });
}

/// @nodoc
class __$$DailyStatsImplCopyWithImpl<$Res>
    extends _$DailyStatsCopyWithImpl<$Res, _$DailyStatsImpl>
    implements _$$DailyStatsImplCopyWith<$Res> {
  __$$DailyStatsImplCopyWithImpl(
    _$DailyStatsImpl _value,
    $Res Function(_$DailyStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? questsCompleted = null,
    Object? correctAnswers = null,
    Object? totalAnswers = null,
    Object? coinsEarned = null,
    Object? studyMinutes = null,
    Object? categoryStats = null,
  }) {
    return _then(
      _$DailyStatsImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        questsCompleted: null == questsCompleted
            ? _value.questsCompleted
            : questsCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        correctAnswers: null == correctAnswers
            ? _value.correctAnswers
            : correctAnswers // ignore: cast_nullable_to_non_nullable
                  as int,
        totalAnswers: null == totalAnswers
            ? _value.totalAnswers
            : totalAnswers // ignore: cast_nullable_to_non_nullable
                  as int,
        coinsEarned: null == coinsEarned
            ? _value.coinsEarned
            : coinsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
        studyMinutes: null == studyMinutes
            ? _value.studyMinutes
            : studyMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryStats: null == categoryStats
            ? _value._categoryStats
            : categoryStats // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyStatsImpl implements _DailyStats {
  const _$DailyStatsImpl({
    required this.date,
    required this.questsCompleted,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.coinsEarned,
    required this.studyMinutes,
    required final Map<String, dynamic> categoryStats,
  }) : _categoryStats = categoryStats;

  factory _$DailyStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyStatsImplFromJson(json);

  @override
  final String date;
  // YYYY-MM-DD
  @override
  final int questsCompleted;
  @override
  final int correctAnswers;
  @override
  final int totalAnswers;
  @override
  final int coinsEarned;
  @override
  final int studyMinutes;
  final Map<String, dynamic> _categoryStats;
  @override
  Map<String, dynamic> get categoryStats {
    if (_categoryStats is EqualUnmodifiableMapView) return _categoryStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryStats);
  }

  @override
  String toString() {
    return 'DailyStats(date: $date, questsCompleted: $questsCompleted, correctAnswers: $correctAnswers, totalAnswers: $totalAnswers, coinsEarned: $coinsEarned, studyMinutes: $studyMinutes, categoryStats: $categoryStats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyStatsImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.questsCompleted, questsCompleted) ||
                other.questsCompleted == questsCompleted) &&
            (identical(other.correctAnswers, correctAnswers) ||
                other.correctAnswers == correctAnswers) &&
            (identical(other.totalAnswers, totalAnswers) ||
                other.totalAnswers == totalAnswers) &&
            (identical(other.coinsEarned, coinsEarned) ||
                other.coinsEarned == coinsEarned) &&
            (identical(other.studyMinutes, studyMinutes) ||
                other.studyMinutes == studyMinutes) &&
            const DeepCollectionEquality().equals(
              other._categoryStats,
              _categoryStats,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    questsCompleted,
    correctAnswers,
    totalAnswers,
    coinsEarned,
    studyMinutes,
    const DeepCollectionEquality().hash(_categoryStats),
  );

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyStatsImplCopyWith<_$DailyStatsImpl> get copyWith =>
      __$$DailyStatsImplCopyWithImpl<_$DailyStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyStatsImplToJson(this);
  }
}

abstract class _DailyStats implements DailyStats {
  const factory _DailyStats({
    required final String date,
    required final int questsCompleted,
    required final int correctAnswers,
    required final int totalAnswers,
    required final int coinsEarned,
    required final int studyMinutes,
    required final Map<String, dynamic> categoryStats,
  }) = _$DailyStatsImpl;

  factory _DailyStats.fromJson(Map<String, dynamic> json) =
      _$DailyStatsImpl.fromJson;

  @override
  String get date; // YYYY-MM-DD
  @override
  int get questsCompleted;
  @override
  int get correctAnswers;
  @override
  int get totalAnswers;
  @override
  int get coinsEarned;
  @override
  int get studyMinutes;
  @override
  Map<String, dynamic> get categoryStats;

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyStatsImplCopyWith<_$DailyStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MonthlyStats _$MonthlyStatsFromJson(Map<String, dynamic> json) {
  return _MonthlyStats.fromJson(json);
}

/// @nodoc
mixin _$MonthlyStats {
  String get month => throw _privateConstructorUsedError; // YYYY-MM
  int get totalQuestsCompleted => throw _privateConstructorUsedError;
  int get totalCorrectAnswers => throw _privateConstructorUsedError;
  int get totalAnswers => throw _privateConstructorUsedError;
  double get accuracyRate => throw _privateConstructorUsedError; // 0.0 ~ 1.0
  int get totalStudyMinutes => throw _privateConstructorUsedError;
  int get totalCoinsEarned => throw _privateConstructorUsedError;
  int get studyDaysCount => throw _privateConstructorUsedError; // 学習した日数
  Map<String, dynamic> get categoryStats => throw _privateConstructorUsedError;

  /// Serializes this MonthlyStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyStatsCopyWith<MonthlyStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyStatsCopyWith<$Res> {
  factory $MonthlyStatsCopyWith(
    MonthlyStats value,
    $Res Function(MonthlyStats) then,
  ) = _$MonthlyStatsCopyWithImpl<$Res, MonthlyStats>;
  @useResult
  $Res call({
    String month,
    int totalQuestsCompleted,
    int totalCorrectAnswers,
    int totalAnswers,
    double accuracyRate,
    int totalStudyMinutes,
    int totalCoinsEarned,
    int studyDaysCount,
    Map<String, dynamic> categoryStats,
  });
}

/// @nodoc
class _$MonthlyStatsCopyWithImpl<$Res, $Val extends MonthlyStats>
    implements $MonthlyStatsCopyWith<$Res> {
  _$MonthlyStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? totalQuestsCompleted = null,
    Object? totalCorrectAnswers = null,
    Object? totalAnswers = null,
    Object? accuracyRate = null,
    Object? totalStudyMinutes = null,
    Object? totalCoinsEarned = null,
    Object? studyDaysCount = null,
    Object? categoryStats = null,
  }) {
    return _then(
      _value.copyWith(
            month: null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                      as String,
            totalQuestsCompleted: null == totalQuestsCompleted
                ? _value.totalQuestsCompleted
                : totalQuestsCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCorrectAnswers: null == totalCorrectAnswers
                ? _value.totalCorrectAnswers
                : totalCorrectAnswers // ignore: cast_nullable_to_non_nullable
                      as int,
            totalAnswers: null == totalAnswers
                ? _value.totalAnswers
                : totalAnswers // ignore: cast_nullable_to_non_nullable
                      as int,
            accuracyRate: null == accuracyRate
                ? _value.accuracyRate
                : accuracyRate // ignore: cast_nullable_to_non_nullable
                      as double,
            totalStudyMinutes: null == totalStudyMinutes
                ? _value.totalStudyMinutes
                : totalStudyMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCoinsEarned: null == totalCoinsEarned
                ? _value.totalCoinsEarned
                : totalCoinsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
            studyDaysCount: null == studyDaysCount
                ? _value.studyDaysCount
                : studyDaysCount // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryStats: null == categoryStats
                ? _value.categoryStats
                : categoryStats // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthlyStatsImplCopyWith<$Res>
    implements $MonthlyStatsCopyWith<$Res> {
  factory _$$MonthlyStatsImplCopyWith(
    _$MonthlyStatsImpl value,
    $Res Function(_$MonthlyStatsImpl) then,
  ) = __$$MonthlyStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String month,
    int totalQuestsCompleted,
    int totalCorrectAnswers,
    int totalAnswers,
    double accuracyRate,
    int totalStudyMinutes,
    int totalCoinsEarned,
    int studyDaysCount,
    Map<String, dynamic> categoryStats,
  });
}

/// @nodoc
class __$$MonthlyStatsImplCopyWithImpl<$Res>
    extends _$MonthlyStatsCopyWithImpl<$Res, _$MonthlyStatsImpl>
    implements _$$MonthlyStatsImplCopyWith<$Res> {
  __$$MonthlyStatsImplCopyWithImpl(
    _$MonthlyStatsImpl _value,
    $Res Function(_$MonthlyStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? totalQuestsCompleted = null,
    Object? totalCorrectAnswers = null,
    Object? totalAnswers = null,
    Object? accuracyRate = null,
    Object? totalStudyMinutes = null,
    Object? totalCoinsEarned = null,
    Object? studyDaysCount = null,
    Object? categoryStats = null,
  }) {
    return _then(
      _$MonthlyStatsImpl(
        month: null == month
            ? _value.month
            : month // ignore: cast_nullable_to_non_nullable
                  as String,
        totalQuestsCompleted: null == totalQuestsCompleted
            ? _value.totalQuestsCompleted
            : totalQuestsCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCorrectAnswers: null == totalCorrectAnswers
            ? _value.totalCorrectAnswers
            : totalCorrectAnswers // ignore: cast_nullable_to_non_nullable
                  as int,
        totalAnswers: null == totalAnswers
            ? _value.totalAnswers
            : totalAnswers // ignore: cast_nullable_to_non_nullable
                  as int,
        accuracyRate: null == accuracyRate
            ? _value.accuracyRate
            : accuracyRate // ignore: cast_nullable_to_non_nullable
                  as double,
        totalStudyMinutes: null == totalStudyMinutes
            ? _value.totalStudyMinutes
            : totalStudyMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCoinsEarned: null == totalCoinsEarned
            ? _value.totalCoinsEarned
            : totalCoinsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
        studyDaysCount: null == studyDaysCount
            ? _value.studyDaysCount
            : studyDaysCount // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryStats: null == categoryStats
            ? _value._categoryStats
            : categoryStats // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyStatsImpl extends _MonthlyStats {
  const _$MonthlyStatsImpl({
    required this.month,
    required this.totalQuestsCompleted,
    required this.totalCorrectAnswers,
    required this.totalAnswers,
    required this.accuracyRate,
    required this.totalStudyMinutes,
    required this.totalCoinsEarned,
    required this.studyDaysCount,
    required final Map<String, dynamic> categoryStats,
  }) : _categoryStats = categoryStats,
       super._();

  factory _$MonthlyStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyStatsImplFromJson(json);

  @override
  final String month;
  // YYYY-MM
  @override
  final int totalQuestsCompleted;
  @override
  final int totalCorrectAnswers;
  @override
  final int totalAnswers;
  @override
  final double accuracyRate;
  // 0.0 ~ 1.0
  @override
  final int totalStudyMinutes;
  @override
  final int totalCoinsEarned;
  @override
  final int studyDaysCount;
  // 学習した日数
  final Map<String, dynamic> _categoryStats;
  // 学習した日数
  @override
  Map<String, dynamic> get categoryStats {
    if (_categoryStats is EqualUnmodifiableMapView) return _categoryStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryStats);
  }

  @override
  String toString() {
    return 'MonthlyStats(month: $month, totalQuestsCompleted: $totalQuestsCompleted, totalCorrectAnswers: $totalCorrectAnswers, totalAnswers: $totalAnswers, accuracyRate: $accuracyRate, totalStudyMinutes: $totalStudyMinutes, totalCoinsEarned: $totalCoinsEarned, studyDaysCount: $studyDaysCount, categoryStats: $categoryStats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyStatsImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.totalQuestsCompleted, totalQuestsCompleted) ||
                other.totalQuestsCompleted == totalQuestsCompleted) &&
            (identical(other.totalCorrectAnswers, totalCorrectAnswers) ||
                other.totalCorrectAnswers == totalCorrectAnswers) &&
            (identical(other.totalAnswers, totalAnswers) ||
                other.totalAnswers == totalAnswers) &&
            (identical(other.accuracyRate, accuracyRate) ||
                other.accuracyRate == accuracyRate) &&
            (identical(other.totalStudyMinutes, totalStudyMinutes) ||
                other.totalStudyMinutes == totalStudyMinutes) &&
            (identical(other.totalCoinsEarned, totalCoinsEarned) ||
                other.totalCoinsEarned == totalCoinsEarned) &&
            (identical(other.studyDaysCount, studyDaysCount) ||
                other.studyDaysCount == studyDaysCount) &&
            const DeepCollectionEquality().equals(
              other._categoryStats,
              _categoryStats,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    month,
    totalQuestsCompleted,
    totalCorrectAnswers,
    totalAnswers,
    accuracyRate,
    totalStudyMinutes,
    totalCoinsEarned,
    studyDaysCount,
    const DeepCollectionEquality().hash(_categoryStats),
  );

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyStatsImplCopyWith<_$MonthlyStatsImpl> get copyWith =>
      __$$MonthlyStatsImplCopyWithImpl<_$MonthlyStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyStatsImplToJson(this);
  }
}

abstract class _MonthlyStats extends MonthlyStats {
  const factory _MonthlyStats({
    required final String month,
    required final int totalQuestsCompleted,
    required final int totalCorrectAnswers,
    required final int totalAnswers,
    required final double accuracyRate,
    required final int totalStudyMinutes,
    required final int totalCoinsEarned,
    required final int studyDaysCount,
    required final Map<String, dynamic> categoryStats,
  }) = _$MonthlyStatsImpl;
  const _MonthlyStats._() : super._();

  factory _MonthlyStats.fromJson(Map<String, dynamic> json) =
      _$MonthlyStatsImpl.fromJson;

  @override
  String get month; // YYYY-MM
  @override
  int get totalQuestsCompleted;
  @override
  int get totalCorrectAnswers;
  @override
  int get totalAnswers;
  @override
  double get accuracyRate; // 0.0 ~ 1.0
  @override
  int get totalStudyMinutes;
  @override
  int get totalCoinsEarned;
  @override
  int get studyDaysCount; // 学習した日数
  @override
  Map<String, dynamic> get categoryStats;

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyStatsImplCopyWith<_$MonthlyStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
