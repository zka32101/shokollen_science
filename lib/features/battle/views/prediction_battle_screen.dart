import 'package:flutter/material.dart';
import '../data/prediction_battle_data.dart';

// ⑨ 親子バトル化: 同じ実験の結果を親子で予想し合い、当てた方が勝ち
class PredictionBattleScreen extends StatefulWidget {
  const PredictionBattleScreen({super.key});

  @override
  State<PredictionBattleScreen> createState() => _PredictionBattleScreenState();
}

class _PredictionBattleScreenState extends State<PredictionBattleScreen> {
  List<PredictionBattleQuestion> _questions = [];
  int _currentRound = 0;
  String? _childPrediction;
  String? _parentPrediction;
  bool _childDone = false;
  bool _parentDone = false;
  bool _roundRevealed = false;
  bool _finished = false;
  final List<BattleRound> _rounds = [];

  static const int _totalRounds = 5;

  @override
  void initState() {
    super.initState();
    _questions = getRandomBattleQuestions(_totalRounds);
  }

  PredictionBattleQuestion? get _currentQuestion =>
      _currentRound < _questions.length ? _questions[_currentRound] : null;

  BattleResult get _battleResult {
    final child = _rounds.fold<int>(0, (s, r) => s + r.childScore);
    final parent = _rounds.fold<int>(0, (s, r) => s + r.parentScore);
    return BattleResult(rounds: _rounds, childTotal: child, parentTotal: parent);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResult();
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('バトルデータを読み込み中...')));
    }
    if (_roundRevealed) return _buildRoundReveal();
    if (!_childDone) return _buildPrediction(isChild: true);
    return _buildPrediction(isChild: false);
  }

  Widget _buildPrediction({required bool isChild}) {
    final q = _currentQuestion!;
    final selected = isChild ? _childPrediction : _parentPrediction;

    return Scaffold(
      backgroundColor: isChild ? const Color(0xFFE3F2FD) : const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text('ラウンド ${_currentRound + 1} / $_totalRounds'),
        backgroundColor:
            isChild ? const Color(0xFF1565C0) : const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 誰の番？
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isChild ? Colors.blue : Colors.orange,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                isChild ? '👧 子どもの番！' : '👨‍👩 お父さん・お母さんの番！',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 実験タイトル
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    q.title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    q.predictionQuestion,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'よそうを選んでね！',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...q.choices.map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selected == null
                          ? () => _selectPrediction(c, isChild: isChild, q: q)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selected == c
                            ? (isChild ? Colors.blue : Colors.orange)
                            : Colors.white,
                        foregroundColor: selected == c
                            ? Colors.white
                            : const Color(0xFF2C3E50),
                        elevation: selected == c ? 4 : 1,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: selected == c
                                ? (isChild ? Colors.blue : Colors.orange)
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      child: Text(c, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                )),
            if (selected != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  '「$selected」を選んだよ！',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _confirmPrediction(isChild: isChild),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isChild ? const Color(0xFF1565C0) : const Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isChild ? '決定！（次は親の番）' : 'バトルスタート！⚔️',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoundReveal() {
    final q = _currentQuestion!;
    final round = _rounds[_currentRound];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('ラウンド ${_currentRound + 1} 結果'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 正解発表
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    q.predictionQuestion,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '正解：${q.correctAnswer}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q.explanation,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 親子の結果
            Row(
              children: [
                Expanded(child: _buildPlayerResult('👧 子ども', round.childPrediction, round.childCorrect, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildPlayerResult('👨‍👩 親', round.parentPrediction, round.parentCorrect, Colors.orange)),
              ],
            ),
            const SizedBox(height: 20),
            // ラウンド勝者
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: round.winner == 'child'
                      ? [Colors.blue.shade400, Colors.blue.shade700]
                      : round.winner == 'parent'
                          ? [Colors.orange.shade400, Colors.orange.shade700]
                          : round.winner == 'draw'
                              ? [Colors.green.shade400, Colors.green.shade700]
                              : [Colors.grey.shade400, Colors.grey.shade700],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                round.winner == 'child'
                    ? '🎉 子どもの勝ち！'
                    : round.winner == 'parent'
                        ? '👏 親の勝ち！'
                        : round.winner == 'draw'
                            ? '🤝 引き分け！ふたりとも正解！'
                            : '😲 ふたりとも外れ…でも学んだね！',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextRound,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentRound + 1 < _totalRounds
                      ? '次のラウンドへ →'
                      : 'バトル結果を見る 🏆',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerResult(
      String name, String prediction, bool isCorrect, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect ? color.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCorrect ? color : Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(prediction, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            isCorrect ? '🎯 正解' : '✗ 外れ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCorrect ? color : Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final result = _battleResult;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('バトル結果 🏆'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              result.getResultMessage(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScoreChip('👧 子ども', result.childTotal, Colors.blue),
                const SizedBox(width: 16),
                const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                _buildScoreChip('親 👨‍👩', result.parentTotal, Colors.orange),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '各ラウンドの結果',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ...result.rounds.asMap().entries.map((e) {
              final i = e.key;
              final r = e.value;
              if (i >= _questions.length) return const SizedBox.shrink();
              final q = _questions[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text('R${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        q.title,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      r.childCorrect ? '👧✓' : '👧✗',
                      style: TextStyle(color: r.childCorrect ? Colors.blue : Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      r.parentCorrect ? '👨‍👩✓' : '👨‍👩✗',
                      style: TextStyle(color: r.parentCorrect ? Colors.orange : Colors.grey),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
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

  Widget _buildScoreChip(String label, int score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '$score点',
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _selectPrediction(String choice,
      {required bool isChild, required PredictionBattleQuestion q}) {
    setState(() {
      if (isChild) {
        _childPrediction = choice;
      } else {
        _parentPrediction = choice;
      }
    });
  }

  void _confirmPrediction({required bool isChild}) {
    if (isChild) {
      setState(() => _childDone = true);
    } else {
      setState(() => _parentDone = true);
      _revealRound();
    }
  }

  void _revealRound() {
    final q = _currentQuestion!;
    final round = BattleRound(
      round: _currentRound + 1,
      questionId: q.id,
      childPrediction: _childPrediction!,
      parentPrediction: _parentPrediction!,
      correctAnswer: q.correctAnswer,
    );
    setState(() {
      _rounds.add(round);
      _roundRevealed = true;
    });
  }

  void _nextRound() {
    if (_currentRound + 1 < _totalRounds && _currentRound + 1 < _questions.length) {
      setState(() {
        _currentRound++;
        _childPrediction = null;
        _parentPrediction = null;
        _childDone = false;
        _parentDone = false;
        _roundRevealed = false;
      });
    } else {
      setState(() => _finished = true);
    }
  }
}
