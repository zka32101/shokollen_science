import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ミッション定義
class WeeklyMission {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final int coinReward;
  bool completed;

  WeeklyMission({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.coinReward,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {'id': id, 'completed': completed};
}

// 固定ミッションリスト（毎週リセット）
List<WeeklyMission> _buildMissions() => [
      WeeklyMission(
        id: 'quiz_3',
        emoji: '🧪',
        title: 'クイズ3回チャレンジ',
        description: '今週クイズを3ステージやってみよう',
        coinReward: 10,
      ),
      WeeklyMission(
        id: 'learn_2',
        emoji: '📖',
        title: 'まなぶモード2回',
        description: 'まなぶモードで2つのステージを学ぼう',
        coinReward: 10,
      ),
      WeeklyMission(
        id: 'perfect',
        emoji: '⭐',
        title: 'パーフェクト達成',
        description: 'クイズで全問正解しよう',
        coinReward: 15,
      ),
      WeeklyMission(
        id: 'daily',
        emoji: '📅',
        title: 'デイリーチャレンジ',
        description: 'デイリーチャレンジに挑戦しよう',
        coinReward: 10,
      ),
      WeeklyMission(
        id: 'grade_mix',
        emoji: '🎯',
        title: 'いろんな学年に挑戦',
        description: '2つの異なる学年のクイズをやろう',
        coinReward: 15,
      ),
    ];

class WeeklyChallengeState {
  final List<WeeklyMission> missions;
  final String weekKey; // 'yyyy-Www' 形式
  final bool bonusClaimed;
  final int completedCount;

  WeeklyChallengeState({
    required this.missions,
    required this.weekKey,
    required this.bonusClaimed,
  }) : completedCount = missions.where((m) => m.completed).length;

  bool get allComplete => completedCount >= missions.length;
  int get bonusCoins => 50;
}

class WeeklyChallengeNotifier extends AsyncNotifier<WeeklyChallengeState> {
  static const _key = 'weekly_challenge_v1';

  @override
  Future<WeeklyChallengeState> build() async {
    return _load();
  }

  String _currentWeekKey(DateTime now) {
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '${monday.year}-W${monday.month.toString().padLeft(2, '0')}${monday.day.toString().padLeft(2, '0')}';
  }

  Future<WeeklyChallengeState> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final currentWeek = _currentWeekKey(now);
    final raw = prefs.getString(_key);

    if (raw != null) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['weekKey'] == currentWeek) {
        final missions = _buildMissions();
        final completedIds = List<String>.from(data['completed'] ?? []);
        for (final m in missions) {
          if (completedIds.contains(m.id)) m.completed = true;
        }
        return WeeklyChallengeState(
          missions: missions,
          weekKey: currentWeek,
          bonusClaimed: data['bonusClaimed'] == true,
        );
      }
    }
    // 新しい週 → リセット
    await _save(currentWeek, [], false, prefs);
    return WeeklyChallengeState(
      missions: _buildMissions(),
      weekKey: currentWeek,
      bonusClaimed: false,
    );
  }

  Future<void> _save(String weekKey, List<String> completed, bool bonusClaimed,
      [SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.setString(
        _key,
        jsonEncode({
          'weekKey': weekKey,
          'completed': completed,
          'bonusClaimed': bonusClaimed,
        }));
  }

  // ミッション達成
  Future<bool> completeMission(String missionId) async {
    final current = state.valueOrNull;
    if (current == null) return false;
    final mission = current.missions.firstWhere(
      (m) => m.id == missionId,
      orElse: () => WeeklyMission(
          id: '', emoji: '', title: '', description: '', coinReward: 0),
    );
    if (mission.id.isEmpty || mission.completed) return false;

    mission.completed = true;
    final completedIds =
        current.missions.where((m) => m.completed).map((m) => m.id).toList();
    await _save(current.weekKey, completedIds, current.bonusClaimed);
    state = AsyncValue.data(WeeklyChallengeState(
      missions: current.missions,
      weekKey: current.weekKey,
      bonusClaimed: current.bonusClaimed,
    ));
    return true;
  }

  // 全完了ボーナス受取
  Future<int> claimBonus() async {
    final current = state.valueOrNull;
    if (current == null || !current.allComplete || current.bonusClaimed) {
      return 0;
    }
    final completedIds =
        current.missions.where((m) => m.completed).map((m) => m.id).toList();
    await _save(current.weekKey, completedIds, true);
    state = AsyncValue.data(WeeklyChallengeState(
      missions: current.missions,
      weekKey: current.weekKey,
      bonusClaimed: true,
    ));
    return current.bonusCoins;
  }

  // クイズクリア通知（home_screen等から呼び出す）
  Future<void> onQuizComplete({
    required String stageId,
    required bool isPerfect,
    required String grade,
  }) async {
    await completeMission('quiz_3');
    if (isPerfect) await completeMission('perfect');
    // grade_mix: 異なる学年チェックは簡略化（TODO: 実際には2学年記録して比較）
  }

  Future<void> onLearnComplete() async => completeMission('learn_2');
  Future<void> onDailyComplete() async => completeMission('daily');
}

final weeklyChallengeProvider =
    AsyncNotifierProvider<WeeklyChallengeNotifier, WeeklyChallengeState>(
  WeeklyChallengeNotifier.new,
);
