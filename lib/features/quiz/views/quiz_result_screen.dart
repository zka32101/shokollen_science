import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../providers/quiz_provider.dart';
import '../../progress/providers/user_progress_provider.dart';
import '../../progress/views/badge_earned_dialog.dart';
import '../../parent/providers/praise_provider.dart';
import '../../../data/seeds/explanations/explanations_index.dart';
import '../../progress/models/incorrect_monster.dart';
import '../../progress/providers/incorrect_monster_provider.dart';
import '../../progress/views/widgets/monster_dialogs.dart';
import '../../progress/providers/review_time_capsule_provider.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  const QuizResultScreen({super.key});

  @override
  ConsumerState<QuizResultScreen> createState() =>
      _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  bool _saved = false;
  int _coinsEarned = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveProgress());
  }

  Future<void> _saveProgress() async {
    if (_saved || !mounted) return;
    _saved = true;

    final quiz = ref.read(quizProvider);

    // 間違えた問題のリストを取得
    final wrongAnswers = quiz.questions.asMap().entries
        .where((e) =>
            e.key < quiz.selectedAnswers.length &&
            quiz.selectedAnswers[e.key] != null &&
            quiz.selectedAnswers[e.key] != quiz.questions[e.key].correctAnswerIndex)
        .toList();

    final wrongNums = wrongAnswers.map((e) => e.key + 1).toList();

    // 🎯 NEW: 間違えた問題をモンスター化 & 正解した問題をチェックして進化判定
    final monsterNotifier = ref.read(incorrectMonstersProvider.notifier);
    final evolvedMonsters = <IncorrectMonster>[];
    final newlyCreatedQuestionIds = <String>[];

    for (final entry in wrongAnswers) {
      final questionIndex = entry.key;
      final question = quiz.questions[questionIndex];
      final questionNumber = questionIndex + 1;
      final questionId = '${quiz.stageId}_q$questionNumber';
      final questionTitle = question.question;

      final alreadyExists = await monsterNotifier.hasIncorrectMonster(questionId);

      await monsterNotifier.recordIncorrect(
        questionId: questionId,
        stageId: quiz.stageId,
        questionNumber: questionNumber,
        questionTitle: questionTitle,
      );

      if (!alreadyExists) {
        newlyCreatedQuestionIds.add(questionId);
      }
    }

    // 正解した問題をチェック: モンスター進化 + タイムカプセル登録
    final timeCapsuleNotifier = ref.read(timeCapsuleProvider.notifier);

    for (int i = 0; i < quiz.questions.length; i++) {
      final selectedAnswer = i < quiz.selectedAnswers.length ? quiz.selectedAnswers[i] : null;
      final correctIndex = quiz.questions[i].correctAnswerIndex;
      final question = quiz.questions[i];

      // 正解した問題
      if (selectedAnswer == correctIndex) {
        final questionNumber = i + 1;
        final questionId = '${quiz.stageId}_q$questionNumber';
        final questionTitle = question.question;

        // 🎯 NEW: タイムカプセルに登録（復習スケジュール追加）
        await timeCapsuleNotifier.createFromQuestion(
          questionId: questionId,
          stageId: quiz.stageId,
          questionNumber: questionNumber,
          questionTitle: questionTitle,
        );

        // モンスター進化チェック
        final existing = await ref
            .read(incorrectMonstersProvider.notifier)
            .hasIncorrectMonster(questionId);

        if (existing) {
          // モンスターを進化させる
          final monsters = ref.read(incorrectMonstersProvider);
          IncorrectMonster? monster;
          for (final m in monsters) {
            if (m.questionId == questionId) {
              monster = m;
              break;
            }
          }

          if (monster != null && monster.canEvolve()) {
            await monsterNotifier.evolveMonster(monster.id);
            // 進化後の最新状態を再取得（correctionsCount/evolutionState が更新済み）
            final updatedMonsters = ref.read(incorrectMonstersProvider);
            for (final m in updatedMonsters) {
              if (m.id == monster.id) {
                evolvedMonsters.add(m); // 進化したモンスターを全て記録
                break;
              }
            }
          }
        }
      }
    }

    final result = await ref
        .read(userProgressProvider.notifier)
        .completeStage(
          quiz.stageId,
          quiz.earnedPoints,
          quiz.correctCount,
          quiz.totalQuestions,
          wrongQuestionNumbers: wrongNums,
        );

    if (mounted) {
      setState(() => _coinsEarned = result.coinsEarned);
    }

    // 全問正解: 親ほめ待ちリストに登録
    if (quiz.correctCount == quiz.totalQuestions && quiz.totalQuestions > 0) {
      final stageName = quiz.stageId; // ステージ名はIDで代用（表示は別途調整可）
      await ref
          .read(pendingPraiseProvider.notifier)
          .addClearedStage(quiz.stageId, stageName);
    }

    // 🎯 NEW: モンスター進化ダイアログを表示（優先度: 最初、複数進化した場合は順番に表示）
    for (final monster in evolvedMonsters) {
      if (!mounted) break;
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (_) => MonsterEvolutionDialog(
            monster: monster,
            onConfirm: () {
              // 進化完了
            },
          ),
        );
      }
    }

    // 🎯 NEW: 新規にモンスター化された問題があれば獲得ダイアログを表示
    if (newlyCreatedQuestionIds.isNotEmpty && mounted) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        final monsters = ref.read(incorrectMonstersProvider);
        IncorrectMonster? newMonster;
        for (final m in monsters) {
          if (m.questionId == newlyCreatedQuestionIds.last) {
            newMonster = m;
            break;
          }
        }
        if (newMonster != null) {
          await showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) => MonsterGetDialog(
              monster: newMonster!,
              onDismiss: () {
                // ダイアログ閉じて、このスクリーンの処理は継続
              },
            ),
          );
        }
      }
    }

    if (result.badges.isNotEmpty && mounted) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => BadgeEarnedDialog(badges: result.badges),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizProvider);
    final isPerfect = quiz.correctCount == quiz.totalQuestions;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildScoreHeader(quiz, isPerfect),
              _buildStatsRow(quiz),
              _buildQuestionList(quiz),
              _buildButtons(context, ref, quiz),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── スコアヘッダー ─────────────────────────────────────
  Widget _buildScoreHeader(QuizState quiz, bool isPerfect) {
    final String grade;
    final Color gradeColor;
    final String gradeEmoji;
    if (quiz.accuracy >= 0.9) {
      grade = 'S';
      gradeColor = const Color(0xFFFF6B00);
      gradeEmoji = '🏆';
    } else if (quiz.accuracy >= 0.7) {
      grade = 'A';
      gradeColor = AppColors.sciencePrimary;
      gradeEmoji = '🎉';
    } else if (quiz.accuracy >= 0.5) {
      grade = 'B';
      gradeColor = AppColors.success;
      gradeEmoji = '👍';
    } else {
      grade = 'C';
      gradeColor = AppColors.textGray;
      gradeEmoji = '💪';
    }

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
      Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradeColor.withOpacity(0.85), AppColors.scienceSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Text(gradeEmoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            isPerfect ? '全問正解！ すごい！' : 'クイズ終了！',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.5), width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${quiz.correctCount}',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '/ ${quiz.totalQuestions}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ランク ',
                      style: TextStyle(
                        color: gradeColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      grade,
                      style: TextStyle(
                        color: gradeColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      '+${quiz.earnedPoints} pt',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_coinsEarned > 0)
                      Text(
                        '🪙 +$_coinsEarned',
                        style: TextStyle(
                          color: Colors.yellow[200],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    Positioned(
      right: -20,
      top: -20,
      child: Opacity(
        opacity: 0.08,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
    Positioned(
      left: -30,
      bottom: 0,
      child: Opacity(
        opacity: 0.06,
        child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
    ],);
  }

  // ── 詳細スタッツ ──────────────────────────────────────
  Widget _buildStatsRow(QuizState quiz) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _StatCard(
            emoji: '✅',
            label: '正解',
            value: '${quiz.correctCount}問',
            color: AppColors.success,
          ),
          const SizedBox(width: 10),
          _StatCard(
            emoji: '❌',
            label: '不正解',
            value: '${quiz.totalQuestions - quiz.correctCount}問',
            color: AppColors.error,
          ),
          const SizedBox(width: 10),
          _StatCard(
            emoji: '⭐',
            label: '獲得ポイント',
            value: '+${quiz.earnedPoints}',
            color: const Color(0xFFFF8C00),
          ),
        ],
      ),
    );
  }

  // ── 問題一覧 ──────────────────────────────────────────
  Widget _buildQuestionList(QuizState quiz) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 問題ごとの結果',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(quiz.questions.length, (i) {
            final q = quiz.questions[i];
            final selected = quiz.selectedAnswers[i];
            final isCorrect = selected == q.correctAnswerIndex;
            return _QuestionResultRow(
              stageId: quiz.stageId,
              number: i + 1,
              question: q.question,
              correctAnswer: q.answers[q.correctAnswerIndex],
              isCorrect: isCorrect,
            );
          }),
        ],
      ),
    );
  }

  // ── ボタン ────────────────────────────────────────────
  Widget _buildButtons(
      BuildContext context, WidgetRef ref, QuizState quiz) {
    final wrongCount = quiz.totalQuestions - quiz.correctCount;
    final isLowScore = quiz.accuracy < 0.5;
    final isPerfect = quiz.correctCount == quiz.totalQuestions;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          // 全問正解: 親にほめてもらおう！バナー
          if (isPerfect) ...[
            GestureDetector(
              onTap: () => context.push(
                '/praise-send/${quiz.stageId}',
                extra: {'stageName': quiz.stageId},
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE91E8C).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Text('💌', style: TextStyle(fontSize: 26)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'おうちの人にほめてもらおう！',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '全問正解を伝えてほめメッセージを受け取ろう',
                            style: TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
          // まちがえた問題だけやり直す（1問以上まちがえた場合のみ）
          if (wrongCount > 0) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  _saved = false;
                  ref.read(quizProvider.notifier).retryWrong();
                  context.go('/quiz/${quiz.stageId}');
                },
                icon: const Text('🔁', style: TextStyle(fontSize: 18)),
                label: Text(
                  'まちがえた$wrongCount問だけやり直す',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          // スコアが低い場合「まなんでから再挑戦」を表示
          if (isLowScore) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/learn/${quiz.stageId}'),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('まなんでから再挑戦 →',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                _saved = false;
                ref.read(quizProvider.notifier).retry();
                context.go('/quiz/${quiz.stageId}');
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'もう一度やる（全問）',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sciencePrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home_rounded),
              label: const Text('ホームに戻る',
                  style: TextStyle(fontSize: 15)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sciencePrimary,
                side: const BorderSide(
                    color: AppColors.sciencePrimary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── スタッツカード ─────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 問題結果行 ─────────────────────────────────────────────
class _QuestionResultRow extends ConsumerWidget {
  final String stageId;
  final int number;
  final String question;
  final String correctAnswer;
  final bool isCorrect;

  const _QuestionResultRow({
    required this.stageId,
    required this.number,
    required this.question,
    required this.correctAnswer,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showExplanationDialog(context, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCorrect
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFFCE4EC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCorrect
                ? AppColors.success.withOpacity(0.3)
                : AppColors.error.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? AppColors.success : AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FuriganaText(
                    '問$number. $question',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 2),
                    FuriganaText(
                      '正解: $correctAnswer',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '💡 詳しく学ぶ',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.sciencePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textGray,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showExplanationDialog(BuildContext context, WidgetRef ref) {
    final explanation = getExplanation(stageId, number);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '問$number の解説',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (explanation != null) ...[
                // 正解理由
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✅ 正解理由',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FuriganaText(
                        explanation['correctReason'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                // よくある間違い
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '❌ よくある間違い',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FuriganaText(
                        explanation['commonMistakes'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                // 発展学習
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF9C27B0).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🚀 発展学習',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FuriganaText(
                        explanation['advancedLearning'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '問$numberの解説はまだ準備中です',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textGray,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
