import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shokollen_science/features/progress/data/repositories/review_time_capsule_repository.dart';
import 'package:shokollen_science/features/progress/models/review_schedule.dart';

void main() {
  group('ReviewTimeCapsuleRepository Tests', () {
    late ReviewTimeCapsuleRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getAll で空リストが返される（初期状態）', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      final result = await repository.getAll();

      expect(result, isEmpty);
    });

    test('createFromQuestion で新しいタイムカプセルを作成できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      await repository.createFromQuestion(
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: '昆虫のからだのつくり',
      );

      final all = await repository.getAll();
      expect(all.length, 1);
      expect(all.first.questionId, 'stage_3_001_q1');
      expect(all.first.schedules.length, 4);
    });

    test('同じ questionId では重複して作成しない', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      await repository.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await repository.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      final all = await repository.getAll();
      expect(all.length, 1);
    });

    test('複数のタイムカプセルを作成・取得できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      await repository.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await repository.createFromQuestion(
        questionId: 'q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        questionTitle: 'Q2',
      );

      final all = await repository.getAll();
      expect(all.length, 2);
    });

    test('getById で指定した ID のカプセルを取得できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      await repository.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      final all = await repository.getAll();
      final capsuleId = all.first.id;

      final result = await repository.getById(capsuleId);

      expect(result, isNotNull);
      expect(result!.questionId, 'q1');
    });

    test('getById で存在しない ID は null を返す', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      final result = await repository.getById('nonexistent');

      expect(result, isNull);
    });

    test('getByStageId で特定ステージのカプセルを取得できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      // stage_3_001 に 2 個
      await repository.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await repository.createFromQuestion(
        questionId: 'q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        questionTitle: 'Q2',
      );

      // stage_3_002 に 1 個
      await repository.createFromQuestion(
        questionId: 'q3',
        stageId: 'stage_3_002',
        questionNumber: 1,
        questionTitle: 'Q3',
      );

      final stage1 = await repository.getByStageId('stage_3_001');
      final stage2 = await repository.getByStageId('stage_3_002');

      expect(stage1.length, 2);
      expect(stage2.length, 1);
    });

    test('getTodayReviews で今日の復習を取得できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      await repository.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      // 最初の復習スケジュールを今日に設定
      final all = await repository.getAll();
      final capsule = all.first;

      final updatedSchedules = capsule.schedules.map((s) {
        if (s.interval == ReviewInterval.day1) {
          return s.copyWith(nextReviewDate: today);
        }
        return s;
      }).toList();

      final updated = capsule.copyWith(schedules: updatedSchedules);
      await repository.update(updated);

      final todayReviews = await repository.getTodayReviews();
      expect(todayReviews.length, 1);
      expect(todayReviews.first.questionId, 'q1');
    });

    test('completeReview で復習を完了できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      await repository.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      final all = await repository.getAll();
      final capsuleId = all.first.id;

      // 復習を完了
      await repository.completeReview(capsuleId, ReviewInterval.day1);

      final updated = await repository.getById(capsuleId);
      expect(updated!.completedCount, 1);
      expect(
        updated.schedules[0].status,
        ReviewStatus.completed,
      );
    });

    test('4 回の復習完了で isFullyCompleted が true になる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      await repository.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      final all = await repository.getAll();
      final capsuleId = all.first.id;

      // 4 回の復習を完了
      await repository.completeReview(capsuleId, ReviewInterval.day1);
      await repository.completeReview(capsuleId, ReviewInterval.day3);
      await repository.completeReview(capsuleId, ReviewInterval.week1);
      await repository.completeReview(capsuleId, ReviewInterval.month1);

      final final_ = await repository.getById(capsuleId);
      expect(final_!.completedCount, 4);
      expect(final_.isFullyCompleted, true);
    });

    test('update でカプセルを更新できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      await repository.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      final all = await repository.getAll();
      final original = all.first;

      final updated = original.copyWith(
        completedCount: 2,
      );

      await repository.update(updated);

      final result = await repository.getById(original.id);
      expect(result!.completedCount, 2);
    });

    test('delete でカプセルを削除できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      await repository.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await repository.createFromQuestion(
        questionId: 'q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        questionTitle: 'Q2',
      );

      final all = await repository.getAll();
      final firstId = all.first.id;

      await repository.delete(firstId);

      final remaining = await repository.getAll();
      expect(remaining.length, 1);
      expect(remaining.first.id, isNot(firstId));
    });

    test('deleteAll ですべてのカプセルを削除できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      await repository.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await repository.createFromQuestion(
        questionId: 'q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        questionTitle: 'Q2',
      );

      await repository.deleteAll();

      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('getCount で正しい数を返す', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      expect(await repository.getCount(), 0);

      await repository.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      expect(await repository.getCount(), 1);

      await repository.createFromQuestion(
        questionId: 'q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        questionTitle: 'Q2',
      );

      expect(await repository.getCount(), 2);
    });
  });
}
