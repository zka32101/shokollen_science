import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/daily_mystery_repository.dart';
import '../data/daily_mysteries_data.dart';
import '../models/daily_mystery.dart';

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final dailyMysteryRepositoryProvider = Provider<DailyMysteryRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).maybeWhen(
    data: (prefs) => prefs,
    orElse: () => throw Exception('SharedPreferences not initialized'),
  );
  return DailyMysteryRepositoryImpl(prefs);
});

final todayMysteryProvider = FutureProvider<DailyMystery>((ref) async {
  return pickTodayMystery();
});

final todayRecordProvider = FutureProvider<DailyMysteryRecord?>((ref) async {
  final repo = ref.watch(dailyMysteryRepositoryProvider);
  return await repo.getTodayRecord();
});

class DailyMysteryNotifier extends StateNotifier<DailyMysteryRecord?> {
  final DailyMysteryRepository repository;

  DailyMysteryNotifier(this.repository) : super(null) {
    _init();
  }

  Future<void> _init() async {
    final record = await repository.getTodayRecord();
    state = record;
  }

  Future<void> revealToday(int mysteryId) async {
    await repository.recordRevealed(mysteryId);
    state = await repository.getTodayRecord();
  }

  Future<void> answerToday(int mysteryId, bool isCorrect) async {
    await repository.recordAnswered(mysteryId, isCorrect);
    state = await repository.getTodayRecord();
  }
}

final dailyMysteryNotifierProvider =
    StateNotifierProvider<DailyMysteryNotifier, DailyMysteryRecord?>((ref) {
  final repo = ref.watch(dailyMysteryRepositoryProvider);
  return DailyMysteryNotifier(repo);
});
