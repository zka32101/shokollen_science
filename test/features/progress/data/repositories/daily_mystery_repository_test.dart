import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shokollen_science/features/progress/data/repositories/daily_mystery_repository.dart';
import 'package:shokollen_science/features/progress/models/daily_mystery.dart';

void main() {
  group('DailyMysteryRepository Tests', () {
    late SharedPreferences prefs;
    late DailyMysteryRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = DailyMysteryRepositoryImpl(prefs);
    });

    tearDown(() async {
      await repository.clear();
    });

    test('recordRevealed saves mystery record', () async {
      await repository.recordRevealed(1);
      final record = await repository.getTodayRecord();

      expect(record, isNotNull);
      expect(record!.mysteryId, 1);
      expect(record.revealedAt, isNotNull);
    });

    test('recordAnswered updates answered status', () async {
      await repository.recordRevealed(1);
      await repository.recordAnswered(1, true);

      final record = await repository.getTodayRecord();
      expect(record!.answeredAt, isNotNull);
      expect(record.isCorrect, true);
    });

    test('recordAnswered with isCorrect=false', () async {
      await repository.recordRevealed(2);
      await repository.recordAnswered(2, false);

      final record = await repository.getTodayRecord();
      expect(record!.isCorrect, false);
    });

    test('getTodayRecord returns null if no record', () async {
      final record = await repository.getTodayRecord();
      expect(record, isNull);
    });

    test('getAll returns all records', () async {
      // Add records on different days (simulated by clearing)
      await repository.recordRevealed(1);
      final all = await repository.getAll();
      expect(all.isNotEmpty, true);
    });

    test('clear removes all records', () async {
      await repository.recordRevealed(1);
      await repository.clear();

      final all = await repository.getAll();
      expect(all, isEmpty);
    });

    test('multiple recordRevealed calls update the record', () async {
      await repository.recordRevealed(1);
      final record1 = await repository.getTodayRecord();

      await repository.recordRevealed(2);
      final record2 = await repository.getTodayRecord();

      // Last mysteryId should be stored
      expect(record2!.mysteryId, 2);
    });
  });
}
