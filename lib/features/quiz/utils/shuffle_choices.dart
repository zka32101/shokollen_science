import 'dart:math';

/// 問題データの選択肢をシャッフルし、正解の位置(correctAnswerIndex)を付け替えた
/// コピーを返す。元データは「正解が A」に偏っているので、出題時に必ず通す。
Map<String, dynamic> withShuffledAnswers(Map<String, dynamic> q, [Random? rng]) {
  final answers = List<String>.from(q['answers'] as List);
  final correct = q['correctAnswerIndex'] as int;
  if (answers.length < 2 || correct < 0 || correct >= answers.length) {
    return Map<String, dynamic>.from(q);
  }
  final order = List<int>.generate(answers.length, (i) => i)
    ..shuffle(rng ?? Random());
  return {
    ...q,
    'answers': [for (final i in order) answers[i]],
    'correctAnswerIndex': order.indexOf(correct),
  };
}
