// ⑨ 親子バトル化：予想バトル問題（5ラウンド用）
// 親子が同じ実験の結果を予想し、当たった方が勝ち

class PredictionBattleQuestion {
  final String id;
  final int round; // 1-5
  final String experimentId;
  final String title; // 「磁石と鉄」
  final String predictionQuestion; // 「くぎは磁石につくかな？」
  final List<String> choices;
  final String correctAnswer;
  final String explanation;

  const PredictionBattleQuestion({
    required this.id,
    required this.round,
    required this.experimentId,
    required this.title,
    required this.predictionQuestion,
    required this.choices,
    required this.correctAnswer,
    required this.explanation,
  });
}

final predictionBattleQuestions = [
  PredictionBattleQuestion(
    id: 'pb_001',
    round: 1,
    experimentId: 'exp_001',
    title: '磁石と鉄',
    predictionQuestion: 'くぎは磁石につくかな？',
    choices: ['つく', 'つかない', 'わからない'],
    correctAnswer: 'つく',
    explanation:
        '磁石には見えない力があって、くぎなどの鉄をひきつけるんだよ。',
  ),
  PredictionBattleQuestion(
    id: 'pb_002',
    round: 2,
    experimentId: 'exp_002',
    title: '光と影',
    predictionQuestion: '太陽が動くと、影はどうなるかな？',
    choices: ['影も一緒に動く', '影は動かない', 'わからない'],
    correctAnswer: '影も一緒に動く',
    explanation:
        '光の方向が変わると、影の向きと長さも変わるんだね。',
  ),
  PredictionBattleQuestion(
    id: 'pb_003',
    round: 3,
    experimentId: 'exp_003',
    title: '音の振動',
    predictionQuestion: 'スピーカーの前に砂をまくと、砂はどうなるかな？',
    choices: ['砂が動く', '砂は動かない', 'わからない'],
    correctAnswer: '砂が動く',
    explanation:
        '音は振動。その振動が砂を揺らして、砂が跳ねるんだよ。',
  ),
  PredictionBattleQuestion(
    id: 'pb_004',
    round: 4,
    experimentId: 'exp_004',
    title: '力のはたらき',
    predictionQuestion: 'てこで重い石を持ち上げるには、どこに支点を置く？',
    choices: [
      '石に近い位置',
      '力を入れる場所に近い位置',
      'わからない',
    ],
    correctAnswer: '力を入れる場所に近い位置',
    explanation:
        '支点が力の場所に近いほど、大きな力が出せるんだね。',
  ),
  PredictionBattleQuestion(
    id: 'pb_005',
    round: 5,
    experimentId: 'exp_005',
    title: '水の性質',
    predictionQuestion: '水に塩を入れると、水は？',
    choices: [
      'へんな色になる',
      '塩が溶けて、塩辛くなる',
      'わからない',
    ],
    correctAnswer: '塩が溶けて、塩辛くなる',
    explanation:
        '水に塩を入れると、塩の粒が細かくなって、塩水になるんだよ。',
  ),

  // ========== 以降もスケール追加（5問のセットを複数用意）
  // 親子バトル用に、5ラウンドごとに異なる問題セットを準備

  PredictionBattleQuestion(
    id: 'pb_006',
    round: 1,
    experimentId: 'exp_006',
    title: '電気と回路',
    predictionQuestion: '豆電球を二つつなぐと、電気はどうなるかな？',
    choices: [
      '二つとも通常に光る',
      '二つとも薄く光る',
      'わからない',
    ],
    correctAnswer: '二つとも薄く光る',
    explanation:
        '電気が二つに分かれるから、一つあたりの電気が弱くなるんだね。',
  ),
  PredictionBattleQuestion(
    id: 'pb_007',
    round: 2,
    experimentId: 'exp_007',
    title: '水溶液の性質',
    predictionQuestion: 'あたたかい水と冷たい水、砂糖はどちらが速く溶ける？',
    choices: [
      'あたたかい水',
      '冷たい水',
      'わからない',
    ],
    correctAnswer: 'あたたかい水',
    explanation:
        'あたたかいほど、砂糖の粒が動きやすくなって、速く溶けるんだよ。',
  ),
];

// バトル用の便利な関数
List<PredictionBattleQuestion> getBattleQuestionsForRound(int round) {
  return predictionBattleQuestions
      .where((q) => q.round == round)
      .toList();
}

PredictionBattleQuestion? getBattleQuestion(String questionId) {
  try {
    return predictionBattleQuestions
        .firstWhere((q) => q.id == questionId);
  } catch (e) {
    return null;
  }
}

List<PredictionBattleQuestion> getRandomBattleQuestions(int count) {
  final shuffled = List.of(predictionBattleQuestions);
  shuffled.shuffle();
  return shuffled.take(count).toList();
}

// バトル結果判定
class BattleRound {
  final int round;
  final String questionId;
  final String childPrediction;
  final String parentPrediction;
  final String correctAnswer;

  BattleRound({
    required this.round,
    required this.questionId,
    required this.childPrediction,
    required this.parentPrediction,
    required this.correctAnswer,
  });

  bool get childCorrect => childPrediction == correctAnswer;
  bool get parentCorrect => parentPrediction == correctAnswer;

  String get winner {
    if (childCorrect && !parentCorrect) return 'child';
    if (parentCorrect && !childCorrect) return 'parent';
    if (childCorrect && parentCorrect) return 'draw';
    return 'neither'; // どちらも外れ
  }

  int get childScore => childCorrect ? 1 : 0;
  int get parentScore => parentCorrect ? 1 : 0;
}

class BattleResult {
  final List<BattleRound> rounds;
  final int childTotal;
  final int parentTotal;

  BattleResult({
    required this.rounds,
    required this.childTotal,
    required this.parentTotal,
  });

  String get battleWinner =>
      childTotal > parentTotal
          ? 'child'
          : parentTotal > childTotal
          ? 'parent'
          : 'draw';

  String getResultMessage() {
    if (battleWinner == 'child') {
      return 'やったー！子どもの勝ち！🎉';
    } else if (battleWinner == 'parent') {
      return 'お父さん・お母さんの勝ち！さすが！👏';
    } else {
      return '同点！親子で力を合わせた証拠だね！💪';
    }
  }
}
