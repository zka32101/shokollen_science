import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../../../data/seeds/sample_questions.dart';
import '../../../data/seeds/stages.dart';
import '../../progress/providers/user_progress_provider.dart';

class TimerQuizScreen extends ConsumerStatefulWidget {
  final String stageId;
  const TimerQuizScreen({super.key, required this.stageId});

  @override
  ConsumerState<TimerQuizScreen> createState() => _TimerQuizScreenState();
}

class _TimerQuizScreenState extends ConsumerState<TimerQuizScreen> {
  int _currentIndex = 0;
  int _timeRemaining = 30;
  int? _selected;
  List<int?> _allSelected = [];
  Timer? _timer;
  bool _answered = false;
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    final qs = sampleQuestionsData
        .where((q) => q['stageId'] == widget.stageId)
        .toList();
    _questions = qs.take(10).toList();
    _allSelected = List.filled(_questions.length, null);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeRemaining = 30;
      _answered = false;
      _selected = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          t.cancel();
          _onTimeout();
        }
      });
    });
  }

  void _onTimeout() {
    setState(() {
      _answered = true;
    });
    Future.delayed(const Duration(seconds: 1), _nextQuestion);
  }

  void _onAnswer(int index) {
    if (_answered) return;
    _timer?.cancel();
    setState(() {
      _answered = true;
      _selected = index;
      _allSelected[_currentIndex] = index;
    });
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();
    final correct = _allSelected.asMap().entries
        .where((e) =>
            e.key < _questions.length &&
            e.value == _questions[e.key]['correctAnswerIndex'])
        .length;
    final total = _questions.length;
    if (mounted) {
      context.push('/timer-quiz-result', extra: {
        'stageId': widget.stageId,
        'correct': correct,
        'total': total,
        'allSelected': _allSelected,
        'questions': _questions,
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _timerColor() {
    if (_timeRemaining <= 10) return Colors.red;
    if (_timeRemaining <= 20) return Colors.orange;
    return AppColors.sciencePrimary;
  }

  String _stageName() {
    final stage = stagesData.firstWhere(
      (s) => s['id'] == widget.stageId,
      orElse: () => {'stageName': 'タイマークイズ'},
    );
    return stage['stageName'] as String? ?? 'タイマークイズ';
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('問題がありません')),
      );
    }

    final q = _questions[_currentIndex];
    final answers = List<String>.from(q['answers'] as List);
    final correctIndex = q['correctAnswerIndex'] as int;
    final explanation = q['explanation'] as String? ?? '';
    final timerColor = _timerColor();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // ── カスタムヘッダー ──
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo[700]!, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // 行1: 戻る / ステージ名 / 問X/Y
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            _timer?.cancel();
                            context.pop();
                          },
                        ),
                        Expanded(
                          child: Text(
                            _stageName(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '問 ${_currentIndex + 1}/${_questions.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 行2: タイマーバー + 残りX秒
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _timeRemaining / 30,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.3),
                              valueColor: AlwaysStoppedAnimation(
                                _timeRemaining <= 10
                                    ? Colors.red[300]!
                                    : _timeRemaining <= 20
                                        ? Colors.orange[300]!
                                        : Colors.white,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 44,
                          child: Text(
                            '残り ${_timeRemaining}s',
                            style: TextStyle(
                              color: _timeRemaining <= 10
                                  ? Colors.red[200]
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── 問題エリア ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイムアウトバナー
                    if (_answered && _selected == null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: const Text(
                          '⏰ 時間切れ！',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],

                    // 問題カード
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: FuriganaText(
                        q['question'] as String,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.5),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 4択ボタン
                    ...answers.asMap().entries.map((entry) {
                      final i = entry.key;
                      final label = entry.value;
                      Color buttonColor = Colors.white;
                      Color borderColor = AppColors.borderGray;
                      Color textColor = AppColors.textDark;
                      IconData? trailingIcon;

                      if (_answered) {
                        if (i == correctIndex) {
                          buttonColor = Colors.green[50]!;
                          borderColor = Colors.green;
                          textColor = Colors.green[800]!;
                          trailingIcon = Icons.check_circle;
                        } else if (i == _selected) {
                          buttonColor = Colors.red[50]!;
                          borderColor = Colors.red;
                          textColor = Colors.red[800]!;
                          trailingIcon = Icons.cancel;
                        }
                      }

                      return GestureDetector(
                        onTap: () => _onAnswer(i),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _answered && i == correctIndex
                                      ? Colors.green
                                      : _answered && i == _selected
                                          ? Colors.red
                                          : AppColors.scienceLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  String.fromCharCode(65 + i), // A, B, C, D
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _answered &&
                                            (i == correctIndex ||
                                                i == _selected)
                                        ? Colors.white
                                        : AppColors.sciencePrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FuriganaText(
                                  label,
                                  style: TextStyle(fontSize: 14, color: textColor),
                                ),
                              ),
                              if (trailingIcon != null)
                                Icon(trailingIcon,
                                    color: i == correctIndex
                                        ? Colors.green
                                        : Colors.red,
                                    size: 20),
                            ],
                          ),
                        ),
                      );
                    }),

                    // 解説
                    if (_answered && explanation.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '💡 解説',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            const SizedBox(height: 6),
                            FuriganaText(
                              explanation,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF1565C0)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── 次へボタン ──
            if (_answered)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sciencePrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentIndex < _questions.length - 1
                          ? '次の問題へ →'
                          : '結果を見る！',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
