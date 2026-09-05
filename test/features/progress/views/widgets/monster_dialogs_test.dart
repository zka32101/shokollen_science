import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/features/progress/models/incorrect_monster.dart';
import 'package:shokollen_science/features/progress/views/widgets/monster_dialogs.dart';

void main() {
  group('Monster Dialogs UI Tests', () {
    // ────────────────────────────────────────
    // MonsterGetDialog テスト
    // ────────────────────────────────────────

    testWidgets('MonsterGetDialog が表示される', (WidgetTester tester) async {
      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テストモンスター',
        firstIncorrectDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonsterGetDialog(monster: monster),
          ),
        ),
      );

      // タイトルが表示されている
      expect(find.text('このモンスターをあなたのともだちにしよう！'), findsOneWidget);

      // モンスター名が表示されている
      expect(find.text('テストモンスター'), findsOneWidget);

      // 絵文字が表示されている
      expect(find.text('😢'), findsOneWidget);

      // ボタンが表示されている
      expect(find.text('まちがい図鑑をみる'), findsOneWidget);
    });

    testWidgets('MonsterGetDialog のボタンをタップできる', (WidgetTester tester) async {
      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テスト',
        firstIncorrectDate: DateTime.now(),
      );

      bool onDismissCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonsterGetDialog(
              monster: monster,
              onDismiss: () {
                onDismissCalled = true;
              },
            ),
          ),
        ),
      );

      // ボタンをタップ
      await tester.tap(find.text('まちがい図鑑をみる'));
      await tester.pumpAndSettle();

      expect(onDismissCalled, true);
    });

    testWidgets('MonsterGetDialog で異なるモンスターを表示', (WidgetTester tester) async {
      final monster = IncorrectMonster(
        id: 'test-2',
        questionId: 'q2',
        stageId: 'stage_4_005',
        questionNumber: 5,
        monsterName: 'ハナコちゃん',
        firstIncorrectDate: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonsterGetDialog(monster: monster),
          ),
        ),
      );

      expect(find.text('ハナコちゃん'), findsOneWidget);
      expect(find.text('stage_4_005'), findsNothing); // stageId は表示されない
    });

    // ────────────────────────────────────────
    // MonsterEvolutionDialog テスト
    // ────────────────────────────────────────

    testWidgets('MonsterEvolutionDialog が表示される', (WidgetTester tester) async {
      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テスト',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MonsterEvolutionDialog(monster: monster),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // タイトルが表示されている
      expect(find.text('テストが進化した！'), findsOneWidget);

      // 進化前の絵文字
      expect(find.text('😢'), findsWidgets);

      // 進化後の絵文字
      expect(find.text('😕'), findsWidgets);

      // OK ボタン
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('MonsterEvolutionDialog で進化度が表示される', (WidgetTester tester) async {
      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テスト',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 2,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MonsterEvolutionDialog(monster: monster),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 進化度の表示
      expect(find.text('2/3'), findsOneWidget);
    });

    testWidgets('MonsterEvolutionDialog でモンスター名が正しく表示される',
        (WidgetTester tester) async {
      final monster = IncorrectMonster(
        id: 'test-123',
        questionId: 'q1',
        stageId: 'stage_5_003',
        questionNumber: 1,
        monsterName: 'コムシちゃん',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MonsterEvolutionDialog(monster: monster),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('コムシちゃんが進化した！'), findsOneWidget);
    });

    testWidgets('MonsterEvolutionDialog で最終進化時のメッセージが表示される',
        (WidgetTester tester) async {
      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テスト',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 3, // 最終進化
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MonsterEvolutionDialog(monster: monster),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('博士になりました！'), findsOneWidget);
      expect(find.text('これ以上進化しません。'), findsOneWidget);
    });

    // ────────────────────────────────────────
    // MonsterStatusDialog テスト
    // ────────────────────────────────────────

    testWidgets('MonsterStatusDialog が表示される', (WidgetTester tester) async {
      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'ハナコちゃん',
        firstIncorrectDate: DateTime(2026, 7, 2, 10, 30),
        correctionsCount: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MonsterStatusDialog(monster: monster),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // モンスター名
      expect(find.text('ハナコちゃん'), findsOneWidget);

      // 絵文字
      expect(find.text('😕'), findsOneWidget);

      // 段階ラベル
      expect(find.text('幼生'), findsOneWidget);

      // 進度表示
      expect(find.text('1/3'), findsOneWidget);
    });

    testWidgets('MonsterStatusDialog で日時が正しく表示される',
        (WidgetTester tester) async {
      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テスト',
        firstIncorrectDate: DateTime(2026, 7, 15, 14, 30),
        correctionsCount: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MonsterStatusDialog(monster: monster),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 日付フォーマット: YYYY-MM-DD
      expect(find.text('2026-07-15'), findsOneWidget);
    });

    testWidgets('MonsterStatusDialog でとじるボタンが機能する',
        (WidgetTester tester) async {
      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テスト',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MonsterStatusDialog(monster: monster),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // とじるボタンを検索
      final closeButton = find.text('とじる');
      expect(closeButton, findsOneWidget);

      // ボタンをタップ
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // ダイアログが閉じられている
      expect(find.text('モンスター詳細'), findsNothing);
    });

    // ────────────────────────────────────────
    // EvolutionState Extension テスト
    // ────────────────────────────────────────

    test('EvolutionState.emoji が正しい', () {
      expect(EvolutionState.baby.emoji, '😢');
      expect(EvolutionState.juvenile.emoji, '😕');
      expect(EvolutionState.adult.emoji, '😐');
      expect(EvolutionState.sage.emoji, '😊');
    });

    test('EvolutionState.label が正しい', () {
      expect(EvolutionState.baby.label, 'たまご');
      expect(EvolutionState.juvenile.label, '幼生');
      expect(EvolutionState.adult.label, '成体');
      expect(EvolutionState.sage.label, '博士');
    });
  });
}
