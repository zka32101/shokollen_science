import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shokollen_science/features/progress/data/repositories/incorrect_monster_repository.dart';
import 'package:shokollen_science/features/progress/models/incorrect_monster.dart';

void main() {
  group('IncorrectMonsterRepository Tests', () {
    late IncorrectMonsterRepository repository;

    setUp(() {
      // SharedPreferences をモックする
      SharedPreferences.setMockInitialValues({});
    });

    test('getAll で空リストが返される（初期状態）', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = IncorrectMonsterRepositoryImpl(prefs);

      final result = await repository.getAll();

      expect(result, isEmpty);
    });

    test('save で新しいモンスターを保存できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = IncorrectMonsterRepositoryImpl(prefs);

      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'stage_3_001_q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テスト',
        firstIncorrectDate: DateTime.now(),
      );

      await repository.save(monster);

      final all = await repository.getAll();
      expect(all.length, 1);
      expect(all.first.id, monster.id);
      expect(all.first.monsterName, monster.monsterName);
    });

    test('複数のモンスターを保存・取得できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = IncorrectMonsterRepositoryImpl(prefs);

      final m1 = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'M1',
        firstIncorrectDate: DateTime.now(),
      );

      final m2 = IncorrectMonster(
        id: 'test-2',
        questionId: 'q2',
        stageId: 'stage_3_002',
        questionNumber: 2,
        monsterName: 'M2',
        firstIncorrectDate: DateTime.now(),
      );

      await repository.save(m1);
      await repository.save(m2);

      final all = await repository.getAll();
      expect(all.length, 2);
      expect(all.map((m) => m.id).toList(), ['test-1', 'test-2']);
    });

    test('getById で指定した ID のモンスターを取得できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = IncorrectMonsterRepositoryImpl(prefs);

      final monster = IncorrectMonster(
        id: 'unique-id-123',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'Target',
        firstIncorrectDate: DateTime.now(),
      );

      await repository.save(monster);

      final result = await repository.getById('unique-id-123');

      expect(result, isNotNull);
      expect(result!.monsterName, 'Target');
    });

    test('getById で存在しない ID は null を返す', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = IncorrectMonsterRepositoryImpl(prefs);

      final result = await repository.getById('nonexistent');

      expect(result, isNull);
    });

    test('getByQuestionId で questionId から検索できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = IncorrectMonsterRepositoryImpl(prefs);

      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'stage_5_007_q3',
        stageId: 'stage_5_007',
        questionNumber: 3,
        monsterName: 'SearchMe',
        firstIncorrectDate: DateTime.now(),
      );

      await repository.save(monster);

      final result = await repository.getByQuestionId('stage_5_007_q3');

      expect(result, isNotNull);
      expect(result!.monsterName, 'SearchMe');
    });

    test('update でモンスターを更新できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = IncorrectMonsterRepositoryImpl(prefs);

      final original = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'Original',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 0,
      );

      await repository.save(original);

      final updated = original.copyWith(
        correctionsCount: 1,
        monsterName: 'Updated',
      );

      await repository.update(updated);

      final result = await repository.getById('test-1');

      expect(result!.monsterName, 'Updated');
      expect(result.correctionsCount, 1);
    });

    test('delete でモンスターを削除できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = IncorrectMonsterRepositoryImpl(prefs);

      final m1 = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'M1',
        firstIncorrectDate: DateTime.now(),
      );

      final m2 = IncorrectMonster(
        id: 'test-2',
        questionId: 'q2',
        stageId: 'stage_3_002',
        questionNumber: 2,
        monsterName: 'M2',
        firstIncorrectDate: DateTime.now(),
      );

      await repository.save(m1);
      await repository.save(m2);
      await repository.delete('test-1');

      final all = await repository.getAll();
      expect(all.length, 1);
      expect(all.first.id, 'test-2');
    });

    test('deleteAll で全モンスターを削除できる', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = IncorrectMonsterRepositoryImpl(prefs);

      final m1 = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'M1',
        firstIncorrectDate: DateTime.now(),
      );

      final m2 = IncorrectMonster(
        id: 'test-2',
        questionId: 'q2',
        stageId: 'stage_3_002',
        questionNumber: 2,
        monsterName: 'M2',
        firstIncorrectDate: DateTime.now(),
      );

      await repository.save(m1);
      await repository.save(m2);
      await repository.deleteAll();

      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('getCount で正しい数を返す', () async {
      final prefs = await SharedPreferences.getInstance();
      repository = IncorrectMonsterRepositoryImpl(prefs);

      expect(await repository.getCount(), 0);

      final m1 = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'M1',
        firstIncorrectDate: DateTime.now(),
      );

      await repository.save(m1);
      expect(await repository.getCount(), 1);

      final m2 = IncorrectMonster(
        id: 'test-2',
        questionId: 'q2',
        stageId: 'stage_3_002',
        questionNumber: 2,
        monsterName: 'M2',
        firstIncorrectDate: DateTime.now(),
      );

      await repository.save(m2);
      expect(await repository.getCount(), 2);

      await repository.delete('test-1');
      expect(await repository.getCount(), 1);
    });
  });
}
