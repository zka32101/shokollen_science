import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../../../data/seeds/sample_questions.dart';
import '../../../data/seeds/stages.dart';
import '../../progress/providers/user_progress_provider.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});
  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _currentIndex = 0;
  List<int?> _selected = [];
  bool _finished = false;
  List<Map<String, dynamic>> _reviewQuestions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWrongQuestions());
  }

  void _loadWrongQuestions() {
    final progress = ref.read(userProgressProvider).value;
    if (progress == null) return;
    final wrongMap = progress.wrongAnswers;
    final questions = <Map<String, dynamic>>[];
    for (final entry in wrongMap.entries) {
      final stageId = entry.key;
      final wrongNums = entry.value;
      final stageQuestions = sampleQuestionsData
          .where((q) => q['stageId'] == stageId)
          .toList();
      for (final num in wrongNums) {
        final matching = stageQuestions.where((q) => q['questionNumber'] == num).toList();
        questions.addAll(matching);
      }
    }
    setState(() {
      _reviewQuestions = questions.take(10).toList();
      _selected = List.filled(_reviewQuestions.length, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_reviewQuestions.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.scienceGradient),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 72)),
                    const SizedBox(height: 16),
                    const Text('にがて問題がありません！\nすばらしい！',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('ホームに戻る'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_finished) return _buildResult(context);

    final q = _reviewQuestions[_currentIndex];
    final answers = List<String>.from(q['answers'] as List);
    final correct = q['correctAnswerIndex'] as int;
    final answered = _selected[_currentIndex] != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text('にがて問題 ${_currentIndex + 1}/${_reviewQuestions.length}'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ステージ名
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getStageName(q['stageId'] as String),
                style: TextStyle(fontSize: 12, color: Colors.red[700], fontWeight: FontWeight.bold),
              ),
            ),
            // 問題
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
              ),
              child: FuriganaText(q['question'] as String,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.5)),
            ),
            const SizedBox(height: 16),
            ...answers.asMap().entries.map((e) {
              final i = e.key;
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
                  child: FuriganaText(e.value, style: const TextStyle(fontSize: 14)),
                ),
              );
            }),
            if (answered) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FuriganaText(q['explanation'] as String,
                    style: const TextStyle(fontSize: 13, height: 1.6)),
              ),
            ],
            const SizedBox(height: 80),
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
                if (_currentIndex < _reviewQuestions.length - 1) {
                  setState(() => _currentIndex++);
                } else {
                  setState(() => _finished = true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600], foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(_currentIndex < _reviewQuestions.length - 1 ? '次の問題' : '結果を見る',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ) : null,
    );
  }

  String _getStageName(String stageId) {
    final stage = stagesData.firstWhere((s) => s['id'] == stageId, orElse: () => {});
    return stage['stageName'] as String? ?? stageId;
  }

  Widget _buildResult(BuildContext context) {
    final correct = _selected.asMap().entries.where((e) {
      if (e.key >= _reviewQuestions.length) return false;
      return e.value == _reviewQuestions[e.key]['correctAnswerIndex'];
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(correct == _reviewQuestions.length ? '🏆' : correct >= _reviewQuestions.length ~/ 2 ? '👍' : '💪',
                    style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                Text('$correct / ${_reviewQuestions.length} せいかい！',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('にがて問題を練習しました！', style: TextStyle(fontSize: 16, color: AppColors.textGray)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600], foregroundColor: Colors.white,
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
