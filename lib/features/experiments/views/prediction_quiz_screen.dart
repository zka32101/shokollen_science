import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/prediction_provider.dart';
import '../widgets/prediction_result_widget.dart';

// ① よそうラボ: 実験の前に「何が起きるか」を予想するスクリーン
class PredictionQuizScreen extends ConsumerStatefulWidget {
  final String experimentId;

  const PredictionQuizScreen({required this.experimentId, super.key});

  @override
  ConsumerState<PredictionQuizScreen> createState() =>
      _PredictionQuizScreenState();
}

class _PredictionQuizScreenState extends ConsumerState<PredictionQuizScreen> {
  int _questionIndex = 0;
  String? _selectedAnswer;
  bool _revealed = false;
  int _score = 0;
  bool _finished = false;
  final List<_PredQResult> _results = [];

  List<_PredQ> get _questions => _getQuestions(widget.experimentId);

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildFinished();
    if (_questions.isEmpty) return _buildEmpty();

    final q = _questions[_questionIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: const Text('よそうラボ 🔬'),
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgress(),
            const SizedBox(height: 20),
            _buildQuestionCard(q),
            const SizedBox(height: 20),
            if (!_revealed) _buildChoices(q) else _buildReveal(q),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      children: [
        Text(
          'よそう ${_questionIndex + 1} / ${_questions.length}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3498DB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_questionIndex + 1) / _questions.length,
              backgroundColor: Colors.blue.shade100,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF3498DB)),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(_PredQ q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(q.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            q.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChoices(_PredQ q) {
    return Column(
      children: [
        const Text(
          'どっちだと思う？',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...q.choices.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _selectAnswer(c, q),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedAnswer == c
                        ? const Color(0xFF3498DB)
                        : Colors.white,
                    foregroundColor: _selectedAnswer == c
                        ? Colors.white
                        : const Color(0xFF2C3E50),
                    elevation: _selectedAnswer == c ? 4 : 1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _selectedAnswer == c
                            ? const Color(0xFF3498DB)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: Text(c, style: const TextStyle(fontSize: 16)),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildReveal(_PredQ q) {
    final isCorrect = _selectedAnswer == q.correct;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrect
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCorrect ? Colors.green : Colors.orange,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                isCorrect ? '🎯 あたり！' : '💡 はずれ…',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green.shade700 : Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '正解：${q.correct}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                q.explanation,
                style: const TextStyle(fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              if (isCorrect)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+10 ボーナスコイン',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _questionIndex + 1 < _questions.length ? '次のよそうへ →' : '結果を見る',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinished() {
    final rate = _questions.isEmpty ? 0.0 : _score / _questions.length * 100;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: const Text('よそうラボ 結果'),
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              rate >= 90
                  ? '🏆 よそう名人！'
                  : rate >= 70
                      ? '⭐ よくできた！'
                      : '🔬 次回がんばろう！',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$_score / ${_questions.length} 正解',
              style: TextStyle(
                fontSize: 22,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '的中率 ${rate.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            PredictionResultWidget(
              experimentId: widget.experimentId,
              userPrediction: _results.isNotEmpty ? _results.last.selected : null,
              correctAnswer: _results.isNotEmpty ? _results.last.correct : '',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ホームへ戻る',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Scaffold(
      appBar: AppBar(title: const Text('よそうラボ')),
      body: const Center(child: Text('この実験のよそうデータはまだありません')),
    );
  }

  void _selectAnswer(String answer, _PredQ q) {
    setState(() {
      _selectedAnswer = answer;
      _revealed = true;
    });
    final isCorrect = answer == q.correct;
    if (isCorrect) _score++;
    _results.add(_PredQResult(selected: answer, correct: q.correct));
    ref.read(predictionProvider.notifier).recordPrediction(
          experimentId: widget.experimentId,
          userPrediction: answer,
          correctAnswer: q.correct,
        );
  }

  void _nextQuestion() {
    if (_questionIndex + 1 < _questions.length) {
      setState(() {
        _questionIndex++;
        _selectedAnswer = null;
        _revealed = false;
      });
    } else {
      setState(() => _finished = true);
    }
  }
}

class _PredQ {
  final String emoji;
  final String question;
  final List<String> choices;
  final String correct;
  final String explanation;

  const _PredQ({
    required this.emoji,
    required this.question,
    required this.choices,
    required this.correct,
    required this.explanation,
  });
}

class _PredQResult {
  final String selected;
  final String correct;
  _PredQResult({required this.selected, required this.correct});
}

List<_PredQ> _getQuestions(String experimentId) {
  // 各実験のよそう問題 (Firestore拡張まで静的データ)
  switch (experimentId) {
    case 'exp_magnet_001':
      return [
        _PredQ(
          emoji: '🧲',
          question: 'くぎは磁石につくかな？',
          choices: ['つく', 'つかない'],
          correct: 'つく',
          explanation: '磁石は鉄でできたくぎを引きつけます。鉄のものはほとんど磁石につくよ！',
        ),
        _PredQ(
          emoji: '🪙',
          question: '100円玉は磁石につくかな？',
          choices: ['つく', 'つかない'],
          correct: 'つかない',
          explanation: '100円玉はニッケルと銅でできているので、磁石につかないんだ。',
        ),
        _PredQ(
          emoji: '🔃',
          question: '磁石のN極とS極を近づけると？',
          choices: ['引き合う', '反発する'],
          correct: '引き合う',
          explanation: '違う極（N極とS極）同士は引き合い、同じ極同士は反発します。',
        ),
      ];
    case 'exp_balloon_001':
      return [
        _PredQ(
          emoji: '🎈',
          question: '風船を冷蔵庫に入れると、風船はどうなるかな？',
          choices: ['小さくなる', '大きくなる'],
          correct: '小さくなる',
          explanation: '冷えると空気が縮んで、風船が小さくなります。熱すると膨らむよ！',
        ),
        _PredQ(
          emoji: '⚡',
          question: '風船を頭でこすると何が起きる？',
          choices: ['静電気で髪がくっつく', '何も起きない'],
          correct: '静電気で髪がくっつく',
          explanation: '摩擦で静電気が生まれ、風船と髪の毛がくっつくようになります。',
        ),
      ];
    default:
      return [
        _PredQ(
          emoji: '🔬',
          question: '科学では、実験前に「よそう」をすることが大切です。なぜ？',
          choices: ['考える力がつくから', '正解が分かるから'],
          correct: '考える力がつくから',
          explanation: '予想することで「なぜ？」と考える習慣がつきます。外れても大丈夫！',
        ),
      ];
  }
}
