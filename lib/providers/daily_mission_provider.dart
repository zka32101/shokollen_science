import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/models/daily_mission_model.dart';

final dailyMissionProvider = StateNotifierProvider<DailyMissionNotifier, List<DailyMission>>((ref) {
  return DailyMissionNotifier();
});

class DailyMissionNotifier extends StateNotifier<List<DailyMission>> {
  DailyMissionNotifier() : super([]) {
    _initializeMissions();
  }

  void _initializeMissions() {
    state = [
      DailyMission(
        id: 'daily_1',
        title: '実験にチャレンジ',
        description: '1つの実験を実施しよう',
        reward: 15,
        isCompleted: false,
      ),
      DailyMission(
        id: 'daily_2',
        title: '3問クリア',
        description: '科学問題を3問クリアしよう',
        reward: 25,
        isCompleted: false,
      ),
    ];
  }

  void completeMission(String missionId) {
    state = [
      for (final mission in state)
        if (mission.id == missionId)
          mission.copyWith(isCompleted: true)
        else
          mission,
    ];
  }
}
