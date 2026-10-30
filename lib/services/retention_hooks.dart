import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart'
    show
        answerStreakProvider,
        notificationPlanProvider,
        onboardingProvider,
        retentionTrackerProvider,
        reviewQueueProvider;

import '../features/progress/providers/user_progress_provider.dart'
    show userProgressProvider;
import 'study_reminder_service.dart';

/// `ref.read`（WidgetRef・Ref どちらでも）を渡すための型。
typedef RefRead = T Function<T>(ProviderListenable<T> provider);

/// 定着率施策（shared_core の retention）の保存データを起動時に読み込む。
/// 失敗しても起動は止めない。
Future<void> initRetention(ProviderContainer container) async {
  try {
    await Future.wait([
      container.read(onboardingProvider.notifier).load(),
      container.read(reviewQueueProvider.notifier).load(),
      container.read(notificationPlanProvider.notifier).load(),
      container.read(retentionTrackerProvider.notifier).load(),
    ]);
  } catch (e) {
    debugPrint('[Retention] 初期化スキップ: $e');
  }
}

/// クイズ 1 問に回答したときに呼ぶ。連続正解ボーナス・
/// 間違い復習キュー・学習時間帯の記録をまとめて行う。
///
/// [read] には `ref.read` を渡す（画面でも Notifier でも使える）。
/// read はすべて await より前に行う（画面が閉じた後でも安全）。
/// 週次チャレンジは、このアプリ独自の weekly_challenge 機能があるため使わない。
/// 問題IDは `<stageId>_<questionNumber>`（例: `stage_3_001_1`）。
/// ボーナスコインが付いたら [context] にスナックバーで知らせる。
/// コインは shared_core の coinProvider に加算される（ホーム・ショップの残高と同じ）。
Future<void> onQuizAnswered(
  RefRead read, {
  required String quizId,
  required bool correct,
  BuildContext? context,
}) async {
  try {
    final streak = read(answerStreakProvider.notifier);
    final review = read(reviewQueueProvider.notifier);
    final tracker = read(retentionTrackerProvider.notifier);
    final plan = read(notificationPlanProvider.notifier);
    final messenger =
        context == null ? null : ScaffoldMessenger.maybeOf(context);
    final streakDays = read(userProgressProvider).value?.streakDays ?? 0;

    final bonus = await streak.recordAnswer(correct);
    await review.recordAnswer(quizId, correct, subject: 'rika');
    await tracker.markActiveToday();
    await plan.recordActivity();

    // 学習リマインダーを予約し直す（明日の時点で期限の復習件数を数える）
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await StudyReminderService.instance.reschedule(
      plan: plan,
      streak: streakDays,
      dueReviewTomorrow: review.dueIds(now: tomorrow).length,
    );

    if (messenger != null && bonus > 0) {
      messenger.showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('🔥 連続正解ボーナス +$bonus コイン'),
      ));
    }
  } catch (e) {
    debugPrint('[Retention] 回答記録をスキップ: $e');
  }
}

/// 問題データ（sampleQuestionsData の 1 件）から、復習キュー用の問題IDを作る。
/// QuizNotifier の `QuestionModel.id`（`<stageId>_<questionNumber>`）と同じ形式。
String retentionQuestionId(Map<String, dynamic> q) =>
    '${q['stageId']}_${q['questionNumber']}';

/// 問題データ [q] に [answerIndex] で回答したことを記録する（画面用）。
void recordQuestionAnswer(
  RefRead read,
  Map<String, dynamic> q,
  int answerIndex, {
  BuildContext? context,
}) {
  onQuizAnswered(
    read,
    quizId: retentionQuestionId(q),
    correct: answerIndex == q['correctAnswerIndex'],
    context: context,
  );
}
