import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../data/seeds/sample_questions.dart';

class DailyChallengeState {
  final String date;
  final List<Map<String, dynamic>> questions; // 3問
  final bool completed;
  final int coinsReward;

  const DailyChallengeState({
    required this.date,
    required this.questions,
    this.completed = false,
    this.coinsReward = 30,
  });

  bool get isToday => date == _todayStr();
  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }
}

class DailyChallengeNotifier extends AsyncNotifier<DailyChallengeState> {
  static const _dateKey = 'daily_challenge_date';
  static const _completedKey = 'daily_challenge_completed';

  @override
  Future<DailyChallengeState> build() async {
    ref.watch(profileProvider);
    return _load();
  }

  Future<DailyChallengeState> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final profileId = ref.read(profileProvider).value?.activeProfileId ?? 'default';
    final savedDate = prefs.getString('${_dateKey}_$profileId') ?? '';
    final today = DailyChallengeState._todayStr();
    final completed = savedDate == today &&
        (prefs.getBool('${_completedKey}_$profileId') ?? false);

    final questions = _pickDailyQuestions(today);
    return DailyChallengeState(date: today, questions: questions, completed: completed);
  }

  List<Map<String, dynamic>> _pickDailyQuestions(String date) {
    // 日付からシード生成（同じ日は同じ問題）
    final seed = date.replaceAll('-', '').hashCode;
    final rng = Random(seed);
    final all = List<Map<String, dynamic>>.from(sampleQuestionsData);
    all.shuffle(rng);
    return all.take(3).toList();
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final profileId = ref.read(profileProvider).value?.activeProfileId ?? 'default';
    final today = DailyChallengeState._todayStr();
    await prefs.setString('${_dateKey}_$profileId', today);
    await prefs.setBool('${_completedKey}_$profileId', true);
    final current = state.value;
    if (current != null) {
      state = AsyncData(DailyChallengeState(
        date: current.date,
        questions: current.questions,
        completed: true,
        coinsReward: current.coinsReward,
      ));
    }
  }
}

final dailyChallengeProvider =
    AsyncNotifierProvider<DailyChallengeNotifier, DailyChallengeState>(
        DailyChallengeNotifier.new);
