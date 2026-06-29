import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PredictionStats {
  final String experimentId;
  final int totalAttempts;
  final int correctPredictions;

  PredictionStats({
    required this.experimentId,
    required this.totalAttempts,
    required this.correctPredictions,
  });

  double get predictionRate =>
      totalAttempts == 0 ? 0 : (correctPredictions / totalAttempts) * 100;

  bool get isPredictionMaster => predictionRate >= 90;
}

class PredictionNotifier extends StateNotifier<Map<String, PredictionStats>> {
  PredictionNotifier() : super({});

  Future<void> loadPredictionStats() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, PredictionStats> stats = {};

    // Firestore実装時まで SharedPrefs のみ使用
    // キー: prediction_stats_{experimentId}:totalAttempts
    // キー: prediction_stats_{experimentId}:correctPredictions

    state = stats;
  }

  Future<void> recordPrediction({
    required String experimentId,
    required String userPrediction,
    required String correctAnswer,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isCorrect = userPrediction == correctAnswer;

    final keyPrefix = 'prediction_stats_$experimentId';
    final totalKey = '$keyPrefix:totalAttempts';
    final correctKey = '$keyPrefix:correctPredictions';

    final currentTotal = prefs.getInt(totalKey) ?? 0;
    final currentCorrect = prefs.getInt(correctKey) ?? 0;

    await prefs.setInt(totalKey, currentTotal + 1);
    if (isCorrect) {
      await prefs.setInt(correctKey, currentCorrect + 1);
    }

    // 履歴も記録（後でグラフ化可能）
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await prefs.setString(
      'prediction_history_${experimentId}_$timestamp',
      isCorrect ? 'correct' : 'incorrect',
    );

    // Riverpod更新
    state = {
      ...state,
      experimentId: PredictionStats(
        experimentId: experimentId,
        totalAttempts: currentTotal + 1,
        correctPredictions: currentCorrect + (isCorrect ? 1 : 0),
      ),
    };
  }

  Future<PredictionStats?> getPredictionStats(String experimentId) async {
    await loadPredictionStats();
    return state[experimentId];
  }

  double getPredictionRate(String experimentId) {
    return state[experimentId]?.predictionRate ?? 0;
  }

  bool isUnlockedBadge(String experimentId) {
    return state[experimentId]?.isPredictionMaster ?? false;
  }

  Future<void> resetExperimentStats(String experimentId) async {
    final prefs = await SharedPreferences.getInstance();
    final keyPrefix = 'prediction_stats_$experimentId';

    await prefs.remove('$keyPrefix:totalAttempts');
    await prefs.remove('$keyPrefix:correctPredictions');

    // Riverpod更新
    state = {
      ...state,
    }..remove(experimentId);
  }
}

final predictionProvider =
    StateNotifierProvider<PredictionNotifier, Map<String, PredictionStats>>(
  (ref) => PredictionNotifier(),
);
