import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shokollen_science/features/progress/data/repositories/daily_mystery_repository.dart';
import 'package:shokollen_science/features/progress/providers/daily_mystery_provider.dart';
import 'package:shokollen_science/features/progress/views/daily_mystery_omikuji_screen.dart';

void main() {
  group('DailyMysteryOmikujiScreen Widget Tests', () {
    late ProviderContainer container;
    late DailyMysteryRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = DailyMysteryRepositoryImpl(prefs);

      container = ProviderContainer(
        overrides: [
          dailyMysteryRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    testWidgets('Screen displays omikuji animation button initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DailyMysteryOmikujiScreen(),
          ),
        ),
      );

      expect(find.text('おみくじを引く'), findsOneWidget);
      expect(find.text('🤔'), findsWidgets);
      expect(find.text('📿 今日のふしぎ'), findsOneWidget);
    });

    testWidgets('Mystery question appears after reveal button tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DailyMysteryOmikujiScreen(),
          ),
        ),
      );

      final button = find.byType(ElevatedButton).first;
      await tester.tap(button);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('後で見る'), findsOneWidget);
      expect(find.text('すぐに答えを見る'), findsOneWidget);
    });

    testWidgets('Answer is revealed when answer button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DailyMysteryOmikujiScreen(),
          ),
        ),
      );

      final revealButton = find.byType(ElevatedButton).first;
      await tester.tap(revealButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final answerButton = find.byType(ElevatedButton).first;
      await tester.tap(answerButton);
      await tester.pumpAndSettle();

      expect(find.text('💡'), findsWidgets);
      expect(find.text('ホームに戻る'), findsOneWidget);
    });

    testWidgets('Back to home button closes the screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DailyMysteryOmikujiScreen(),
          ),
        ),
      );

      final revealButton = find.byType(ElevatedButton).first;
      await tester.tap(revealButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final answerButton = find.byType(ElevatedButton).first;
      await tester.tap(answerButton);
      await tester.pumpAndSettle();

      final homeButton = find.byType(ElevatedButton).first;
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      // Screen should pop
      expect(find.byType(DailyMysteryOmikujiScreen), findsNothing);
    });

    testWidgets('AppBar displays correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DailyMysteryOmikujiScreen(),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('📿 今日のふしぎ'), findsOneWidget);
    });

    testWidgets('Category and grade display on revealed question',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DailyMysteryOmikujiScreen(),
          ),
        ),
      );

      final button = find.byType(ElevatedButton).first;
      await tester.tap(button);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check for category and grade information
      expect(find.text('🏷️'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Post-answer state shows "ホームに戻る" button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DailyMysteryOmikujiScreen(),
          ),
        ),
      );

      final revealButton = find.byType(ElevatedButton).first;
      await tester.tap(revealButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final answerButton = find.byType(ElevatedButton).first;
      await tester.tap(answerButton);
      await tester.pumpAndSettle();

      expect(find.text('ホームに戻る'), findsOneWidget);
      expect(find.text('すぐに答えを見る'), findsNothing);
    });

    testWidgets('Scroll works on the screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DailyMysteryOmikujiScreen(),
          ),
        ),
      );

      final revealButton = find.byType(ElevatedButton).first;
      await tester.tap(revealButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final answerButton = find.byType(ElevatedButton).first;
      await tester.tap(answerButton);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Animation completes before showing question',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DailyMysteryOmikujiScreen(),
          ),
        ),
      );

      final button = find.byType(ElevatedButton).first;
      await tester.tap(button);

      // After 100ms, animation should be in progress
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('後で見る'), findsNothing);

      // After animation completes
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('後で見る'), findsOneWidget);
    });
  });
}
