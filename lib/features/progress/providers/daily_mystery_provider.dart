import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/daily_mystery_repository.dart';
import '../data/daily_mysteries_data.dart';
import '../models/daily_mystery.dart';

/// main() で SharedPreferences.getInstance() 済みの値を overrideWithValue で注入する。
/// 以前は FutureProvider だったため、読み込み完了前の初回ビルドで例外を投げていた。
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final dailyMysteryRepositoryProvider = Provider<DailyMysteryRepository>((ref) {
  return DailyMysteryRepositoryImpl(ref.watch(sharedPreferencesProvider));
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
