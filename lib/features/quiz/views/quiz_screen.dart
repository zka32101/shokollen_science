import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../../../services/tts_service.dart';
import '../providers/quiz_provider.dart';
import '../../progress/providers/user_progress_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String stageId;
  const QuizScreen({super.key, required this.stageId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _explanationAnim;
  late Animation<Offset> _explanationSlide;
  int? _eliminatedIndex;

  // 難易度ごとの絵文字
  static const _diffEmoji = ['', '⭐', '⭐⭐', '⭐⭐⭐', '⭐⭐⭐⭐', '⭐⭐⭐⭐⭐'];

  @override
  void initState() {
    super.initState();
    _explanationAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _explanationSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _explanationAnim,
      curve: Curves.easeOutCubic,
    ));

    // ステージをロード
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).loadStage(widget.stageId);
    });
  }

  @override
  void dispose() {
    _explanationAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizProvider);

    // 全問終了 → 結果画面へ
    ref.listen(quizProvider, (prev, next) {
      if (!prev!.isFinished && next.isFinished) {
        context.go('/quiz-result');
      }
      // 回答した瞬間にスライドアニメーション
      if (!prev.isAnswered && next.isAnswered) {
        _explanationAnim.forward(from: 0);
      }
      // 次の問題へ進んだとき
      if (prev.currentIndex != next.currentIndex) {
        _explanationAnim.reset();
        _eliminatedIndex = null;
      }
    });

    if (quiz.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = quiz.currentQuestion;
    final selectedIdx = quiz.selectedAnswers[quiz.currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // ── ヘッダー ──
            _buildHeader(quiz),

            // ── 問題エリア（スクロール可） ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // 問題文カード
                    _buildQuestionCard(q.question, q.difficultyLevel),
                    const SizedBox(height: 20),
                    // 選択肢ボタン
                    _buildHintButton(quiz),
                    ...List.generate(q.answers.length, (i) {
                      final isEliminated =
                          !quiz.isAnswered && i == _eliminatedIndex;
                      return Opacity(
                        opacity: isEliminated ? 0.35 : 1.0,
                        child: _AnswerButton(
                          label: ['A', 'B', 'C', 'D'][i],
                          text: isEliminated
                              ? '✕ (ちがう答え)'
                              : q.answers[i],
                          state: _answerState(
                            i, selectedIdx, q.correctAnswerIndex,
                            quiz.isAnswered,
                          ),
                          onTap: (quiz.isAnswered || isEliminated)
                              ? null
                              : () => ref
                                  .read(quizProvider.notifier)
                                  .selectAnswer(i),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),

                    // ── 解説カード（スライドアップ） ──
                    if (quiz.isAnswered)
                      SlideTransition(
                        position: _explanationSlide,
                        child: _buildExplanationCard(
                          q.explanation,
                          selectedIdx == q.correctAnswerIndex,
                          q.answers[q.correctAnswerIndex],
                          quiz.stageId,
                        ),
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── 次の問題 / 結果へ ボタン ──
      bottomNavigationBar: quiz.isAnswered
          ? _buildNextButton(quiz)
          : null,
    );
  }

  // ── ヘッダー（グラデーション + プログレスバー） ──────────
  Widget _buildHeader(QuizState quiz) {
    final progress =
        (quiz.currentIndex + 1) / quiz.totalQuestions;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        gradient: AppColors.scienceGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/home'),
                child: const Icon(Icons.close, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  quiz.stageName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${quiz.currentIndex + 1} / ${quiz.totalQuestions}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // プログレスバー
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ── 問題文カード ──────────────────────────────────────────
  Widget _buildQuestionCard(String question, int difficulty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.sciencePrimary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔬', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                _diffEmoji[difficulty.clamp(1, 5)],
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FuriganaText(
            question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => ttsService.speak(question),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.scienceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderGray),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up_rounded, size: 16, color: AppColors.sciencePrimary),
                          SizedBox(width: 4),
                          Text('よむ', style: TextStyle(fontSize: 12, color: AppColors.sciencePrimary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ── ヒントボタン ──────────────────────────────────────────
  Widget _buildHintButton(QuizState quiz) {
    final progress = ref.watch(userProgressProvider).value;
    final hintsLeft = progress?.hintsRemaining ?? 0;
    if (quiz.isAnswered || _eliminatedIndex != null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (hintsLeft > 0)
            TextButton.icon(
              onPressed: () async {
                final correct = quiz.currentQuestion.correctAnswerIndex;
                final wrongIndices = List.generate(
                  quiz.currentQuestion.answers.length,
                  (i) => i,
                ).where((i) => i != correct).toList()..shuffle();

                if (wrongIndices.isNotEmpty) {
                  final used = await ref
                      .read(userProgressProvider.notifier)
                      .useHint();
                  if (used && mounted) {
                    setState(() => _eliminatedIndex = wrongIndices.first);
                  }
                }
              },
              icon: const Text('💡', style: TextStyle(fontSize: 16)),
              label: Text(
                'ヒント（残り$hintsLeft回）',
                style: const TextStyle(fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber[800],
                backgroundColor: Colors.amber[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.amber[200]!),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: () => context.push('/learn/${quiz.stageId}'),
              icon: const Text('📖', style: TextStyle(fontSize: 14)),
              label: const Text('まなぶをみる',
                  style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.sciencePrimary,
                backgroundColor: AppColors.scienceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.sciencePrimary.withOpacity(0.3)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── 解説カード ────────────────────────────────────────────
  Widget _buildExplanationCard(
    String explanation,
    bool isCorrect,
    String correctAnswerText,
    String stageId,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCorrect
              ? AppColors.success.withOpacity(0.5)
              : AppColors.error.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isCorrect
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.error.withOpacity(0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Text(
                  isCorrect ? '✅ 正解！すごい！' : '❌ まちがえた…',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 不正解のとき → 正しい答えを強調表示
                if (!isCorrect) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.success.withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⭕',
                            style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'せいかいは…',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              FuriganaText(
                                correctAnswerText,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // 解説テキスト（ふりがな対応）
                const Text(
                  '📖 かいせつ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 6),
                FuriganaText(
                  explanation,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                    height: 1.8,
                  ),
                ),
                // 不正解のとき → まなぶへのリンク
                if (!isCorrect) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.push('/learn/$stageId'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.sciencePrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.sciencePrimary.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📚', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 6),
                          Text(
                            'このステージをまなぶ →',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.sciencePrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 次の問題ボタン ────────────────────────────────────────
  Widget _buildNextButton(QuizState quiz) {
    final isLast =
        quiz.currentIndex == quiz.totalQuestions - 1;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () =>
                ref.read(quizProvider.notifier).nextQuestion(),
            icon: Icon(
              isLast
                  ? Icons.flag_rounded
                  : Icons.arrow_forward_rounded,
            ),
            label: Text(
              isLast ? '結果を見る' : '次の問題へ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sciencePrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ── 選択肢の状態を判定 ────────────────────────────────────
  _AnswerState _answerState(
    int index,
    int? selected,
    int correct,
    bool isAnswered,
  ) {
    if (!isAnswered) return _AnswerState.idle;
    if (index == correct) return _AnswerState.correct;
    if (index == selected) return _AnswerState.wrong;
    return _AnswerState.idle;
  }
}

// ── 選択肢ボタン ──────────────────────────────────────────
enum _AnswerState { idle, correct, wrong }

class _AnswerButton extends StatelessWidget {
  final String label;
  final String text;
  final _AnswerState state;
  final VoidCallback? onTap;

  const _AnswerButton({
    required this.label,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, border, labelBg, textColor;

    switch (state) {
      case _AnswerState.correct:
        bg = const Color(0xFFE8F5E9);
        border = AppColors.success;
        labelBg = AppColors.success;
        textColor = AppColors.textDark;
      case _AnswerState.wrong:
        bg = const Color(0xFFFCE4EC);
        border = AppColors.error;
        labelBg = AppColors.error;
        textColor = AppColors.textDark;
      case _AnswerState.idle:
        bg = Colors.white;
        border = AppColors.borderGray;
        labelBg = const Color(0xFFEBF5FB);
        textColor = AppColors.textDark;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ラベル丸
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: labelBg,
                shape: BoxShape.circle,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: state == _AnswerState.idle
                      ? AppColors.sciencePrimary
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FuriganaText(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: state == _AnswerState.correct
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            if (state == _AnswerState.correct)
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 20),
            if (state == _AnswerState.wrong)
              const Icon(Icons.cancel,
                  color: AppColors.error, size: 20),
          ],
        ),
      ),
    );
  }
}
