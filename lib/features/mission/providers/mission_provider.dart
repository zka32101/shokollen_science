import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../profile/providers/profile_provider.dart';

/// 今日のミッション
class DailyMission {
  final String id;
  final String title;
  final String emoji;
  final int coinReward;
  final bool completed;

  const DailyMission({
    required this.id,
    required this.title,
    required this.emoji,
    required this.coinReward,
    this.completed = false,
  });

  DailyMission withCompleted(bool v) => DailyMission(
    id: id, title: title, emoji: emoji, coinReward: coinReward, completed: v,
  );
}

/// 静的ミッション定義
const _missionDefs = [
  DailyMission(id: 'quiz_3', title: '3問クイズに正解する', emoji: '🎯', coinReward: 15),
  DailyMission(id: 'clear_stage', title: 'ステージを1つクリアする', emoji: '⭐', coinReward: 20),
  DailyMission(id: 'read_learn', title: 'まなぶを1つ読む', emoji: '📖', coinReward: 10),
  DailyMission(id: 'streak', title: '今日もログインする', emoji: '🔥', coinReward: 5),
];

class MissionState {
  final String date;
  final List<DailyMission> missions;

  const MissionState({required this.date, required this.missions});

  int get totalCoins => missions.where((m) => m.completed).fold(0, (s, m) => s + m.coinReward);
  int get completedCount => missions.where((m) => m.completed).length;
}

class MissionNotifier extends AsyncNotifier<MissionState> {
  static const _keyPrefix = 'missions_v1_';

  @override
  Future<MissionState> build() async {
    ref.watch(profileProvider);
    return _load();
  }

  String get _profileId => ref.read(profileProvider).value?.activeProfileId ?? 'default';

  Future<MissionState> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayStr();
    final missions = _missionDefs.map((def) {
      final done = prefs.getBool('${_keyPrefix}${_profileId}_${today}_${def.id}') ?? false;
      return def.withCompleted(done);
    }).toList();
    return MissionState(date: today, missions: missions);
  }

  Future<void> completeMission(String missionId) async {
    final current = state.value;
    if (current == null) return;
    final today = _todayStr();
    if (current.date != today) return;
    final mission = current.missions.firstWhere((m) => m.id == missionId, orElse: () => _missionDefs.first);
    if (mission.completed) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_keyPrefix}${_profileId}_${today}_$missionId', true);

    final updated = current.missions.map((m) => m.id == missionId ? m.withCompleted(true) : m).toList();
    state = AsyncData(MissionState(date: today, missions: updated));
  }

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }
}

final missionProvider =
    AsyncNotifierProvider<MissionNotifier, MissionState>(MissionNotifier.new);
