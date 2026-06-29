// ⑥ 失敗ラボ推理拡張：トラブルシューティング問題データ
// 各実験の「失敗の原因を推理する」問題 20実験 × 5問 = 100問

class TroubleshootQuestion {
  final String id;
  final String experimentId;
  final int difficulty; // 1-5
  final String scenario; // 問題文
  final List<String> choices;
  final String correctAnswer;
  final String explanation; // 解説

  const TroubleshootQuestion({
    required this.id,
    required this.experimentId,
    required this.difficulty,
    required this.scenario,
    required this.choices,
    required this.correctAnswer,
    required this.explanation,
  });
}

final troubleshootQuestions = [
  // ========== 3年生 実験 ==========

  // exp_001: 磁石と鉄
  TroubleshootQuestion(
    id: 'ts_001_01',
    experimentId: 'exp_001',
    difficulty: 1,
    scenario: '磁石でくぎを持ち上げようとしたけど、くぎが落ちちゃった。なぜ？',
    choices: [
      '磁石の力が弱くなってた',
      '磁石の向きが反対だった',
      'くぎが磁石にくっつかない材質だった',
    ],
    correctAnswer: '磁石の力が弱くなってた',
    explanation: '磁石の力には限界があります。重いものはくぎが落ちちゃう。',
  ),
  TroubleshootQuestion(
    id: 'ts_001_02',
    experimentId: 'exp_001',
    difficulty: 2,
    scenario: 'アルミホイルを磁石に近づけたけど、くっつかない。なぜ？',
    choices: [
      '磁石が壊れてた',
      'アルミは磁石に吸いつかない材質',
      'アルミの方が強い',
    ],
    correctAnswer: 'アルミは磁石に吸いつかない材質',
    explanation: '磁石は鉄にはくっつくけど、アルミ・銀・金にはくっつかない。',
  ),
  TroubleshootQuestion(
    id: 'ts_001_03',
    experimentId: 'exp_001',
    difficulty: 2,
    scenario: 'きのう磁石がいっぱいくぎを持ち上げたのに、きょうは1個だけ。なぜ？',
    choices: [
      '磁石の向きが逆になった',
      '磁石の力が徐々に弱くなってた',
      'くぎの種類が違った',
    ],
    correctAnswer: '磁石の力が徐々に弱くなってた',
    explanation:
        '磁石は何度も使ったり、強くぶつけたりすると、だんだん弱くなる。',
  ),
  TroubleshootQuestion(
    id: 'ts_001_04',
    experimentId: 'exp_001',
    difficulty: 3,
    scenario: 'S極とN極を逆に重ねたら、磁石同士が反発した。これって磁石が壊れた？',
    choices: [
      'はい、磁石が壊れた',
      'いいえ、これが磁石の力です',
      '一時的に壊れてる',
    ],
    correctAnswer: 'いいえ、これが磁石の力です',
    explanation: '同じ極同士は反発する。これは磁力がちゃんと働いてる証拠！',
  ),
  TroubleshootQuestion(
    id: 'ts_001_05',
    experimentId: 'exp_001',
    difficulty: 3,
    scenario: '磁石を水に入れたら、くぎへの力が半分になった。なぜ？',
    choices: [
      '磁石が濡れると力が弱くなる',
      '水が磁力を弱くする',
      '水中では磁力が弱く見える（実際は変わってない）',
    ],
    correctAnswer: '水中では磁力が弱く見える（実際は変わってない）',
    explanation:
        '水の影響で見かけ上弱く見えるけど、磁力そのものは変わってない。',
  ),

  // exp_002: 光と影
  TroubleshootQuestion(
    id: 'ts_002_01',
    experimentId: 'exp_002',
    difficulty: 1,
    scenario: 'グラウンドで午前中に影の実験をしたけど、午後もやったら影の長さが違った。',
    choices: [
      '太陽が動いた',
      '物の向きが変わった',
      '光の速度が変わった',
    ],
    correctAnswer: '太陽が動いた',
    explanation: '太陽は1日の中で位置が変わる。だから影の長さも向きも変わる。',
  ),
  TroubleshootQuestion(
    id: 'ts_002_02',
    experimentId: 'exp_002',
    difficulty: 2,
    scenario: '懐中電灯で影を作ったけど、影がぼやけてて線がくっきり出ない。',
    choices: [
      '懐中電灯の電池が弱い',
      '光の源が大きすぎる',
      'スクリーンが曲がってる',
    ],
    correctAnswer: '光の源が大きすぎる',
    explanation: '懐中電灯の光が広がると、影の縁がぼやける。',
  ),

  // exp_003: 音の振動
  TroubleshootQuestion(
    id: 'ts_003_01',
    experimentId: 'exp_003',
    difficulty: 1,
    scenario: 'スピーカーから出た音が聞こえなくなった。なぜ？',
    choices: [
      '電源が切れてた',
      '音量ボタンがゼロになってた',
      'スピーカーが壊れた',
    ],
    correctAnswer: '電源が切れてた',
    explanation: 'スピーカーが動いてなければ音も出ない。',
  ),
  TroubleshootQuestion(
    id: 'ts_003_02',
    experimentId: 'exp_003',
    difficulty: 2,
    scenario: 'ボール紙に砂をのせてスピーカーに置いたけど、砂が動かない。',
    choices: [
      '周波数が低すぎる',
      '音量が小さすぎる',
      '砂が重すぎる',
    ],
    correctAnswer: '音量が小さすぎる',
    explanation: '音の振動が砂を動かすには、十分な大きさの音が必要。',
  ),

  // exp_004: 力のはたらき
  TroubleshootQuestion(
    id: 'ts_004_01',
    experimentId: 'exp_004',
    difficulty: 1,
    scenario: 'てこで重い石を持ち上げられなかった。なぜ？',
    choices: [
      '支点の位置が悪かった',
      '石が重すぎた',
      '木の棒が弱かった',
    ],
    correctAnswer: '支点の位置が悪かった',
    explanation:
        'てこの支点が持ち上げたい物に近いと、力が必要。支点を遠ざけるといい。',
  ),

  // exp_005: 水の性質
  TroubleshootQuestion(
    id: 'ts_005_01',
    experimentId: 'exp_005',
    difficulty: 1,
    scenario: 'ビーカーにこぼした水が床を濡らした。なぜ水は広がるの？',
    choices: [
      '水が自分で動いてる',
      '重力で流れて広がった',
      '風が吹いてた',
    ],
    correctAnswer: '重力で流れて広がった',
    explanation: '水は重力に従って、低い方へ流れ落ちる。',
  ),

  // ========== 4年生 実験 ==========

  // exp_006: 電気と回路
  TroubleshootQuestion(
    id: 'ts_006_01',
    experimentId: 'exp_006',
    difficulty: 1,
    scenario: '豆電球の回路を作ったけど、豆電球がつかない。なぜ？',
    choices: [
      '電池の向きが反対',
      '導線が途中で切れてる',
      '豆電球のソケットがゆるい',
      '全部当てはまる可能性',
    ],
    correctAnswer: '全部当てはまる可能性',
    explanation:
        'つかない理由は複数ある。1つずつ確認する必要がある（トラブルシューティング！）',
  ),

  // exp_007: 水溶液の性質
  TroubleshootQuestion(
    id: 'ts_007_01',
    experimentId: 'exp_007',
    difficulty: 2,
    scenario: '砂糖を水に入れたけど、全く溶けない。なぜ？',
    choices: [
      '砂糖が壊れてた',
      '水の温度が低い',
      '砂糖の粒が大きすぎる',
    ],
    correctAnswer: '水の温度が低い',
    explanation: 'あたたかい水ほど、砂糖がよく溶ける。',
  ),

  // ========== 以降も同様に各実験 exp_008～exp_020 の問題データを追加

  // クイズとしての簡潔性を保つため、ここでは代表例を掲載
  // 実装時に全20実験 × 5問を完成させる
];

// 便利な関数
TroubleshootQuestion? getTroubleshootQuestion(String questionId) {
  try {
    return troubleshootQuestions.firstWhere((q) => q.id == questionId);
  } catch (e) {
    return null;
  }
}

List<TroubleshootQuestion> getTroubleshootQuestionsByExperiment(
    String experimentId) {
  return troubleshootQuestions
      .where((q) => q.experimentId == experimentId)
      .toList();
}

List<TroubleshootQuestion> getTroubleshootQuestionsByDifficulty(
    int difficulty) {
  return troubleshootQuestions.where((q) => q.difficulty == difficulty).toList();
}
