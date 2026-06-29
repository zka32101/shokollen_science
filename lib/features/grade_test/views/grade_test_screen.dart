import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../../../data/seeds/sample_questions.dart';
import '../../../data/seeds/stages.dart';

class GradeTestScreen extends ConsumerStatefulWidget {
  const GradeTestScreen({super.key});

  @override
  ConsumerState<GradeTestScreen> createState() => _GradeTestScreenState();
}

class _GradeTestScreenState extends ConsumerState<GradeTestScreen> {
  int _grade = 3;
  bool _started = false;
  int _currentIndex = 0;
  List<int?> _selected = [];
  List<Map<String, dynamic>> _questions = [];

  void _loadQuestions() {
    final prefix = 'stage_${_grade}_';
    final gradeQs = sampleQuestionsData
        .where((q) => (q['stageId'] as String).startsWith(prefix))
        .toList();
    gradeQs.shuffle();
    final picked = gradeQs.take(20).toList();
    setState(() {
      _questions = picked;
      _selected = List.filled(picked.length, null);
    });
  }

  int get _correctCount {
    return _selected
        .asMap()
        .entries
        .where((e) => e.value == _questions[e.key]['correctAnswerIndex'])
        .length;
  }

  void _onAnswerSelected(int answerIndex) {
    if (_selected[_currentIndex] != null) return;
    setState(() {
      _selected[_currentIndex] = answerIndex;
    });
  }

  void _onNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      context.push(
        '/certificate/$_grade',
        extra: {
          'correct': _correctCount,
          'total': _questions.length,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return _buildGradeSelectScreen();
    }
    return _buildTestScreen();
  }

  Widget _buildGradeSelectScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.scienceGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.science,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '学年末まとめテスト',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '学年を選んでチャレンジしよう！',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ...List.generate(4, (i) {
                    final grade = i + 3;
                    final isSelected = _grade == grade;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _grade = grade),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '$grade年生',
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.sciencePrimary
                                      : Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.sciencePrimary,
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _loadQuestions();
                        setState(() => _started = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.sciencePrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'はじめる！',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestScreen() {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${_grade}年生まとめテスト')),
        body: const Center(child: Text('問題がありません')),
      );
    }

    final question = _questions[_currentIndex];
    final answered = _selected[_currentIndex] != null;
    final selectedIndex = _selected[_currentIndex];
    final correctIndex = question['correctAnswerIndex'] as int;
    final answers = (question['answers'] as List).cast<String>();
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_grade}年生まとめテスト'),
        backgroundColor: AppColors.sciencePrimary,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '問 ${_currentIndex + 1}/${_questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.scienceLight,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.sciencePrimary,
            ),
            minHeight: 6,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.scienceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.sciencePrimary.withOpacity(0.3),
                      ),
                    ),
                    child: FuriganaText(
                      question['question'] as String,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(answers.length, (i) {
                    Color buttonColor = Colors.white;
                    Color textColor = AppColors.textDark;
                    Color borderColor = AppColors.borderGray;

                    if (answered) {
                      if (i == correctIndex) {
                        buttonColor = AppColors.success.withOpacity(0.15);
                        textColor = AppColors.success;
                        borderColor = AppColors.success;
                      } else if (i == selectedIndex) {
                        buttonColor = AppColors.error.withOpacity(0.15);
                        textColor = AppColors.error;
                        borderColor = AppColors.error;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _onAnswerSelected(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: answered && i == correctIndex
                                      ? AppColors.success
                                      : answered && i == selectedIndex
                                          ? AppColors.error
                                          : AppColors.sciencePrimary
                                              .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    ['ア', 'イ', 'ウ', 'エ'][i],
                                    style: TextStyle(
                                      color: answered &&
                                              (i == correctIndex ||
                                                  i == selectedIndex)
                                          ? Colors.white
                                          : AppColors.sciencePrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  answers[i],
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: answered && i == correctIndex
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (answered && i == correctIndex)
                                const Icon(Icons.check_circle,
                                    color: AppColors.success, size: 20),
                              if (answered && i == selectedIndex && i != correctIndex)
                                const Icon(Icons.cancel,
                                    color: AppColors.error, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (answered) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb,
                                  color: Colors.amber, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'かいせつ',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question['explanation'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sciencePrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentIndex < _questions.length - 1
                              ? '次へ →'
                              : '結果を見る 🏆',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
