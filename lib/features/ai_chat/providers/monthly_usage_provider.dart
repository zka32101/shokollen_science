import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ② AIはかせチャット: 月ごとの利用回数制限 (無料: 5回/月)
const int kFreeMonthlyLimit = 5;

class MonthlyUsageState {
  final int usedCount;
  final String yearMonth; // "2026-06"

  const MonthlyUsageState({
    required this.usedCount,
    required this.yearMonth,
  });

  bool get isLimitReached => usedCount >= kFreeMonthlyLimit;
  int get remaining => (kFreeMonthlyLimit - usedCount).clamp(0, kFreeMonthlyLimit);
}

class MonthlyUsageNotifier extends StateNotifier<MonthlyUsageState> {
  MonthlyUsageNotifier()
      : super(MonthlyUsageState(usedCount: 0, yearMonth: _currentYearMonth()));

  static String _currentYearMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final ym = _currentYearMonth();
    final key = 'ai_chat_usage_$ym';
    final count = prefs.getInt(key) ?? 0;
    state = MonthlyUsageState(usedCount: count, yearMonth: ym);
  }

  Future<bool> recordUsage() async {
    if (state.isLimitReached) return false;

    final prefs = await SharedPreferences.getInstance();
    final ym = _currentYearMonth();
    final key = 'ai_chat_usage_$ym';
    final newCount = (prefs.getInt(key) ?? 0) + 1;
    await prefs.setInt(key, newCount);
    state = MonthlyUsageState(usedCount: newCount, yearMonth: ym);
    return true;
  }
}

final monthlyUsageProvider =
    StateNotifierProvider<MonthlyUsageNotifier, MonthlyUsageState>(
  (ref) {
    final notifier = MonthlyUsageNotifier();
    notifier.load();
    return notifier;
  },
);
