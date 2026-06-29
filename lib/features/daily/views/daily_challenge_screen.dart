import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../../../features/progress/providers/user_progress_provider.dart';
import '../providers/daily_challenge_provider.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});
  @override
  ConsumerState<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  int _currentIndex = 0;
  List<int?> _selected = [];
  bool _finished = false;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final dailyAsync = ref.watch(dailyChallengeProvider);
    return dailyAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(body: Center(child: Text('エラー'))),
      data: (daily) {
        if (!_initialized) {
          _selected = List.filled(daily.questions.length, null);
          _initialized = true;
        }
        if (_finished) return _buildResult(context, daily);
        final q = daily.questions[_currentIndex];
        return _buildQuiz(context, q, daily);
      },
    );
  }

  Widget _buildQuiz(BuildContext context, Map<String, dynamic> q, DailyChallengeState daily) {
    final total = daily.questions.length;
    final answers = List<String>.from(q['answers'] as List);
    final correct = q['correctAnswerIndex'] as int;
    final answered = _selected[_currentIndex] != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[700]!, Colors.orange[500]!],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('⚡ デイリーチャレンジ',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Text('${_currentIndex + 1}/$total',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / total,
                      backgroundColor: Colors.white30,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 問題
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
                      ),
                      child: FuriganaText(q['question'] as String,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.5)),
                    ),
                    const SizedBox(height: 16),
                    // 選択肢
                    ...answers.asMap().entries.map((e) {
                      final i = e.key;
                      final text = e.value;
                      Color bg = Colors.white;
                      Color border = AppColors.borderGray;
                      if (answered) {
                        if (i == correct) { bg = const Color(0xFFE8F5E9); border = AppColors.success; }
                        else if (i == _selected[_currentIndex]) { bg = const Color(0xFFFCE4EC); border = AppColors.error; }
                      }
                      return GestureDetector(
                        onTap: answered ? null : () => setState(() => _selected[_currentIndex] = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: border, width: 1.5)),
                          child: FuriganaText(text, style: const TextStyle(fontSize: 14)),
                        ),
                      );
                    }),
                    if (answered) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: FuriganaText(q['explanation'] as String,
                            style: const TextStyle(fontSize: 13, height: 1.6)),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: answered ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_currentIndex < total - 1) {
                  setState(() => _currentIndex++);
                } else {
                  setState(() => _finished = true);
                  _complete();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(_currentIndex < total - 1 ? '次の問題' : '結果を見る',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ) : null,
    );
  }

  Future<void> _complete() async {
    final daily = ref.read(dailyChallengeProvider).value;
    if (daily != null && !daily.completed) {
      await ref.read(dailyChallengeProvider.notifier).markCompleted();
      // コインを追加
      await ref.read(userProgressProvider.notifier).addCoins(daily.coinsReward);
    }
  }

  Widget _buildResult(BuildContext context, DailyChallengeState daily) {
    final correct = _selected.asMap().entries.where((e) {
      final q = daily.questions[e.key];
      return e.value == q['correctAnswerIndex'];
    }).length;

    final total = daily.questions.length;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(correct == total ? '🏆' : correct >= total - 1 ? '🎉' : '💪',
                    style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                Text('$correct / $total せいかい！',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Text('🪙 +${daily.coinsReward} コイン ゲット！',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber[800])),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700], foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('ホームに戻る', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
