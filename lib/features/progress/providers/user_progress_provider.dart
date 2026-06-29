import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress_model.dart';
import '../models/badge_model.dart';
import '../../profile/providers/profile_provider.dart';

// 学年別ステージID一覧
const _grade3StageIds = [
  'stage_3_001', 'stage_3_002', 'stage_3_003', 'stage_3_004',
  'stage_3_005', 'stage_3_006', 'stage_3_007', 'stage_3_008',
  'stage_3_009', 'stage_3_010', 'stage_3_011', 'stage_3_012',
];
const _grade4StageIds = [
  'stage_4_001', 'stage_4_002', 'stage_4_003', 'stage_4_004',
  'stage_4_005', 'stage_4_006', 'stage_4_007', 'stage_4_008',
  'stage_4_009', 'stage_4_010', 'stage_4_011',
];
const _grade5StageIds = [
  'stage_5_001', 'stage_5_002', 'stage_5_003', 'stage_5_004',
  'stage_5_005', 'stage_5_006', 'stage_5_007', 'stage_5_008',
  'stage_5_009', 'stage_5_010', 'stage_5_011', 'stage_5_012',
];
const _grade6StageIds = [
  'stage_6_001', 'stage_6_002', 'stage_6_003', 'stage_6_004',
  'stage_6_005', 'stage_6_006', 'stage_6_007', 'stage_6_008',
  'stage_6_009', 'stage_6_010', 'stage_6_011', 'stage_6_012',
];

// 総ステージ数（stages.dart の合計）
const int _totalStageCount = 47;

// コイン獲得量
const int kCoinsPerCorrect = 5;     // 正解1問につき
const int kCoinsBonusPerfect = 20;  // 全問正解ボーナス
const int kCoinsStreakBonus = 10;   // 3日連続ボーナス

class UserProgressNotifier extends AsyncNotifier<UserProgress> {
  // v3: hintsRemaining, activeThemeId追加
  String get _prefsKey {
    final profileId = ref.read(profileProvider).value?.activeProfileId;
    return profileId != null
        ? 'user_progress_v3_$profileId'
        : 'user_progress_v3_default';
  }

  @override
  Future<UserProgress> build() async {
    // アクティブプロフィールが変わったら再ロード
    ref.watch(profileProvider);
    return _load();
  }

  Future<UserProgress> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return const UserProgress();
    try {
      return UserProgress.fromJsonString(raw);
    } catch (_) {
      return const UserProgress();
    }
  }

  Future<void> _save(UserProgress p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, p.toJsonString());
  }

  // ────────────────────────────────────────────────────────
  /// クイズ完了時。獲得バッジと獲得コインを返す
  // ────────────────────────────────────────────────────────
  Future<({List<BadgeModel> badges, int coinsEarned})> completeStage(
    String stageId,
    int earnedPoints,
    int correctCount,
    int totalQuestions, {
    List<int> wrongQuestionNumbers = const [],
  }) async {
    final current = state.value ?? const UserProgress();
    final today = _todayStr();

    // ── ストリーク更新 ────────────────
    int newStreak = current.streakDays;
    if (current.lastPlayedDate != today) {
      final yesterday = _yesterdayStr();
      if (current.lastPlayedDate == yesterday) {
        newStreak = current.streakDays + 1;
      } else if (current.lastPlayedDate.isEmpty) {
        newStreak = 1;
      } else {
        newStreak = 1;
      }
    }

    // ── ベストスコア更新（全問正解のみクリア） ──────────────
    final bestScore = totalQuestions == 0
        ? 0
        : ((correctCount / totalQuestions) * 100).round();
    final newCleared = Map<String, int>.from(current.clearedStages);
    // 全問正解のみをクリア扱いにする
    if (correctCount == totalQuestions && totalQuestions > 0) {
      newCleared[stageId] = bestScore; // bestScore は 100
    }

    // ── コイン計算 ────────────────────
    int coinsEarned = correctCount * kCoinsPerCorrect;
    if (correctCount == totalQuestions && totalQuestions > 0) {
      coinsEarned += kCoinsBonusPerfect; // 全問正解ボーナス
    }
    // 3日連続ボーナス（ストリーク達成日のみ）
    if (newStreak >= 3 && current.streakDays < 3) {
      coinsEarned += kCoinsStreakBonus;
    }

    // ── 新しい進捗 ────────────────────
    final newProgress = current.copyWith(
      totalPoints: current.totalPoints + earnedPoints,
      coins: current.coins + coinsEarned,
      streakDays: newStreak,
      lastPlayedDate: today,
      clearedStages: newCleared,
    );

    // ── バッジチェック ─────────────────
    final newBadges = _checkNewBadges(current, newProgress);

    // ── 間違えた問題を記録 ───────────────────────────
    final newWrongAnswers = Map<String, List<int>>.from(current.wrongAnswers);
    if (wrongQuestionNumbers.isNotEmpty) {
      newWrongAnswers[stageId] = wrongQuestionNumbers;
    } else if (bestScore == 100) {
      // 全問正解ならその stageId の間違いを削除
      newWrongAnswers.remove(stageId);
    }

    // ── 日別アクティビティ更新 ──────────────────────
    final newDailyActivity = Map<String, int>.from(current.dailyActivity);
    newDailyActivity[today] = (newDailyActivity[today] ?? 0) + correctCount;

    final finalProgress = newProgress.copyWith(
      earnedBadgeIds: [
        ...current.earnedBadgeIds,
        ...newBadges.map((b) => b.id),
      ],
      wrongAnswers: newWrongAnswers,
      dailyActivity: newDailyActivity,
    );

    await _save(finalProgress);
    state = AsyncData(finalProgress);
    return (badges: newBadges, coinsEarned: coinsEarned);
  }

  // ────────────────────────────────────────────────────────
  /// コインを加算する（デイリーチャレンジ等の外部から直接付与）
  // ────────────────────────────────────────────────────────
  Future<void> addCoins(int amount) async {
    final current = state.value ?? const UserProgress();
    final updated = current.copyWith(coins: current.coins + amount);
    await _save(updated);
    state = AsyncData(updated);
  }

  // ────────────────────────────────────────────────────────
  /// ショップでコインアイテムを購入
  // ────────────────────────────────────────────────────────
  Future<bool> purchaseWithCoins(String itemId, int cost) async {
    final current = state.value ?? const UserProgress();
    if (current.coins < cost) return false;

    // ヒントは繰り返し購入可能（重複チェックをスキップ）
    final isHint = itemId == 'hint_3';
    if (!isHint && current.hasPurchased(itemId)) return false;

    final updated = current.copyWith(
      coins: current.coins - cost,
      hintsRemaining: isHint
          ? current.hintsRemaining + 3
          : current.hintsRemaining,
      purchasedItemIds: isHint
          ? current.purchasedItemIds
          : [...current.purchasedItemIds, itemId],
    );
    await _save(updated);
    state = AsyncData(updated);
    return true;
  }

  // ────────────────────────────────────────────────────────
  /// ヒントを1つ使う。使えない場合は false を返す
  // ────────────────────────────────────────────────────────
  Future<bool> useHint() async {
    final current = state.value ?? const UserProgress();
    if (current.hintsRemaining <= 0) return false;
    final updated = current.copyWith(
      hintsRemaining: current.hintsRemaining - 1,
    );
    await _save(updated);
    state = AsyncData(updated);
    return true;
  }

  // ────────────────────────────────────────────────────────
  /// テーマを変更する
  // ────────────────────────────────────────────────────────
  Future<void> setTheme(String themeId) async {
    final current = state.value ?? const UserProgress();
    final updated = current.copyWith(activeThemeId: themeId);
    await _save(updated);
    state = AsyncData(updated);
  }

  // ────────────────────────────────────────────────────────
  /// データリセット（デバッグ用）
  // ────────────────────────────────────────────────────────
  Future<void> resetProgress() async {
    const empty = UserProgress();
    await _save(empty);
    state = const AsyncData(UserProgress());
  }

  // ── 内部ヘルパー ─────────────────────────────────────────

  List<BadgeModel> _checkNewBadges(UserProgress old, UserProgress newP) {
    final result = <BadgeModel>[];
    for (final badge in allBadges) {
      if (old.earnedBadgeIds.contains(badge.id)) continue;
      if (_isBadgeEarned(badge.id, newP)) result.add(badge);
    }
    return result;
  }

  bool _isBadgeEarned(String id, UserProgress p) {
    switch (id) {
      // ストリーク
      case 'streak_3':        return p.streakDays >= 3;
      case 'streak_7':        return p.streakDays >= 7;
      case 'streak_14':       return p.streakDays >= 14;
      case 'streak_30':       return p.streakDays >= 30;
      // 満点
      case 'perfect_score':   return p.clearedStages.values.any((s) => s == 100);
      // ポイント
      case 'points_100':      return p.totalPoints >= 100;
      case 'points_500':      return p.totalPoints >= 500;
      case 'points_1000':     return p.totalPoints >= 1000;
      // ステージ数マイルストーン
      case 'first_quiz':      return p.clearedCount >= 1;
      case 'five_stages':     return p.clearedCount >= 5;
      case 'ten_stages':      return p.clearedCount >= 10;
      case 'stage_20':        return p.clearedCount >= 20;
      case 'stage_30':        return p.clearedCount >= 30;
      case 'stage_40':        return p.clearedCount >= 40;
      case 'stage_45':        return p.clearedCount >= 45;
      case 'stage_47':        return p.clearedCount >= 47;
      // 学年コンプリート（緩和: 80%以上で獲得）
      case 'grade3_complete':
        final count3 = _grade3StageIds
            .where((sid) => p.clearedStages.containsKey(sid))
            .length;
        return count3 >= 11; // 11/12
      case 'grade4_complete':
        final count4 = _grade4StageIds
            .where((sid) => p.clearedStages.containsKey(sid))
            .length;
        return count4 >= 10; // 10/11
      case 'grade5_complete':
        final count5 = _grade5StageIds
            .where((sid) => p.clearedStages.containsKey(sid))
            .length;
        return count5 >= 10; // 10/12
      case 'grade6_complete':
        final count6 = _grade6StageIds
            .where((sid) => p.clearedStages.containsKey(sid))
            .length;
        return count6 >= 10; // 10/12
      // 全ステージ制覇
      case 'science_master':  return p.clearedCount >= _totalStageCount;
      default:                return false;
    }
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  static String _yesterdayStr() {
    final d = DateTime.now().subtract(const Duration(days: 1));
    return '${d.year}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}

final userProgressProvider =
    AsyncNotifierProvider<UserProgressNotifier, UserProgress>(
        UserProgressNotifier.new);
