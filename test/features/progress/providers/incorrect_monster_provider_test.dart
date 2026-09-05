import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shokollen_science/features/progress/data/repositories/incorrect_monster_repository.dart';
import 'package:shokollen_science/features/progress/models/incorrect_monster.dart';
import 'package:shokollen_science/features/progress/providers/incorrect_monster_provider.dart';

void main() {
  group('IncorrectMonsterNotifier Tests', () {
    late ProviderContainer container;
    late IncorrectMonsterRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = IncorrectMonsterRepositoryImpl(prefs);

      container = ProviderContainer(
        overrides: [
          incorrectMonsterRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    test('初期状態は空リスト', () async {
      await Future.delayed(Duration(milliseconds: 100)); // 初期化待ち
      final state = container.read(incorrectMonstersProvider);
      expect(state, isEmpty);
    });

    test('recordIncorrect で新しいモンスターを追加できる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(incorrectMonstersProvider.notifier);

      await notifier.recordIncorrect(
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: '昆虫のからだのつくり',
      );

      final state = container.read(incorrectMonstersProvider);
      expect(state.length, 1);
      expect(state.first.questionId, 'stage_3_001_q1');
      expect(state.first.monsterName, 'コンチュゃん'); // 自動生成名
    });

    test('同じ questionId では重複して追加しない', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(incorrectMonstersProvider.notifier);

      // 1回目
      await notifier.recordIncorrect(
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Test Q1',
      );

      // 2回目（同じ questionId）
      await notifier.recordIncorrect(
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Test Q1',
      );

      final state = container.read(incorrectMonstersProvider);
      expect(state.length, 1); // 1個のまま
    });

    test('複数のモンスターを追加できる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(incorrectMonstersProvider.notifier);

      await notifier.recordIncorrect(
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await notifier.recordIncorrect(
        questionId: 'stage_3_001_q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        questionTitle: 'Q2',
      );

      final state = container.read(incorrectMonstersProvider);
      expect(state.length, 2);
    });

    test('evolveMonster で correctionsCount が増加する', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(incorrectMonstersProvider.notifier);

      // モンスター作成
      await notifier.recordIncorrect(
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      final beforeState = container.read(incorrectMonstersProvider);
      final monsterId = beforeState.first.id;

      // 進化
      await notifier.evolveMonster(monsterId);

      final afterState = container.read(incorrectMonstersProvider);
      expect(afterState.first.correctionsCount, 1);
      expect(afterState.first.evolutionState, EvolutionState.juvenile);
    });

    test('進化は最大3回までできる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(incorrectMonstersProvider.notifier);

      await notifier.recordIncorrect(
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      final state1 = container.read(incorrectMonstersProvider);
      final monsterId = state1.first.id;

      // 1回目
      await notifier.evolveMonster(monsterId);
      expect(container.read(incorrectMonstersProvider).first.correctionsCount, 1);

      // 2回目
      await notifier.evolveMonster(monsterId);
      expect(container.read(incorrectMonstersProvider).first.correctionsCount, 2);

      // 3回目
      await notifier.evolveMonster(monsterId);
      expect(container.read(incorrectMonstersProvider).first.correctionsCount, 3);

      // 4回目試行（追加されない）
      await notifier.evolveMonster(monsterId);
      expect(container.read(incorrectMonstersProvider).first.correctionsCount, 3);
    });

    test('deleteMonster でモンスターを削除できる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(incorrectMonstersProvider.notifier);

      await notifier.recordIncorrect(
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await notifier.recordIncorrect(
        questionId: 'stage_3_001_q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        questionTitle: 'Q2',
      );

      final state = container.read(incorrectMonstersProvider);
      final firstMonsterId = state.first.id;

      await notifier.deleteMonster(firstMonsterId);

      final afterState = container.read(incorrectMonstersProvider);
      expect(afterState.length, 1);
      expect(afterState.first.id, isNot(firstMonsterId));
    });

    test('hasIncorrectMonster で存在確認ができる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(incorrectMonstersProvider.notifier);

      await notifier.recordIncorrect(
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      expect(await notifier.hasIncorrectMonster('stage_3_001_q1'), true);
      expect(await notifier.hasIncorrectMonster('stage_3_001_q99'), false);
    });

    test('getMonstersForStage で特定ステージのモンスターを取得できる', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(incorrectMonstersProvider.notifier);

      // stage_3_001 に3体
      await notifier.recordIncorrect(
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await notifier.recordIncorrect(
        questionId: 'stage_3_001_q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        questionTitle: 'Q2',
      );

      // stage_3_002 に1体
      await notifier.recordIncorrect(
        questionId: 'stage_3_002_q1',
        stageId: 'stage_3_002',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      final stage1Monsters = notifier.getMonstersForStage('stage_3_001');
      final stage2Monsters = notifier.getMonstersForStage('stage_3_002');

      expect(stage1Monsters.length, 2);
      expect(stage2Monsters.length, 1);
      expect(stage1Monsters.every((m) => m.stageId == 'stage_3_001'), true);
    });

    test('monsterCountProvider で正しい数が返される', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(incorrectMonstersProvider.notifier);

      expect(container.read(monsterCountProvider), 0);

      await notifier.recordIncorrect(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      expect(container.read(monsterCountProvider), 1);

      await notifier.recordIncorrect(
        questionId: 'q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        questionTitle: 'Q2',
      );

      expect(container.read(monsterCountProvider), 2);
    });

    test('monstersByEvolutionProvider で進化段階別の統計が返される', () async {
      await Future.delayed(Duration(milliseconds: 100));

      final notifier = container.read(incorrectMonstersProvider.notifier);

      // 3体のモンスター作成
      await notifier.recordIncorrect(
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        questionTitle: 'Q1',
      );

      await notifier.recordIncorrect(
        questionId: 'q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        questionTitle: 'Q2',
      );

      await notifier.recordIncorrect(
        questionId: 'q3',
        stageId: 'stage_3_001',
        questionNumber: 3,
        questionTitle: 'Q3',
      );

      // 最初のモンスターを1回進化
      final state = container.read(incorrectMonstersProvider);
      await notifier.evolveMonster(state[0].id);

      // 2番目のモンスターを2回進化
      await notifier.evolveMonster(state[1].id);
      await notifier.evolveMonster(state[1].id);

      final stats = container.read(monstersByEvolutionProvider);

      expect(stats[EvolutionState.baby], 1); // q3
      expect(stats[EvolutionState.juvenile], 1); // q1
      expect(stats[EvolutionState.adult], 1); // q2
      expect(stats[EvolutionState.sage], 0);
    });
  });
}
