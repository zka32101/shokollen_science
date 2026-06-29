import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question_model.dart';
import '../../../data/seeds/sample_questions.dart';
import '../../../data/seeds/stages.dart';

// ─── ポイント定数 ────────────────────────────────────────
const int kPointsPerCorrect   = 10;
const int kBonusAllCorrect    = 50;
const int kBonusStreak        = 20; // 1日連続ログインボーナス（将来）

// ─── クイズ状態 ───────────────────────────────────────────
class QuizState {
  final String stageId;
  final String stageName;
  final List<QuestionModel> questions;
  final int currentIndex;
  final List<int?> selectedAnswers;   // null = 未回答
  final bool isAnswered;              // 現在の問題に回答済みか
  final bool isFinished;              // 全問完了か
  final int streakDays;               // 連続学習日数（仮）

  const QuizState({
    required this.stageId,
    required this.stageName,
    required this.questions,
    required this.currentIndex,
    required this.selectedAnswers,
    required this.isAnswered,
    required this.isFinished,
    this.streakDays = 3,
  });

  QuestionModel get currentQuestion => questions[currentIndex];
  int get totalQuestions => questions.length;

  /// 正解数
  int get correctCount => selectedAnswers.asMap().entries
      .where((e) =>
          e.value != null &&
          e.value == questions[e.key].correctAnswerIndex)
      .length;

  /// 獲得ポイント
  int get earnedPoints {
    final base = correctCount * kPointsPerCorrect;
    final bonus = correctCount == totalQuestions ? kBonusAllCorrect : 0;
    return base + bonus;
  }

  /// 正解率（0.0〜1.0）
  double get accuracy =>
      totalQuestions == 0 ? 0 : correctCount / totalQuestions;

  QuizState copyWith({
    int? currentIndex,
    List<int?>? selectedAnswers,
    bool? isAnswered,
    bool? isFinished,
  }) {
    return QuizState(
      stageId: stageId,
      stageName: stageName,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      isAnswered: isAnswered ?? this.isAnswered,
      isFinished: isFinished ?? this.isFinished,
      streakDays: streakDays,
    );
  }
}

// ─── クイズプロバイダー ────────────────────────────────────
class QuizNotifier extends Notifier<QuizState> {
  @override
  QuizState build() => _buildInitialState('stage_3_001');

  QuizState _buildInitialState(String stageId) {
    // ステージ名を取得
    final stageData = stagesData.firstWhere(
      (s) => s['id'] == stageId,
      orElse: () => {'stageName': '理科クイズ'},
    );

    // 問題データをフィルタリング（最大10問）
    final rawList = sampleQuestionsData
        .where((q) => q['stageId'] == stageId)
        .take(10)
        .toList();

    final questions = rawList.map((q) {
      return QuestionModel(
        id: '${q['stageId']}_${q['questionNumber']}',
        stageId: q['stageId'] as String,
        questionNumber: q['questionNumber'] as int,
        question: q['question'] as String,
        answers: List<String>.from(q['answers'] as List),
        correctAnswerIndex: q['correctAnswerIndex'] as int,
        explanation: q['explanation'] as String,
        timeLimit: q['timeLimit'] as int,
        difficultyLevel: q['difficultyLevel'] as int,
      );
    }).toList();

    return QuizState(
      stageId: stageId,
      stageName: stageData['stageName'] as String,
      questions: questions,
      currentIndex: 0,
      selectedAnswers: List.filled(questions.length, null),
      isAnswered: false,
      isFinished: false,
    );
  }

  /// ステージを変更してクイズをリセット
  void loadStage(String stageId) {
    state = _buildInitialState(stageId);
  }

  /// 選択肢を選ぶ
  void selectAnswer(int answerIndex) {
    if (state.isAnswered) return; // 既に回答済みなら無視

    final updated = List<int?>.from(state.selectedAnswers);
    updated[state.currentIndex] = answerIndex;

    state = state.copyWith(
      selectedAnswers: updated,
      isAnswered: true,
    );
  }

  /// 次の問題へ進む
  void nextQuestion() {
    if (!state.isAnswered) return;

    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.totalQuestions) {
      // 全問終了
      state = state.copyWith(isFinished: true);
    } else {
      state = state.copyWith(
        currentIndex: nextIndex,
        isAnswered: false,
      );
    }
  }

  /// クイズをリトライ（同じステージ）
  void retry() {
    state = _buildInitialState(state.stageId);
  }

  /// まちがえた問題だけリトライ
  void retryWrong() {
    final wrongQuestions = state.questions.asMap().entries
        .where((e) {
          final selected = e.key < state.selectedAnswers.length
              ? state.selectedAnswers[e.key]
              : null;
          return selected != state.questions[e.key].correctAnswerIndex;
        })
        .map((e) => e.value)
        .toList();

    if (wrongQuestions.isEmpty) return;

    state = QuizState(
      stageId: state.stageId,
      stageName: '${state.stageName}（復習）',
      questions: wrongQuestions,
      currentIndex: 0,
      selectedAnswers: List.filled(wrongQuestions.length, null),
      isAnswered: false,
      isFinished: false,
    );
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(
  QuizNotifier.new,
);
