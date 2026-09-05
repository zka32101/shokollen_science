import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shokollen_science/features/progress/data/repositories/review_time_capsule_repository.dart';
import 'package:shokollen_science/features/progress/models/review_schedule.dart';
import 'package:shokollen_science/features/progress/providers/review_time_capsule_provider.dart';

void main() {
  group('ReviewTimeCapsuleNotifier Tests', () {
    late ProviderContainer container;
    late ReviewTimeCapsuleRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ReviewTimeCapsuleRepositoryImpl(prefs);

      container = ProviderContainer(
        overrides: [
          reviewTimeCapsuleRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    test('初期状態は空リスト', () async {
      await Future.delayed(Duration(milliseconds: 100)); // 初期化待ち
      final state = container.read(timeCapsuleProvider);
      expect(state, isEmpty);
    });

    test('createFromQuestion で新しいカプセルを追加できる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(timeCapsuleProvider.notifier);

      await notifier.createFromQuestion(
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: '昆虫のからだのつくり',
      );

      final state = container.read(timeCapsuleProvider);
      expect(state.length, 1);
      expect(state.first.questionId, 'stage_3_001_q1');
      expect(state.first.schedules.length, 4);
    });

    test('同じ questionId では重複して追加しない', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(timeCapsuleProvider.notifier);

      await notifier.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await notifier.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      final state = container.read(timeCapsuleProvider);
      expect(state.length, 1);
    });

    test('複数のカプセルを追加できる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(timeCapsuleProvider.notifier);

      await notifier.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await notifier.createFromQuestion(
        questionId: 'q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        questionTitle: 'Q2',
      );

      final state = container.read(timeCapsuleProvider);
      expect(state.length, 2);
    });

    test('completeReview で復習を完了できる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(timeCapsuleProvider.notifier);

      await notifier.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      final state1 = container.read(timeCapsuleProvider);
      final capsuleId = state1.first.id;

      await notifier.completeReview(capsuleId, ReviewInterval.day1);

      final state2 = container.read(timeCapsuleProvider);
      expect(state2.first.completedCount, 1);
      expect(state2.first.schedules[0].status, ReviewStatus.completed);
    });

    test('4 回復習完了で isFullyCompleted が true になる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(timeCapsuleProvider.notifier);

      await notifier.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      final state1 = container.read(timeCapsuleProvider);
      final capsuleId = state1.first.id;

      // 4 回復習
      await notifier.completeReview(capsuleId, ReviewInterval.day1);
      await notifier.completeReview(capsuleId, ReviewInterval.day3);
      await notifier.completeReview(capsuleId, ReviewInterval.week1);
      await notifier.completeReview(capsuleId, ReviewInterval.month1);

      final state2 = container.read(timeCapsuleProvider);
      expect(state2.first.completedCount, 4);
      expect(state2.first.isFullyCompleted, true);
    });

    test('deleteTimeCapsule でカプセルを削除できる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(timeCapsuleProvider.notifier);

      await notifier.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await notifier.createFromQuestion(
        questionId: 'q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        questionTitle: 'Q2',
      );

      final state1 = container.read(timeCapsuleProvider);
      final firstId = state1.first.id;

      await notifier.deleteTimeCapsule(firstId);

      final state2 = container.read(timeCapsuleProvider);
      expect(state2.length, 1);
      expect(state2.first.id, isNot(firstId));
    });

    test('hasTimeCapsule で存在確認ができる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(timeCapsuleProvider.notifier);

      await notifier.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      expect(await notifier.hasTimeCapsule('q1'), true);
      expect(await notifier.hasTimeCapsule('q99'), false);
    });

    test('getByStageId でステージ別に取得できる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(timeCapsuleProvider.notifier);

      await notifier.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await notifier.createFromQuestion(
        questionId: 'q2',
        stageId: 'stage_3_002',
        questionNumber: 1,
        questionTitle: 'Q2',
      );

      final stage1 = notifier.getByStageId('stage_3_001');
      final stage2 = notifier.getByStageId('stage_3_002');

      expect(stage1.length, 1);
      expect(stage2.length, 1);
    });

    test('pendingReviewCountProvider で待機中の数を返す', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(timeCapsuleProvider.notifier);

      expect(container.read(pendingReviewCountProvider), 0);

      await notifier.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      expect(container.read(pendingReviewCountProvider), 1);

      // 復習を完了してもまだ pending がある
      final state = container.read(timeCapsuleProvider);
      await notifier.completeReview(
        state.first.id,
        ReviewInterval.day1,
      );

      expect(container.read(pendingReviewCountProvider), 1);
    });

    test('completedCapsuleCountProvider で完了済みカプセル数を返す', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(timeCapsuleProvider.notifier);

      await notifier.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      expect(container.read(completedCapsuleCountProvider), 0);

      // すべて完了
      final state = container.read(timeCapsuleProvider);
      final capsuleId = state.first.id;

      await notifier.completeReview(capsuleId, ReviewInterval.day1);
      await notifier.completeReview(capsuleId, ReviewInterval.day3);
      await notifier.completeReview(capsuleId, ReviewInterval.week1);
      await notifier.completeReview(capsuleId, ReviewInterval.month1);

      expect(container.read(completedCapsuleCountProvider), 1);
    });

    test('getTodayReviews で今日の復習を取得できる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(timeCapsuleProvider.notifier);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      await notifier.createFromQuestion(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      // 最初の復習を今日に設定
      final state = container.read(timeCapsuleProvider);
      final capsule = state.first;

      final updatedSchedules = capsule.schedules.map((s) {
        if (s.interval == ReviewInterval.day1) {
          return s.copyWith(nextReviewDate: today);
        }
        return s;
      }).toList();

      final updated = capsule.copyWith(schedules: updatedSchedules);
      await repository.update(updated);

      final todayReviews = await notifier.getTodayReviews();
      expect(todayReviews.length, 1);
      expect(todayReviews.first.questionId, 'q1');
    });
  });
}
