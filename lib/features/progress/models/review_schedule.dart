import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_schedule.freezed.dart';
part 'review_schedule.g.dart';

/// 復習のタイミング（Ebbinghaus 忘却曲線ベース）
enum ReviewInterval {
  day1,    // 1日後
  day3,    // 3日後
  week1,   // 1週間後
  month1,  // 1ヶ月後
}

extension ReviewIntervalExt on ReviewInterval {
  String get label => {
    ReviewInterval.day1: '1日後',
    ReviewInterval.day3: '3日後',
    ReviewInterval.week1: '1週間後',
    ReviewInterval.month1: '1ヶ月後',
  }[this]!;

  Duration get duration => {
    ReviewInterval.day1: Duration(days: 1),
    ReviewInterval.day3: Duration(days: 3),
    ReviewInterval.week1: Duration(days: 7),
    ReviewInterval.month1: Duration(days: 30),
  }[this]!;

  /// 復習順序（1-4）
  int get order => {
    ReviewInterval.day1: 1,
    ReviewInterval.day3: 2,
    ReviewInterval.week1: 3,
    ReviewInterval.month1: 4,
  }[this]!;

  /// 復習段階の説明
  String get description => {
    ReviewInterval.day1: '短期記憶の定着',
    ReviewInterval.day3: '記憶の強化',
    ReviewInterval.week1: '長期記憶化',
    ReviewInterval.month1: '完全習熟',
  }[this]!;
}

/// 復習のステータス
enum ReviewStatus {
  pending,    // 復習待機中
  completed,  // 復習完了
  skipped,    // スキップ
}

extension ReviewStatusExt on ReviewStatus {
  String get emoji => {
    ReviewStatus.pending: '⏳',
    ReviewStatus.completed: '✅',
    ReviewStatus.skipped: '⏭️',
  }[this]!;

  String get label => {
    ReviewStatus.pending: '待機中',
    ReviewStatus.completed: '完了',
    ReviewStatus.skipped: 'スキップ',
  }[this]!;
}

/// 1 回の復習スケジュール
@freezed
class ReviewSchedule with _$ReviewSchedule {
  const factory ReviewSchedule({
    required ReviewInterval interval,
    required DateTime nextReviewDate,
    @Default(ReviewStatus.pending) ReviewStatus status,
    DateTime? completedAt,
  }) = _ReviewSchedule;

  const ReviewSchedule._();

  /// 復習が今日実施可能か
  bool isReviewDueToday() {
    if (status != ReviewStatus.pending) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      nextReviewDate.year,
      nextReviewDate.month,
      nextReviewDate.day,
    );

    return dueDate.isBefore(today) || dueDate.isAtSameMomentAs(today);
  }

  /// 復習が期限切れか（今日より後）
  bool isOverdue() {
    if (status != ReviewStatus.pending) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      nextReviewDate.year,
      nextReviewDate.month,
      nextReviewDate.day,
    );

    return dueDate.isBefore(today);
  }

  factory ReviewSchedule.fromJson(Map<String, dynamic> json) =>
      _$ReviewScheduleFromJson(json);
}

/// 復習タイムカプセル（正解した問題を管理）
@freezed
class TimeCapsule with _$TimeCapsule {
  const factory TimeCapsule({
    required String id,                    // UUID
    required String questionId,            // "stage_3_001_q1"
    required String stageId,               // "stage_3_001"
    required int questionNumber,           // 1-10
    required String questionTitle,         // 問題タイトル
    required DateTime firstCorrectDate,    // 初回正解日時
    @Default([]) List<ReviewSchedule> schedules, // 復習スケジュール
    @Default(0) int completedCount,       // 完了した復習数（0-4）
    @Default(false) bool isFullyCompleted, // すべての復習を完了したか
  }) = _TimeCapsule;

  const TimeCapsule._();

  /// 次の復習を取得
  ReviewSchedule? getNextReview() {
    try {
      return schedules.firstWhere(
        (s) => s.status == ReviewStatus.pending,
      );
    } catch (e) {
      return null;
    }
  }

  /// 復習が今日実施可能か
  bool hasReviewDueToday() {
    final next = getNextReview();
    return next != null && next.isReviewDueToday();
  }

  /// 進行状況（0.0-1.0）
  double get progressPercent {
    if (schedules.isEmpty) return 0.0;
    return completedCount / 4.0;
  }

  /// 進行状況のパーセンテージ（0-100）
  int get progressPercentInt => (progressPercent * 100).toInt();

  /// すべての復習が完了したか
  bool get isCompleted {
    return schedules.every((s) => s.status == ReviewStatus.completed);
  }

  factory TimeCapsule.fromJson(Map<String, dynamic> json) =>
      _$TimeCapsuleFromJson(json);
}

/// TimeCapsule 作成時のヘルパー
TimeCapsule createNewTimeCapsule({
  required String id,
  required String questionId,
  required String stageId,
  required int questionNumber,
  required String questionTitle,
  DateTime? firstCorrectDate,
}) {
  final now = firstCorrectDate ?? DateTime.now();

  // 4段階の復習スケジュールを作成
  final schedules = [
    ReviewSchedule(
      interval: ReviewInterval.day1,
      nextReviewDate: now.add(Duration(days: 1)),
    ),
    ReviewSchedule(
      interval: ReviewInterval.day3,
      nextReviewDate: now.add(Duration(days: 3)),
    ),
    ReviewSchedule(
      interval: ReviewInterval.week1,
      nextReviewDate: now.add(Duration(days: 7)),
    ),
    ReviewSchedule(
      interval: ReviewInterval.month1,
      nextReviewDate: now.add(Duration(days: 30)),
    ),
  ];

  return TimeCapsule(
    id: id,
    questionId: questionId,
    stageId: stageId,
    questionNumber: questionNumber,
    questionTitle: questionTitle,
    firstCorrectDate: now,
    schedules: schedules,
  );
}
