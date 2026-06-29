import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../../progress/providers/user_progress_provider.dart';

class TimerQuizResultScreen extends StatefulWidget {
  final String stageId;
  final int correct;
  final int total;
  final List<int?> allSelected;
  final List<Map<String, dynamic>> questions;

  const TimerQuizResultScreen({
    super.key,
    required this.stageId,
    required this.correct,
    required this.total,
    required this.allSelected,
    required this.questions,
  });

  @override
  State<TimerQuizResultScreen> createState() => _TimerQuizResultScreenState();
}

class _TimerQuizResultScreenState extends State<TimerQuizResultScreen> {
  // Need ProviderContainer or ConsumerWidget — use late ref via initState
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    // Progress saving is deferred to didChangeDependencies so ref is available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_saved) {
      _saved = true;
      _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    // Access provider via ProviderScope
    final container = ProviderScope.containerOf(context);
    await container
        .read(userProgressProvider.notifier)
        .completeStage(
          widget.stageId,
          widget.correct * 10,
          widget.correct,
          widget.total,
        );
  }

  String _resultEmoji() {
    final ratio = widget.total > 0 ? widget.correct / widget.total : 0;
    if (ratio >= 0.9) return '🏆';
    if (ratio >= 0.7) return '⭐';
    if (ratio >= 0.5) return '😊';
    return '😅';
  }

  String _resultMessage() {
    final ratio = widget.total > 0 ? widget.correct / widget.total : 0;
    if (ratio >= 0.9) return 'すごい！ほぼ満点！';
    if (ratio >= 0.7) return 'よくできました！';
    if (ratio >= 0.5) return 'もう少し！';
    return 'もっと練習しよう！';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // ── 結果ヘッダー ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo[700]!, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // ⚡ タイマーモードバッジ
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '⚡ タイマーモード',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _resultEmoji(),
                    style: const TextStyle(fontSize: 56),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _resultMessage(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.correct}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      Text(
                        ' / ${widget.total}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '正解',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '獲得ポイント: ${widget.correct * 10} pt',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // ── 問題一覧 ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.questions.length,
                itemBuilder: (_, i) {
                  final q = widget.questions[i];
                  final selected = i < widget.allSelected.length
                      ? widget.allSelected[i]
                      : null;
                  final correctIndex = q['correctAnswerIndex'] as int;
                  final isCorrect = selected == correctIndex;
                  final isTimeout = selected == null;
                  final answers = List<String>.from(q['answers'] as List);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCorrect
                            ? Colors.green.shade300
                            : isTimeout
                                ? Colors.orange.shade300
                                : Colors.red.shade300,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isCorrect
                                  ? '✅'
                                  : isTimeout
                                      ? '⏰'
                                      : '❌',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '問${i + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? Colors.green[700]
                                    : isTimeout
                                        ? Colors.orange[700]
                                        : Colors.red[700],
                              ),
                            ),
                            if (isTimeout)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.orange.shade300),
                                ),
                                child: const Text(
                                  '時間切れ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        FuriganaText(
                          q['question'] as String,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '正解: ${answers[correctIndex]}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!isCorrect && !isTimeout && selected != null)
                          Text(
                            'あなたの答え: ${answers[selected]}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[600],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── ボタン ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.pushReplacement(
                            '/quiz-timer/${widget.stageId}');
                      },
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('もう一度'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.sciencePrimary,
                        side: const BorderSide(color: AppColors.sciencePrimary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('ホームへ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sciencePrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
