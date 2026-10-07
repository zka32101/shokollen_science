import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/features/quiz/utils/shuffle_choices.dart';

void main() {
  test('シャッフル後も正解の中身は同じ', () {
    final q = {
      'answers': ['頭・胸・腹', '頭・身体・足', '目・口・足', '皮・肉・骨'],
      'correctAnswerIndex': 0,
    };
    for (var s = 0; s < 50; s++) {
      final r = withShuffledAnswers(q, Random(s));
      final a = r['answers'] as List;
      expect(a[r['correctAnswerIndex'] as int], '頭・胸・腹');
      expect(a.toSet(), (q['answers'] as List).toSet());
    }
  });

  test('正解の位置がA〜Dにばらける', () {
    final q = {
      'answers': ['1', '2', '3', '4'],
      'correctAnswerIndex': 0,
    };
    final pos = <int>{};
    for (var s = 0; s < 200; s++) {
      pos.add(withShuffledAnswers(q, Random(s))['correctAnswerIndex'] as int);
    }
    expect(pos, {0, 1, 2, 3});
  });

  test('不正な正解番号のときは元のまま', () {
    final q = {'answers': ['a', 'b'], 'correctAnswerIndex': 5};
    expect(withShuffledAnswers(q)['answers'], ['a', 'b']);
  });
}
