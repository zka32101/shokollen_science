import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shokollen_science/features/progress/data/repositories/daily_mystery_repository.dart';
import 'package:shokollen_science/features/progress/providers/daily_mystery_provider.dart';

void main() {
  group('DailyMysteryNotifier Tests', () {
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

    test('初期状態は null', () async {
      await Future.delayed(Duration(milliseconds: 50));
      final state = container.read(dailyMysteryNotifierProvider);
      expect(state, isNull);
    });

    test('revealToday で状態が更新される', () async {
      await Future.delayed(Duration(milliseconds: 50));

      final notifier = container.read(dailyMysteryNotifierProvider.notifier);
      await notifier.revealToday(1);

      final state = container.read(dailyMysteryNotifierProvider);
      expect(state, isNotNull);
      expect(state!.mysteryId, 1);
    });

    test('answerToday で isCorrect が更新される', () async {
      await Future.delayed(Duration(milliseconds: 50));

      final notifier = container.read(dailyMysteryNotifierProvider.notifier);
      await notifier.revealToday(1);
      await notifier.answerToday(1, true);

      final state = container.read(dailyMysteryNotifierProvider);
      expect(state!.isCorrect, true);
      expect(state.answeredAt, isNotNull);
    });

    test('answerToday with isCorrect=false', () async {
      await Future.delayed(Duration(milliseconds: 50));

      final notifier = container.read(dailyMysteryNotifierProvider.notifier);
      await notifier.revealToday(2);
      await notifier.answerToday(2, false);

      final state = container.read(dailyMysteryNotifierProvider);
      expect(state!.isCorrect, false);
    });
  });
}
