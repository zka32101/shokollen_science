import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/data/quiz_stage_images.dart';
import 'package:shokollen_science/data/seeds/sample_questions.dart';

void main() {
  test('クイズの各ステージに解説画像があり、asset が存在する', () {
    final stageIds =
        sampleQuestionsData.map((q) => q['stageId'] as String).toSet();
    for (final id in stageIds) {
      final path = quizStageImage(id);
      expect(path, isNotNull, reason: id);
      expect(File(path!).existsSync(), isTrue, reason: '$id -> $path');
    }
  });

  test('単元と画像の対応(食い違い修正 2026-10-13)', () {
    expect(quizStageImage('stage_4_008'), contains('quiz/stage_3_011'));
    expect(quizStageImage('stage_5_004'), contains('quiz/stage_5_004'));
    expect(quizStageImage('stage_6_006'), contains('lever'));
    expect(quizStageImage('stage_6_011'), contains('fossils'));
  });
}
