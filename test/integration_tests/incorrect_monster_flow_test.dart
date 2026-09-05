import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shokollen_science/features/progress/data/repositories/incorrect_monster_repository.dart';
import 'package:shokollen_science/features/progress/models/incorrect_monster.dart';
import 'package:shokollen_science/features/progress/providers/incorrect_monster_provider.dart';

void main() {
  group('IncorrectMonster Integration Tests', () {
    late IncorrectMonsterRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = IncorrectMonsterRepositoryImpl(prefs);
    });

    // ────────────────────────────────────────
    // エンドツーエンドのフロー
    // ────────────────────────────────────────

    test('クイズで間違い → モンスター化 → 再挑戦で正解 → 進化 のフロー', () async {
      // ステップ 1: クイズで間違える
      // → システムが自動的にモンスターを作成
      final questionId = 'stage_3_001_q1';
      final monster = IncorrectMonster(
        id: 'monster-1',
        questionId: questionId,
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テストモンスター',
        firstIncorrectDate: DateTime(2026, 7, 2, 10, 0),
      );

      // ステップ 2: モンスターを保存
      await repository.save(monster);

      // 確認: モンスターが保存されている
      var saved = await repository.getByQuestionId(questionId);
      expect(saved, isNotNull);
      expect(saved!.monsterName, 'テストモンスター');
      expect(saved.evolutionState, EvolutionState.baby);
      expect(saved.correctionsCount, 0);

      // ステップ 3: 同じ問題に再挑戦して正解
      final updated = saved.copyWith(
        correctionsCount: 1,
        evolutionState: EvolutionState.juvenile,
        correctionDates: [DateTime(2026, 7, 2, 14, 0)],
      );

      await repository.update(updated);

      // 確認: モンスターが進化している
      var evolved = await repository.getByQuestionId(questionId);
      expect(evolved!.correctionsCount, 1);
      expect(evolved.evolutionState, EvolutionState.juvenile);
      expect(evolved.correctionDates.length, 1);

      // ステップ 4: さらに正解を重ねて最終進化
      final finalForm = evolved.copyWith(
        correctionsCount: 3,
        evolutionState: EvolutionState.sage,
        correctionDates: [
          evolved.correctionDates[0],
          DateTime(2026, 7, 3, 10, 0),
          DateTime(2026, 7, 4, 10, 0),
        ],
      );

      await repository.update(finalForm);

      // 確認: 最終進化している
      var sage = await repository.getByQuestionId(questionId);
      expect(sage!.evolutionState, EvolutionState.sage);
      expect(sage.correctionsCount, 3);
      expect(sage.canEvolve(), false); // これ以上進化できない
    });

    // ────────────────────────────────────────
    // 複数ステージでの進行フロー
    // ────────────────────────────────────────

    test('複数ステージで複数のモンスターを管理', () async {
      // Stage 3-001: 3問間違える
      final monsters_3_001 = [
        IncorrectMonster(
          id: 'm1',
          questionId: 'stage_3_001_q1',
          stageId: 'stage_3_001',
          questionNumber: 1,
          monsterName: 'M1',
          firstIncorrectDate: DateTime(2026, 7, 2, 10, 0),
          correctionsCount: 0,
        ),
        IncorrectMonster(
          id: 'm2',
          questionId: 'stage_3_001_q3',
          stageId: 'stage_3_001',
          questionNumber: 3,
          monsterName: 'M2',
          firstIncorrectDate: DateTime(2026, 7, 2, 11, 0),
          correctionsCount: 1,
        ),
        IncorrectMonster(
          id: 'm3',
          questionId: 'stage_3_001_q5',
          stageId: 'stage_3_001',
          questionNumber: 5,
          monsterName: 'M3',
          firstIncorrectDate: DateTime(2026, 7, 2, 12, 0),
          correctionsCount: 2,
        ),
      ];

      for (final m in monsters_3_001) {
        await repository.save(m);
      }

      // Stage 3-002: 2問間違える
      final monsters_3_002 = [
        IncorrectMonster(
          id: 'm4',
          questionId: 'stage_3_002_q2',
          stageId: 'stage_3_002',
          questionNumber: 2,
          monsterName: 'M4',
          firstIncorrectDate: DateTime(2026, 7, 2, 13, 0),
          correctionsCount: 0,
        ),
        IncorrectMonster(
          id: 'm5',
          questionId: 'stage_3_002_q4',
          stageId: 'stage_3_002',
          questionNumber: 4,
          monsterName: 'M5',
          firstIncorrectDate: DateTime(2026, 7, 2, 14, 0),
          correctionsCount: 1,
        ),
      ];

      for (final m in monsters_3_002) {
        await repository.save(m);
      }

      // 確認: 合計5体
      final all = await repository.getAll();
      expect(all.length, 5);

      // 確認: stage_3_001 に3体
      final stage_3_001 = all.where((m) => m.stageId == 'stage_3_001').toList();
      expect(stage_3_001.length, 3);
      expect(stage_3_001.map((m) => m.correctionsCount).toList(), [0, 1, 2]);

      // 確認: stage_3_002 に2体
      final stage_3_002 = all.where((m) => m.stageId == 'stage_3_002').toList();
      expect(stage_3_002.length, 2);

      // Stage 3-001 のモンスター M1 を進化させる
      final m1_evolved = stage_3_001[0].copyWith(correctionsCount: 1);
      await repository.update(m1_evolved);

      // 確認
      final updated = await repository.getAll();
      final updated_3_001 =
          updated.where((m) => m.stageId == 'stage_3_001').toList();
      expect(
        updated_3_001.map((m) => m.correctionsCount).toList(),
        [1, 1, 2],
      );
    });

    // ────────────────────────────────────────
    // 復習タイムカプセルとの連携
    // ────────────────────────────────────────

    test('タイムカプセル的な復習スケジュール', () async {
      // 初回間違い: 2026-07-02
      final initialWrong = IncorrectMonster(
        id: 'm1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'Test',
        firstIncorrectDate: DateTime(2026, 7, 2, 10, 0),
      );

      await repository.save(initialWrong);

      // 1日後に復習
      var afterDay1 = initialWrong.copyWith(
        correctionsCount: 1,
        evolutionState: EvolutionState.juvenile,
        correctionDates: [DateTime(2026, 7, 3, 10, 0)],
      );

      await repository.update(afterDay1);

      var check1 = await repository.getById('m1');
      expect(check1!.correctionsCount, 1);
      expect(check1.correctionDates.length, 1);

      // 3日後に復習
      var afterDay3 = check1.copyWith(
        correctionsCount: 2,
        evolutionState: EvolutionState.adult,
        correctionDates: [
          ...check1.correctionDates,
          DateTime(2026, 7, 5, 10, 0),
        ],
      );

      await repository.update(afterDay3);

      var check2 = await repository.getById('m1');
      expect(check2!.correctionsCount, 2);
      expect(check2.correctionDates.length, 2);

      // 1週間後に復習
      var afterWeek = check2.copyWith(
        correctionsCount: 3,
        evolutionState: EvolutionState.sage,
        correctionDates: [
          ...check2.correctionDates,
          DateTime(2026, 7, 9, 10, 0),
        ],
      );

      await repository.update(afterWeek);

      var final_check = await repository.getById('m1');
      expect(final_check!.correctionsCount, 3);
      expect(final_check.correctionDates.length, 3);
      expect(final_check.evolutionState, EvolutionState.sage);

      // 復習日の時系列が正しい
      final dates = final_check.correctionDates;
      expect(dates[0].day, 3); // 1日後
      expect(dates[1].day, 5); // 3日後
      expect(dates[2].day, 9); // 1週間後
    });

    // ────────────────────────────────────────
    // 図鑑の統計
    // ────────────────────────────────────────

    test('図鑑統計の整合性', () async {
      // 各進化段階のモンスターを配置
      const config = [
        (stage: 'stage_3_001', q: 1, level: 0), // baby
        (stage: 'stage_3_001', q: 2, level: 1), // juvenile
        (stage: 'stage_3_001', q: 3, level: 2), // adult
        (stage: 'stage_3_002', q: 1, level: 0), // baby
        (stage: 'stage_3_002', q: 2, level: 3), // sage
      ];

      for (int i = 0; i < config.length; i++) {
        final cfg = config[i];
        await repository.save(IncorrectMonster(
          id: 'm$i',
          questionId: '${cfg.stage}_q${cfg.q}',
          stageId: cfg.stage,
          questionNumber: cfg.q,
          monsterName: 'M$i',
          firstIncorrectDate: DateTime.now(),
          correctionsCount: cfg.level,
        ));
      }

      // 全体統計
      final all = await repository.getAll();
      expect(all.length, 5);

      // 進化段階別集計
      final babyCount = all.where((m) => m.correctionsCount == 0).length;
      final juvenileCount = all.where((m) => m.correctionsCount == 1).length;
      final adultCount = all.where((m) => m.correctionsCount == 2).length;
      final sageCount = all.where((m) => m.correctionsCount == 3).length;

      expect(babyCount, 2);
      expect(juvenileCount, 1);
      expect(adultCount, 1);
      expect(sageCount, 1);

      // ステージ別集計
      final stage_3_001 =
          all.where((m) => m.stageId == 'stage_3_001').toList();
      final stage_3_002 =
          all.where((m) => m.stageId == 'stage_3_002').toList();

      expect(stage_3_001.length, 3);
      expect(stage_3_002.length, 2);
    });

    // ────────────────────────────────────────
    // ストレステスト
    // ────────────────────────────────────────

    test('大量のモンスターを管理できる', () async {
      // 1ステージあたり10個、47ステージ = 470体のモンスター
      const totalMonsters = 100; // ここでは100体でテスト

      for (int i = 0; i < totalMonsters; i++) {
        final stageNum = (i ~/ 10) + 1;
        final qNum = (i % 10) + 1;

        await repository.save(IncorrectMonster(
          id: 'm$i',
          questionId: 'stage_3_${stageNum.toString().padLeft(3, '0')}_q$qNum',
          stageId: 'stage_3_${stageNum.toString().padLeft(3, '0')}',
          questionNumber: qNum,
          monsterName: 'Monster_$i',
          firstIncorrectDate: DateTime.now(),
          correctionsCount: i % 4, // 進化段階をローテーション
        ));
      }

      // 確認: すべて保存されている
      final all = await repository.getAll();
      expect(all.length, totalMonsters);

      // 確認: 各ステージでクエリ可能
      for (int stage = 1; stage <= 10; stage++) {
        final stageName =
            'stage_3_${stage.toString().padLeft(3, '0')}';
        final stageMonsters =
            all.where((m) => m.stageId == stageName).toList();
        expect(stageMonsters.length, 10);
      }

      // 確認: カウント機能
      final count = await repository.getCount();
      expect(count, totalMonsters);
    });
  });
}
