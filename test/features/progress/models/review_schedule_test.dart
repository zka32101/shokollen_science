import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/features/progress/models/review_schedule.dart';

void main() {
  group('ReviewSchedule Model Tests', () {
    // ────────────────────────────────────────
    // ReviewInterval Extension テスト
    // ────────────────────────────────────────

    test('ReviewInterval.day1 の duration は 1 日', () {
      expect(
        ReviewInterval.day1.duration,
        Duration(days: 1),
      );
    });

    test('ReviewInterval.day3 の duration は 3 日', () {
      expect(
        ReviewInterval.day3.duration,
        Duration(days: 3),
      );
    });

    test('ReviewInterval.week1 の duration は 7 日', () {
      expect(
        ReviewInterval.week1.duration,
        Duration(days: 7),
      );
    });

    test('ReviewInterval.month1 の duration は 30 日', () {
      expect(
        ReviewInterval.month1.duration,
        Duration(days: 30),
      );
    });

    test('ReviewInterval.label が正しい文字列を返す', () {
      expect(ReviewInterval.day1.label, '1日後');
      expect(ReviewInterval.day3.label, '3日後');
      expect(ReviewInterval.week1.label, '1週間後');
      expect(ReviewInterval.month1.label, '1ヶ月後');
    });

    test('ReviewInterval.order が正しい順序を返す', () {
      expect(ReviewInterval.day1.order, 1);
      expect(ReviewInterval.day3.order, 2);
      expect(ReviewInterval.week1.order, 3);
      expect(ReviewInterval.month1.order, 4);
    });

    test('ReviewInterval.description が正しい説明を返す', () {
      expect(ReviewInterval.day1.description, '短期記憶の定着');
      expect(ReviewInterval.day3.description, '記憶の強化');
      expect(ReviewInterval.week1.description, '長期記憶化');
      expect(ReviewInterval.month1.description, '完全習熟');
    });

    // ────────────────────────────────────────
    // ReviewStatus Extension テスト
    // ────────────────────────────────────────

    test('ReviewStatus.emoji が正しい絵文字を返す', () {
      expect(ReviewStatus.pending.emoji, '⏳');
      expect(ReviewStatus.completed.emoji, '✅');
      expect(ReviewStatus.skipped.emoji, '⏭️');
    });

    test('ReviewStatus.label が正しいラベルを返す', () {
      expect(ReviewStatus.pending.label, '待機中');
      expect(ReviewStatus.completed.label, '完了');
      expect(ReviewStatus.skipped.label, 'スキップ');
    });

    // ────────────────────────────────────────
    // ReviewSchedule 基本テスト
    // ────────────────────────────────────────

    test('ReviewSchedule は正しく生成される', () {
      final now = DateTime.now();
      final schedule = ReviewSchedule(
        interval: ReviewInterval.day1,
        nextReviewDate: now.add(Duration(days: 1)),
        status: ReviewStatus.pending,
      );

      expect(schedule.interval, ReviewInterval.day1);
      expect(schedule.status, ReviewStatus.pending);
      expect(schedule.completedAt, isNull);
    });

    // ────────────────────────────────────────
    // isReviewDueToday テスト
    // ────────────────────────────────────────

    test('isReviewDueToday は今日が復習日の場合 true', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final schedule = ReviewSchedule(
        interval: ReviewInterval.day1,
        nextReviewDate: today,
        status: ReviewStatus.pending,
      );

      expect(schedule.isReviewDueToday(), true);
    });

    test('isReviewDueToday は昨日の復習は true（期限切れ）', () {
      final now = DateTime.now();
      final yesterday =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: 1));

      final schedule = ReviewSchedule(
        interval: ReviewInterval.day1,
        nextReviewDate: yesterday,
        status: ReviewStatus.pending,
      );

      expect(schedule.isReviewDueToday(), true);
    });

    test('isReviewDueToday は明日の復習は false', () {
      final now = DateTime.now();
      final tomorrow =
          DateTime(now.year, now.month, now.day).add(Duration(days: 1));

      final schedule = ReviewSchedule(
        interval: ReviewInterval.day1,
        nextReviewDate: tomorrow,
        status: ReviewStatus.pending,
      );

      expect(schedule.isReviewDueToday(), false);
    });

    test('isReviewDueToday は completed 状態では false', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final schedule = ReviewSchedule(
        interval: ReviewInterval.day1,
        nextReviewDate: today,
        status: ReviewStatus.completed,
      );

      expect(schedule.isReviewDueToday(), false);
    });

    // ────────────────────────────────────────
    // isOverdue テスト
    // ────────────────────────────────────────

    test('isOverdue は昨日の復習で true', () {
      final now = DateTime.now();
      final yesterday =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: 1));

      final schedule = ReviewSchedule(
        interval: ReviewInterval.day1,
        nextReviewDate: yesterday,
        status: ReviewStatus.pending,
      );

      expect(schedule.isOverdue(), true);
    });

    test('isOverdue は今日の復習で false', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final schedule = ReviewSchedule(
        interval: ReviewInterval.day1,
        nextReviewDate: today,
        status: ReviewStatus.pending,
      );

      expect(schedule.isOverdue(), false);
    });

    test('isOverdue は明日の復習で false', () {
      final now = DateTime.now();
      final tomorrow =
          DateTime(now.year, now.month, now.day).add(Duration(days: 1));

      final schedule = ReviewSchedule(
        interval: ReviewInterval.day1,
        nextReviewDate: tomorrow,
        status: ReviewStatus.pending,
      );

      expect(schedule.isOverdue(), false);
    });

    test('isOverdue は completed 状態では false', () {
      final now = DateTime.now();
      final yesterday =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: 1));

      final schedule = ReviewSchedule(
        interval: ReviewInterval.day1,
        nextReviewDate: yesterday,
        status: ReviewStatus.completed,
      );

      expect(schedule.isOverdue(), false);
    });

    // ────────────────────────────────────────
    // copyWith テスト
    // ────────────────────────────────────────

    test('copyWith で status を更新できる', () {
      final schedule = ReviewSchedule(
        interval: ReviewInterval.day1,
        nextReviewDate: DateTime.now(),
        status: ReviewStatus.pending,
      );

      final updated = schedule.copyWith(
        status: ReviewStatus.completed,
        completedAt: DateTime.now(),
      );

      expect(schedule.status, ReviewStatus.pending);
      expect(updated.status, ReviewStatus.completed);
      expect(updated.completedAt, isNotNull);
    });

    // ────────────────────────────────────────
    // JSON シリアライゼーション
    // ────────────────────────────────────────

    test('ReviewSchedule をラウンドトリップできる', () {
      final original = ReviewSchedule(
        interval: ReviewInterval.week1,
        nextReviewDate: DateTime(2026, 7, 9, 10, 30),
        status: ReviewStatus.pending,
      );

      final json = original.toJson();
      final restored = ReviewSchedule.fromJson(json);

      expect(restored.interval, original.interval);
      expect(restored.nextReviewDate, original.nextReviewDate);
      expect(restored.status, original.status);
    });
  });

  group('TimeCapsule Model Tests', () {
    // ────────────────────────────────────────
    // 基本生成テスト
    // ────────────────────────────────────────

    test('TimeCapsule は正しく生成される', () {
      final now = DateTime.now();
      final capsule = TimeCapsule(
        id: 'test-1',
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: '昆虫のからだのつくり',
        firstCorrectDate: now,
      );

      expect(capsule.id, 'test-1');
      expect(capsule.questionId, 'stage_3_001_q1');
      expect(capsule.schedules, isEmpty);
      expect(capsule.completedCount, 0);
      expect(capsule.isFullyCompleted, false);
    });

    // ────────────────────────────────────────
    // getNextReview テスト
    // ────────────────────────────────────────

    test('getNextReview は最初の pending を返す', () {
      final now = DateTime.now();
      final schedules = [
        ReviewSchedule(
          interval: ReviewInterval.day1,
          nextReviewDate: now.add(Duration(days: 1)),
          status: ReviewStatus.pending,
        ),
        ReviewSchedule(
          interval: ReviewInterval.day3,
          nextReviewDate: now.add(Duration(days: 3)),
          status: ReviewStatus.pending,
        ),
      ];

      final capsule = TimeCapsule(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Test',
        firstCorrectDate: now,
        schedules: schedules,
      );

      final next = capsule.getNextReview();
      expect(next, isNotNull);
      expect(next!.interval, ReviewInterval.day1);
    });

    test('getNextReview は pending がない場合 null を返す', () {
      final now = DateTime.now();
      final schedules = [
        ReviewSchedule(
          interval: ReviewInterval.day1,
          nextReviewDate: now.add(Duration(days: 1)),
          status: ReviewStatus.completed,
        ),
      ];

      final capsule = TimeCapsule(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Test',
        firstCorrectDate: now,
        schedules: schedules,
      );

      expect(capsule.getNextReview(), isNull);
    });

    // ────────────────────────────────────────
    // hasReviewDueToday テスト
    // ────────────────────────────────────────

    test('hasReviewDueToday は今日の復習がある場合 true', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final schedules = [
        ReviewSchedule(
          interval: ReviewInterval.day1,
          nextReviewDate: today,
          status: ReviewStatus.pending,
        ),
      ];

      final capsule = TimeCapsule(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Test',
        firstCorrectDate: now,
        schedules: schedules,
      );

      expect(capsule.hasReviewDueToday(), true);
    });

    test('hasReviewDueToday は明日の復習では false', () {
      final now = DateTime.now();
      final tomorrow =
          DateTime(now.year, now.month, now.day).add(Duration(days: 1));

      final schedules = [
        ReviewSchedule(
          interval: ReviewInterval.day1,
          nextReviewDate: tomorrow,
          status: ReviewStatus.pending,
        ),
      ];

      final capsule = TimeCapsule(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Test',
        firstCorrectDate: now,
        schedules: schedules,
      );

      expect(capsule.hasReviewDueToday(), false);
    });

    // ────────────────────────────────────────
    // progressPercent テスト
    // ────────────────────────────────────────

    test('progressPercent は completedCount に基づいて計算される', () {
      final now = DateTime.now();
      final testCases = [
        (0, 0.0),
        (1, 0.25),
        (2, 0.5),
        (3, 0.75),
        (4, 1.0),
      ];

      for (final (count, expected) in testCases) {
        final capsule = TimeCapsule(
          id: 'test-$count',
          questionId: 'q1',
          stageId: 'stage_3_001',
          questionNumber: 1,
          questionTitle: 'Test',
          firstCorrectDate: now,
          completedCount: count,
        );

        expect(
          capsule.progressPercent,
          expected,
          reason: 'count=$count',
        );
      }
    });

    test('progressPercentInt は整数パーセンテージを返す', () {
      final now = DateTime.now();
      final capsule = TimeCapsule(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Test',
        firstCorrectDate: now,
        completedCount: 2,
      );

      expect(capsule.progressPercentInt, 50);
    });

    // ────────────────────────────────────────
    // isCompleted テスト
    // ────────────────────────────────────────

    test('isCompleted はすべてのスケジュールが completed で true', () {
      final now = DateTime.now();
      final schedules = [
        ReviewSchedule(
          interval: ReviewInterval.day1,
          nextReviewDate: now.add(Duration(days: 1)),
          status: ReviewStatus.completed,
        ),
        ReviewSchedule(
          interval: ReviewInterval.day3,
          nextReviewDate: now.add(Duration(days: 3)),
          status: ReviewStatus.completed,
        ),
      ];

      final capsule = TimeCapsule(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Test',
        firstCorrectDate: now,
        schedules: schedules,
      );

      expect(capsule.isCompleted, true);
    });

    test('isCompleted は 1 つでも pending があれば false', () {
      final now = DateTime.now();
      final schedules = [
        ReviewSchedule(
          interval: ReviewInterval.day1,
          nextReviewDate: now.add(Duration(days: 1)),
          status: ReviewStatus.completed,
        ),
        ReviewSchedule(
          interval: ReviewInterval.day3,
          nextReviewDate: now.add(Duration(days: 3)),
          status: ReviewStatus.pending,
        ),
      ];

      final capsule = TimeCapsule(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Test',
        firstCorrectDate: now,
        schedules: schedules,
      );

      expect(capsule.isCompleted, false);
    });

    // ────────────────────────────────────────
    // JSON シリアライゼーション
    // ────────────────────────────────────────

    test('TimeCapsule をラウンドトリップできる', () {
      final now = DateTime(2026, 7, 2, 10, 30);
      final schedules = [
        ReviewSchedule(
          interval: ReviewInterval.day1,
          nextReviewDate: now.add(Duration(days: 1)),
          status: ReviewStatus.pending,
        ),
      ];

      final original = TimeCapsule(
        id: 'test-1',
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Test Question',
        firstCorrectDate: now,
        schedules: schedules,
        completedCount: 1,
      );

      final json = original.toJson();
      final restored = TimeCapsule.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.questionId, original.questionId);
      expect(restored.stageId, original.stageId);
      expect(restored.questionNumber, original.questionNumber);
      expect(restored.questionTitle, original.questionTitle);
      expect(restored.completedCount, original.completedCount);
      expect(restored.schedules.length, original.schedules.length);
    });
  });

  group('createNewTimeCapsule Helper Tests', () {
    test('createNewTimeCapsule は 4 段階のスケジュールを生成する', () {
      final capsule = createNewTimeCapsule(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Test',
      );

      expect(capsule.schedules.length, 4);
      expect(capsule.schedules[0].interval, ReviewInterval.day1);
      expect(capsule.schedules[1].interval, ReviewInterval.day3);
      expect(capsule.schedules[2].interval, ReviewInterval.week1);
      expect(capsule.schedules[3].interval, ReviewInterval.month1);
    });

    test('createNewTimeCapsule のスケジュール日付が正しく計算される', () {
      final now = DateTime(2026, 7, 2, 10, 30);
      final capsule = createNewTimeCapsule(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Test',
        firstCorrectDate: now,
      );

      expect(
        capsule.schedules[0].nextReviewDate,
        DateTime(2026, 7, 3, 10, 30),
      );
      expect(
        capsule.schedules[1].nextReviewDate,
        DateTime(2026, 7, 5, 10, 30),
      );
      expect(
        capsule.schedules[2].nextReviewDate,
        DateTime(2026, 7, 9, 10, 30),
      );
      expect(
        capsule.schedules[3].nextReviewDate,
        DateTime(2026, 8, 1, 10, 30),
      );
    });
  });
}
