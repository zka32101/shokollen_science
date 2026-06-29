import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/prediction_provider.dart';

class PredictionResultWidget extends ConsumerWidget {
  final String experimentId;
  final String? userPrediction;
  final String correctAnswer;

  const PredictionResultWidget({
    required this.experimentId,
    required this.userPrediction,
    required this.correctAnswer,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(predictionProvider);
    final experimentStats = stats[experimentId];

    if (userPrediction == null || experimentStats == null) {
      return const SizedBox.shrink();
    }

    final isCorrect = userPrediction == correctAnswer;
    final predictionRate = experimentStats.predictionRate;

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrect
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCorrect ? Colors.green : Colors.orange,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                'きみの予想：「$userPrediction」',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '実際の結果：「$correctAnswer」',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                isCorrect ? 'あたり！🎯' : 'はずれ... もう一度',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isCorrect ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isCorrect)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+10 ボーナスコイン（予想的中！）',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 予想的中率表示
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                '予想的中率',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // プログレスバー
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: predictionRate / 100,
                  minHeight: 24,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    predictionRate >= 90
                        ? Colors.green
                        : predictionRate >= 70
                        ? Colors.orange
                        : Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${predictionRate.toStringAsFixed(1)}% (${experimentStats.correctPredictions}/${experimentStats.totalAttempts})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 16),
              // バッジ目標
              if (predictionRate >= 90)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐ ', style: TextStyle(fontSize: 16)),
                      Text(
                        'よそう名人バッジ達成！',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  '目標: よそう名人（90%以上）',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              if (predictionRate < 90 && experimentStats.totalAttempts > 0)
                Text(
                  'あと +${(90 - predictionRate).toStringAsFixed(1)}% がんばろう！',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
