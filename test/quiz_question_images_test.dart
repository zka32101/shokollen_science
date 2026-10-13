import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/data/quiz_stage_images.dart';
import 'package:shokollen_science/data/seeds/sample_questions.dart';

void main() {
  test('問題画像マップの各 asset が存在し、実在する問題に対応する', () {
    final keys = sampleQuestionsData
        .map((q) => quizQuestionImageKey(
            q['stageId'] as String, q['questionNumber'] as int))
        .toSet();
    expect(quizQuestionImages, isNotEmpty);
    quizQuestionImages.forEach((key, path) {
      expect(keys, contains(key), reason: key);
      expect(File(path).existsSync(), isTrue, reason: path);
    });
  });

  test('問題画像を優先し、無ければステージ画像に戻る', () {
    expect(quizQuestionOrStageImage('stage_5_007', 4),
        quizQuestionImages['stage_5_007_q4']);
    expect(quizQuestionOrStageImage('stage_5_007', 1),
        quizStageImage('stage_5_007'));
    expect(quizQuestionOrStageImage('stage_x', 1), isNull);
  });
}
