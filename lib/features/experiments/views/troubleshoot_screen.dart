import 'package:flutter/material.dart';
import '../data/troubleshoot_data.dart';

// ⑥ 失敗ラボ推理: 実験の失敗原因を推理するクイズ画面
class TroubleshootScreen extends StatefulWidget {
  final String experimentId;

  const TroubleshootScreen({required this.experimentId, super.key});

  @override
  State<TroubleshootScreen> createState() => _TroubleshootScreenState();
}

class _TroubleshootScreenState extends State<TroubleshootScreen> {
  List<TroubleshootQuestion> _questions = [];
  int _index = 0;
  String? _selected;
  bool _revealed = false;
  int _correct = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _questions = getTroubleshootQuestionsByExperiment(widget.experimentId);
    if (_questions.isEmpty) {
      // 実験固有データがなければランダムで5問
      _questions = troubleshootQuestions.take(5).toList();
    }
  }

  TroubleshootQuestion? get _currentQ =>
      _index < _questions.length ? _questions[_index] : null;

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResult();
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('失敗ラボ')),
        body: const Center(child: Text('問題データがありません')),
      );
    }
    final q = _currentQ!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('失敗ラボ 🕵️'),
        backgroundColor: const Color(0xFFF57F17),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgress(q),
            const SizedBox(height: 20),
            _buildScenarioCard(q),
            const SizedBox(height: 20),
            if (!_revealed) _buildChoices(q) else _buildReveal(q),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(TroubleshootQuestion q) {
    return Row(
      children: [
        _buildDifficultyBadge(q.difficulty),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '問題 ${_index + 1} / ${_questions.length}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFF57F17),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / _questions.length,
            backgroundColor: Colors.orange.shade100,
            valueColor: const AlwaysStoppedAnimation(Color(0xFFF57F17)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyBadge(int difficulty) {
    final stars = '★' * difficulty + '☆' * (5 - difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF57F17),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        stars,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  Widget _buildScenarioCard(TroubleshootQuestion q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
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
              const Text('🧪', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Text(
                '何が失敗の原因？',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF57F17),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            q.scenario,
            style: const TextStyle(fontSize: 17, height: 1.6, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildChoices(TroubleshootQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'どれが原因だと思う？🔍',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...q.choices.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _select(c, q),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selected == c
                        ? const Color(0xFFF57F17)
                        : Colors.white,
                    foregroundColor: _selected == c
                        ? Colors.white
                        : const Color(0xFF2C3E50),
                    elevation: _selected == c ? 4 : 1,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: _selected == c
                            ? const Color(0xFFF57F17)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(c, style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildReveal(TroubleshootQuestion q) {
    final isCorrect = _selected == q.correctAnswer;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrect
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCorrect ? Colors.green : Colors.red.shade300,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCorrect ? '✅ 正解！よく見つけた！' : '❌ 残念… 正解は：',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green.shade700 : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                q.correctAnswer,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 20),
              const Text(
                '解説',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                q.explanation,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF57F17),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _index + 1 < _questions.length ? '次の問題へ →' : '結果を見る',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final total = _questions.length;
    final rate = total == 0 ? 0 : (_correct * 100) ~/ total;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('失敗ラボ 結果'),
        backgroundColor: const Color(0xFFF57F17),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              _correct >= 3
                  ? '🕵️ ラボたんてい！'
                  : '🔍 もっと調べよう！',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_correct / $total 正解',
              style: TextStyle(
                fontSize: 24,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '正答率 $rate%',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (_correct >= 3) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🏅', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'ラボたんていバッジ獲得！',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57F17),
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

  void _select(String answer, TroubleshootQuestion q) {
    setState(() {
      _selected = answer;
      _revealed = true;
    });
    if (answer == q.correctAnswer) _correct++;
  }

  void _next() {
    if (_index + 1 < _questions.length) {
      setState(() {
        _index++;
        _selected = null;
        _revealed = false;
      });
    } else {
      setState(() => _finished = true);
    }
  }
}
