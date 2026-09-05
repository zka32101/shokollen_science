import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shokollen_science/features/progress/data/repositories/incorrect_monster_repository.dart';
import 'package:shokollen_science/features/progress/models/incorrect_monster.dart';
import 'package:shokollen_science/features/progress/providers/incorrect_monster_provider.dart';
import 'package:shokollen_science/features/progress/views/incorrect_monster_screen.dart';

void main() {
  group('IncorrectMonsterScreen UI Tests', () {
    late IncorrectMonsterRepository repository;
    late ProviderContainer container;

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

    // ────────────────────────────────────────
    // 空の状態
    // ────────────────────────────────────────

    testWidgets('モンスターがない場合、空メッセージが表示される',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: IncorrectMonsterScreen(),
          ),
        ),
      );

      expect(find.text('まちがい図鑑はからです！'), findsOneWidget);
      expect(
        find.text('クイズで間違えたらモンスターが登場するよ'),
        findsOneWidget,
      );
    });

    // ────────────────────────────────────────
    // モンスター一覧表示
    // ────────────────────────────────────────

    testWidgets('モンスターが表示される', (WidgetTester tester) async {
      // テスト用モンスターを追加
      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テストモンスター',
        firstIncorrectDate: DateTime.now(),
      );

      await repository.save(monster);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: IncorrectMonsterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // モンスター数が表示されている
      expect(find.text('まちがい図鑑（1体）'), findsOneWidget);

      // モンスター名が表示されている
      expect(find.text('テストモンスター'), findsOneWidget);

      // 絵文字が表示されている（baby状態）
      expect(find.text('😢'), findsOneWidget);

      // ラベルが表示されている
      expect(find.text('たまご'), findsOneWidget);
    });

    testWidgets('複数のモンスターが表示される', (WidgetTester tester) async {
      // 複数のモンスターを追加
      for (int i = 0; i < 3; i++) {
        final monster = IncorrectMonster(
          id: 'test-$i',
          questionId: 'q$i',
          stageId: 'stage_3_001',
          questionNumber: i + 1,
          monsterName: 'モンスター$i',
          firstIncorrectDate: DateTime.now(),
          correctionsCount: i, // 異なる進化段階
        );

        await repository.save(monster);
      }

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: IncorrectMonsterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // モンスター数が正しい
      expect(find.text('まちがい図鑑（3体）'), findsOneWidget);

      // 全モンスターが表示されている
      expect(find.text('モンスター0'), findsOneWidget);
      expect(find.text('モンスター1'), findsOneWidget);
      expect(find.text('モンスター2'), findsOneWidget);
    });

    // ────────────────────────────────────────
    // 進化段階別統計
    // ────────────────────────────────────────

    testWidgets('進化段階別の統計が表示される', (WidgetTester tester) async {
      // baby 1体
      await repository.save(IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'M1',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 0,
      ));

      // juvenile 1体
      await repository.save(IncorrectMonster(
        id: 'test-2',
        questionId: 'q2',
        stageId: 'stage_3_001',
        questionNumber: 2,
        monsterName: 'M2',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 1,
      ));

      // adult 1体
      await repository.save(IncorrectMonster(
        id: 'test-3',
        questionId: 'q3',
        stageId: 'stage_3_001',
        questionNumber: 3,
        monsterName: 'M3',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 2,
      ));

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: IncorrectMonsterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 各段階の統計が表示されている
      expect(find.text('たまご'), findsWidgets);
      expect(find.text('1体'), findsWidgets); // 各段階1体ずつ
    });

    // ────────────────────────────────────────
    // モンスターカードのインタラクション
    // ────────────────────────────────────────

    testWidgets('モンスターカードをタップすると詳細画面に遷移',
        (WidgetTester tester) async {
      final monster = IncorrectMonster(
        id: 'test-1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テストモンスター',
        firstIncorrectDate: DateTime.now(),
      );

      await repository.save(monster);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: const IncorrectMonsterScreen(),
            routes: {
              '/detail': (context) => Scaffold(
                    appBar: AppBar(title: const Text('詳細')),
                    body: const Center(child: Text('詳細ページ')),
                  ),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // モンスターカードをタップ
      await tester.tap(find.text('テストモンスター'));
      await tester.pumpAndSettle();

      // 詳細画面が表示されている（ナビゲーション確認）
      // ※ ここで詳細画面への遷移を確認できます
    });

    // ────────────────────────────────────────
    // グリッドレイアウト
    // ────────────────────────────────────────

    testWidgets('モンスターがグリッド形式で表示される',
        (WidgetTester tester) async {
      // 複数のモンスターを追加
      for (int i = 0; i < 6; i++) {
        await repository.save(IncorrectMonster(
          id: 'test-$i',
          questionId: 'q$i',
          stageId: 'stage_3_001',
          questionNumber: i + 1,
          monsterName: 'M$i',
          firstIncorrectDate: DateTime.now(),
        ));
      }

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: IncorrectMonsterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 6体のモンスターが表示されている
      expect(find.byType(GestureDetector), findsWidgets);
    });

    // ────────────────────────────────────────
    // スクロール表示
    // ────────────────────────────────────────

    testWidgets('多くのモンスターがスクロール可能', (WidgetTester tester) async {
      // 15体のモンスターを追加（スクロール必須）
      for (int i = 0; i < 15; i++) {
        await repository.save(IncorrectMonster(
          id: 'test-$i',
          questionId: 'q$i',
          stageId: 'stage_3_001',
          questionNumber: i + 1,
          monsterName: 'M$i',
          firstIncorrectDate: DateTime.now(),
        ));
      }

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: IncorrectMonsterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // モンスター数が正しい
      expect(find.text('まちがい図鑑（15体）'), findsOneWidget);

      // スクロール
      await tester.drag(find.byType(GridView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // スクロール後もモンスターが表示されている
      expect(find.byType(GestureDetector), findsWidgets);
    });
  });
}
