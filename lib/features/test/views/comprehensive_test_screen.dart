import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../../../data/seeds/sample_questions.dart';
import '../../../data/seeds/stages.dart';
import '../../progress/providers/user_progress_provider.dart';

class ComprehensiveTestScreen extends ConsumerStatefulWidget {
  final int grade;
  const ComprehensiveTestScreen({super.key, required this.grade});

  @override
  ConsumerState<ComprehensiveTestScreen> createState() =>
      _ComprehensiveTestScreenState();
}

class _ComprehensiveTestScreenState
    extends ConsumerState<ComprehensiveTestScreen> {
  late List<Map<String, dynamic>> _questions;
  final List<int?> _selected = [];
  int _currentIndex = 0;
  bool _finished = false;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions();
    _selected.addAll(List.filled(_questions.length, null));
  }

  List<Map<String, dynamic>> _buildQuestions() {
    // 学年のステージIDを取得
    final stageIds = stagesData
        .where((s) => s['gradeLevel'] == widget.grade)
        .map((s) => s['id'] as String)
        .toSet();
    // その学年の全問題
    final all = sampleQuestionsData
        .where((q) => stageIds.contains(q['stageId']))
        .toList();
    // シャッフルして最大15問
    final seed = DateTime.now().millisecondsSinceEpoch;
    all.shuffle(Random(seed));
    return all.take(15).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResult(context);

    final q = _questions[_currentIndex];
    final answers = List<String>.from(q['answers'] as List);
    final correct = q['correctAnswerIndex'] as int;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(q),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 問題文
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                      ),
                      child: FuriganaText(q['question'] as String,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.5)),
                    ),
                    const SizedBox(height: 16),
                    // 選択肢
                    ...answers.asMap().entries.map((e) {
                      final i = e.key;
                      Color bg = Colors.white;
                      Color border = AppColors.borderGray;
                      if (_answered) {
                        if (i == correct) { bg = const Color(0xFFE8F5E9); border = AppColors.success; }
                        else if (i == _selected[_currentIndex]) { bg = const Color(0xFFFCE4EC); border = AppColors.error; }
                      }
                      return GestureDetector(
                        onTap: _answered ? null : () => setState(() {
                          _selected[_currentIndex] = i;
                          _answered = true;
                        }),
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
                    if (_answered) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _selected[_currentIndex] == correct
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: _answered
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentIndex < _questions.length - 1) {
                        setState(() { _currentIndex++; _answered = false; });
                      } else {
                        setState(() => _finished = true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sciencePrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _currentIndex < _questions.length - 1 ? '次の問題' : '結果を見る',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(Map<String, dynamic> q) {
    final stageId = q['stageId'] as String;
    final stage = stagesData.firstWhere((s) => s['id'] == stageId, orElse: () => {});
    final stageName = stage['stageName'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[700]!, Colors.purple[400]!],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/home'),
                child: const Icon(Icons.close, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${widget.grade}年生 まとめテスト',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Text('${_currentIndex + 1}/${_questions.length}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(stageName,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final correctCount = _selected.asMap().entries
        .where((e) => e.key < _questions.length && e.value == _questions[e.key]['correctAnswerIndex'])
        .length;
    final pct = (_questions.isEmpty ? 0 : (correctCount * 100 / _questions.length)).round();
    final rank = pct >= 90 ? 'S' : pct >= 70 ? 'A' : pct >= 50 ? 'B' : 'C';
    final emoji = pct >= 90 ? '🏆' : pct >= 70 ? '🎉' : pct >= 50 ? '👍' : '💪';
    final rankColor = pct >= 90 ? Colors.orange : pct >= 70 ? AppColors.sciencePrimary : AppColors.success;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.purple[700]!, Colors.purple[400]!]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 12),
                    Text('${widget.grade}年生 まとめテスト',
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('$correctCount / ${_questions.length} 問正解',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('ランク $rank  $pct%',
                          style: TextStyle(color: rankColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 問題ごとの振り返り
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📋 問題ごとの結果',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...List.generate(_questions.length, (i) {
                      final q = _questions[i];
                      final isCorrect = _selected[i] == q['correctAnswerIndex'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? AppColors.success : AppColors.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('問${i + 1}. ${(q['question'] as String).replaceAll(RegExp(r'\{([^|{}]+)\|([^}]+)\}'), r'$1')}',
                                  style: const TextStyle(fontSize: 11.5),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('ホームに戻る', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
