import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/features/progress/models/incorrect_monster.dart';

void main() {
  group('IncorrectMonster Model Tests', () {
    // ────────────────────────────────────────
    // 基本的な生成テスト
    // ────────────────────────────────────────

    test('初期状態は baby で、correctionsCount は 0', () {
      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テストモンスター',
        firstIncorrectDate: DateTime(2026, 7, 2),
      );

      expect(monster.evolutionState, EvolutionState.baby);
      expect(monster.correctionsCount, 0);
      expect(monster.correctionDates, isEmpty);
    });

    test('monsterName と stageId が正しく保存される', () {
      final now = DateTime.now();
      final monster = IncorrectMonster(
        id: 'test-2',
        questionId: 'stage_4_005_q3',
        stageId: 'stage_4_005',
        questionNumber: 3,
        monsterName: 'コムシちゃん',
        firstIncorrectDate: now,
      );

      expect(monster.monsterName, 'コムシちゃん');
      expect(monster.stageId, 'stage_4_005');
      expect(monster.questionNumber, 3);
      expect(monster.firstIncorrectDate, now);
    });

    // ────────────────────────────────────────
    // 進化状態判定テスト
    // ────────────────────────────────────────

    test('correctionsCount = 0 で getEvolutionState() は baby', () {
      final monster = IncorrectMonster(
        id: 'test-3',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'test',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 0,
      );

      expect(monster.getEvolutionState(), EvolutionState.baby);
    });

    test('correctionsCount = 1 で getEvolutionState() は juvenile', () {
      final monster = IncorrectMonster(
        id: 'test-4',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'test',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 1,
      );

      expect(monster.getEvolutionState(), EvolutionState.juvenile);
    });

    test('correctionsCount = 2 で getEvolutionState() は adult', () {
      final monster = IncorrectMonster(
        id: 'test-5',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'test',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 2,
      );

      expect(monster.getEvolutionState(), EvolutionState.adult);
    });

    test('correctionsCount = 3 で getEvolutionState() は sage', () {
      final monster = IncorrectMonster(
        id: 'test-6',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'test',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 3,
      );

      expect(monster.getEvolutionState(), EvolutionState.sage);
    });

    test('correctionsCount > 3 でも getEvolutionState() は sage（上限）', () {
      final monster = IncorrectMonster(
        id: 'test-7',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'test',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 5,
      );

      expect(monster.getEvolutionState(), EvolutionState.sage);
    });

    // ────────────────────────────────────────
    // 進化可能判定テスト
    // ────────────────────────────────────────

    test('correctionsCount < 3 で canEvolve() は true', () {
      for (int count = 0; count < 3; count++) {
        final monster = IncorrectMonster(
          id: 'test-$count',
          questionId: 'q1',
          stageId: 'stage_3_001',
          questionNumber: 1,
          monsterName: 'test',
          firstIncorrectDate: DateTime.now(),
          correctionsCount: count,
        );

        expect(monster.canEvolve(), true, reason: 'count=$count');
      }
    });

    test('correctionsCount >= 3 で canEvolve() は false', () {
      for (int count = 3; count <= 5; count++) {
        final monster = IncorrectMonster(
          id: 'test-$count',
          questionId: 'q1',
          stageId: 'stage_3_001',
          questionNumber: 1,
          monsterName: 'test',
          firstIncorrectDate: DateTime.now(),
          correctionsCount: count,
        );

        expect(monster.canEvolve(), false, reason: 'count=$count');
      }
    });

    // ────────────────────────────────────────
    // 次の進化段階判定テスト
    // ────────────────────────────────────────

    test('correctionsCount = 0 の次は juvenile', () {
      final monster = IncorrectMonster(
        id: 'test-8',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'test',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 0,
      );

      expect(monster.getNextEvolutionState(), EvolutionState.juvenile);
    });

    test('correctionsCount = 1 の次は adult', () {
      final monster = IncorrectMonster(
        id: 'test-9',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'test',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 1,
      );

      expect(monster.getNextEvolutionState(), EvolutionState.adult);
    });

    test('correctionsCount = 2 の次は sage', () {
      final monster = IncorrectMonster(
        id: 'test-10',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'test',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 2,
      );

      expect(monster.getNextEvolutionState(), EvolutionState.sage);
    });

    test('correctionsCount >= 3 の次は null', () {
      for (int count = 3; count <= 5; count++) {
        final monster = IncorrectMonster(
          id: 'test-$count',
          questionId: 'q1',
          stageId: 'stage_3_001',
          questionNumber: 1,
          monsterName: 'test',
          firstIncorrectDate: DateTime.now(),
          correctionsCount: count,
        );

        expect(monster.getNextEvolutionState(), null, reason: 'count=$count');
      }
    });

    // ────────────────────────────────────────
    // 次の進化までの必要正解数
    // ────────────────────────────────────────

    test('correctionsNeededForNextEvolve() は (3 - correctionsCount)', () {
      final testCases = [
        (0, 3),
        (1, 2),
        (2, 1),
        (3, 0),
      ];

      for (final (count, expected) in testCases) {
        final monster = IncorrectMonster(
          id: 'test-$count',
          questionId: 'q1',
          stageId: 'stage_3_001',
          questionNumber: 1,
          monsterName: 'test',
          firstIncorrectDate: DateTime.now(),
          correctionsCount: count,
        );

        expect(
          monster.correctionsNeededForNextEvolve(),
          expected,
          reason: 'count=$count, expected=$expected',
        );
      }
    });

    // ────────────────────────────────────────
    // copyWith テスト
    // ────────────────────────────────────────

    test('copyWith で correctionsCount を更新できる', () {
      final monster = IncorrectMonster(
        id: 'test-11',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'test',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 0,
      );

      final updated = monster.copyWith(correctionsCount: 1);

      expect(monster.correctionsCount, 0); // 元は変わらない
      expect(updated.correctionsCount, 1); // 新しいオブジェクトは更新されている
      expect(updated.id, monster.id); // 他のフィールドは維持
      expect(updated.monsterName, monster.monsterName);
    });

    test('copyWith で correctionDates を追加できる', () {
      final now = DateTime.now();
      final monster = IncorrectMonster(
        id: 'test-12',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'test',
        firstIncorrectDate: DateTime.now(),
        correctionDates: [],
      );

      final updated = monster.copyWith(
        correctionDates: [...monster.correctionDates, now],
      );

      expect(monster.correctionDates, isEmpty);
      expect(updated.correctionDates.length, 1);
      expect(updated.correctionDates.first, now);
    });

    // ────────────────────────────────────────
    // JSON シリアライゼーション
    // ────────────────────────────────────────

    test('fromJson と toJson でラウンドトリップ可能', () {
      final original = IncorrectMonster(
        id: 'test-13',
        questionId: 'stage_5_003_q7',
        stageId: 'stage_5_003',
        questionNumber: 7,
        monsterName: 'ハナコちゃん',
        firstIncorrectDate: DateTime(2026, 7, 2, 10, 30),
        correctionsCount: 2,
        evolutionState: EvolutionState.adult,
        correctionDates: [
          DateTime(2026, 7, 3),
          DateTime(2026, 7, 4),
        ],
      );

      final json = original.toJson();
      final restored = IncorrectMonster.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.questionId, original.questionId);
      expect(restored.stageId, original.stageId);
      expect(restored.questionNumber, original.questionNumber);
      expect(restored.monsterName, original.monsterName);
      expect(restored.correctionsCount, original.correctionsCount);
      expect(restored.evolutionState, original.evolutionState);
      expect(restored.correctionDates.length, original.correctionDates.length);
    });

    // ────────────────────────────────────────
    // EvolutionState Extension テスト
    // ────────────────────────────────────────

    test('EvolutionState.emoji が正しい絵文字を返す', () {
      expect(EvolutionState.baby.emoji, '😢');
      expect(EvolutionState.juvenile.emoji, '😕');
      expect(EvolutionState.adult.emoji, '😐');
      expect(EvolutionState.sage.emoji, '😊');
    });

    test('EvolutionState.label が正しいラベルを返す', () {
      expect(EvolutionState.baby.label, 'たまご');
      expect(EvolutionState.juvenile.label, '幼生');
      expect(EvolutionState.adult.label, '成体');
      expect(EvolutionState.sage.label, '博士');
    });

    test('EvolutionState.progressPercent が正しいパーセンテージを返す', () {
      expect(EvolutionState.baby.progressPercent, 0);
      expect(EvolutionState.juvenile.progressPercent, 33);
      expect(EvolutionState.adult.progressPercent, 66);
      expect(EvolutionState.sage.progressPercent, 100);
    });
  });
}
