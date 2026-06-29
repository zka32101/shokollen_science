import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int _coinsDay1 = 10;
const int _coinsDay2 = 15;
const int _coinsDay3 = 20;
const int _coinsDay4 = 25;
const int _coinsDay5 = 30;
const int _coinsDay6 = 40;

class DailyBonusState {
  final int consecutiveDays;
  final bool hasClaimedToday;
  final DateTime? lastClaimedDate;
  final int coinsForToday;
  final bool isMilestone; // Day 7, 14, 30
  final String? milestoneReward; // キャラID or アイテムID

  const DailyBonusState({
    this.consecutiveDays = 0,
    this.hasClaimedToday = false,
    this.lastClaimedDate,
    this.coinsForToday = 0,
    this.isMilestone = false,
    this.milestoneReward,
  });

  DailyBonusState copyWith({
    int? consecutiveDays,
    bool? hasClaimedToday,
    DateTime? lastClaimedDate,
    int? coinsForToday,
    bool? isMilestone,
    String? milestoneReward,
  }) =>
      DailyBonusState(
        consecutiveDays: consecutiveDays ?? this.consecutiveDays,
        hasClaimedToday: hasClaimedToday ?? this.hasClaimedToday,
        lastClaimedDate: lastClaimedDate ?? this.lastClaimedDate,
        coinsForToday: coinsForToday ?? this.coinsForToday,
        isMilestone: isMilestone ?? this.isMilestone,
        milestoneReward: milestoneReward ?? this.milestoneReward,
      );
}

class DailyLoginBonusNotifier extends AsyncNotifier<DailyBonusState> {
  static const _lastClaimedKey = 'daily_bonus_last_claimed_v1';
  static const _consecutiveDaysKey = 'daily_bonus_consecutive_days_v1';

  @override
  Future<DailyBonusState> build() => _load();

  Future<DailyBonusState> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaimedStr = prefs.getString(_lastClaimedKey);
    final consecutiveDays = prefs.getInt(_consecutiveDaysKey) ?? 0;

    final today = _todayStr();
    final DateTime? lastClaimed =
        lastClaimedStr != null ? DateTime.parse(lastClaimedStr) : null;

    // 本日既に受け取り済みか確認
    final hasClaimedToday =
        lastClaimed != null && _todayStr(lastClaimed) == today;

    if (hasClaimedToday) {
      // 本日既に受け取り済み → 受け取り可能な時間まで待機状態
      final coins = _coinsForDay(consecutiveDays);
      return DailyBonusState(
        consecutiveDays: consecutiveDays,
        hasClaimedToday: true,
        lastClaimedDate: lastClaimed,
        coinsForToday: coins,
        isMilestone: _isMilestone(consecutiveDays),
        milestoneReward: _milestoneReward(consecutiveDays),
      );
    }

    // 本日未受け取り → 新しい日付でボーナス計算
    int newConsecutiveDays = consecutiveDays;
    if (lastClaimed != null) {
      final yesterday = _yesterdayStr();
      final lastClaimedDateStr = _todayStr(lastClaimed);
      // 昨日に受け取っていれば連続日数を+1
      if (lastClaimedDateStr == yesterday) {
        newConsecutiveDays = consecutiveDays + 1;
      } else {
        // 1日以上空いていればリセット
        newConsecutiveDays = 1;
      }
    } else {
      // 初回ボーナス
      newConsecutiveDays = 1;
    }

    final coins = _coinsForDay(newConsecutiveDays);

    return DailyBonusState(
      consecutiveDays: newConsecutiveDays,
      hasClaimedToday: false,
      lastClaimedDate: DateTime.now(),
      coinsForToday: coins,
      isMilestone: _isMilestone(newConsecutiveDays),
      milestoneReward: _milestoneReward(newConsecutiveDays),
    );
  }

  /// ボーナスを受け取る
  Future<void> claimBonus() async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.value ?? const DailyBonusState();

    if (current.hasClaimedToday) {
      return; // 既に受け取り済み
    }

    // 連続日数を更新
    final newConsecutive = current.consecutiveDays + 1;
    await prefs.setInt(_consecutiveDaysKey, newConsecutive);
    await prefs.setString(_lastClaimedKey, DateTime.now().toIso8601String());

    // 状態更新
    final coins = _coinsForDay(newConsecutive);
    state = AsyncData(
      DailyBonusState(
        consecutiveDays: newConsecutive,
        hasClaimedToday: true,
        lastClaimedDate: DateTime.now(),
        coinsForToday: coins,
        isMilestone: _isMilestone(newConsecutive),
        milestoneReward: _milestoneReward(newConsecutive),
      ),
    );
  }

  /// ストリークをリセット（デバッグ用）
  Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastClaimedKey);
    await prefs.remove(_consecutiveDaysKey);
    state = const AsyncData(DailyBonusState());
  }

  static int _coinsForDay(int day) {
    return switch (day) {
      1 => _coinsDay1,
      2 => _coinsDay2,
      3 => _coinsDay3,
      4 => _coinsDay4,
      5 => _coinsDay5,
      6 => _coinsDay6,
      >= 7 => _coinsDay6, // Day 7以降は Day 6と同じ（ウィークリーボックスで別報酬）
      _ => 0,
    };
  }

  static bool _isMilestone(int day) => day == 7 || day == 14 || day == 30;

  static String? _milestoneReward(int day) {
    return switch (day) {
      7 => 'weekly_box', // ウィークリーボックス
      14 => 'character_nichinicho', // 限定キャラ「ニチニチ」
      30 => 'character_monthly', // 伝説キャラ「マンスリー」
      _ => null,
    };
  }

  static String _todayStr([DateTime? date]) {
    final d = date ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _yesterdayStr() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }
}

final dailyLoginBonusProvider =
    AsyncNotifierProvider<DailyLoginBonusNotifier, DailyBonusState>(
        DailyLoginBonusNotifier.new);
