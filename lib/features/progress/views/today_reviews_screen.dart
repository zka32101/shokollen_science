import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../models/review_schedule.dart';
import '../providers/review_time_capsule_provider.dart';

/// 今日の復習スクリーン
class TodayReviewsScreen extends ConsumerWidget {
  const TodayReviewsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayReviewsAsync = ref.watch(todayReviewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('復習タイムカプセル'),
        centerTitle: true,
        elevation: 0,
      ),
      body: todayReviewsAsync.when(
        data: (todayReviews) {
          if (todayReviews.isEmpty) {
            return _EmptyState();
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー
                _Header(count: todayReviews.length),

                // 復習一覧
                _ReviewsList(capsules: todayReviews),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('エラーが発生しました: $err'),
        ),
      ),
    );
  }
}

/// ヘッダー：復習数と説明
class _Header extends StatelessWidget {
  final int count;

  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.sciencePrimary.withOpacity(0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '⏰',
                style: TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日の復習',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count 個の問題が復習待機中',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sciencePrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.sciencePrimary),
                SizedBox(width: 8),
                Expanded(
                  child: FuriganaText(
                    'Ebbinghaus の{忘却|ぼうきゃく}{曲線|きょくせん}に基づいた復習スケジュールです',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 復習一覧
class _ReviewsList extends ConsumerWidget {
  final List<TimeCapsule> capsules;

  const _ReviewsList({required this.capsules});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...capsules.asMap().entries.map((entry) {
            final index = entry.key;
            final capsule = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < capsules.length - 1 ? 12 : 0,
              ),
              child: _ReviewCard(
                capsule: capsule,
                onComplete: () => _showCompleteDialog(context, ref, capsule),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showCompleteDialog(
    BuildContext context,
    WidgetRef ref,
    TimeCapsule capsule,
  ) {
    final nextReview = capsule.getNextReview();
    if (nextReview == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('復習を完了しますか？'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FuriganaText('問${capsule.questionNumber}. ${capsule.questionTitle}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${nextReview.interval.label} の復習',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(timeCapsuleProvider.notifier)
                  .completeReview(capsule.id, nextReview.interval);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ 復習を完了しました！')),
                );
              }
            },
            child: const Text('完了'),
          ),
        ],
      ),
    );
  }
}

/// 復習カード
class _ReviewCard extends StatelessWidget {
  final TimeCapsule capsule;
  final VoidCallback onComplete;

  const _ReviewCard({
    required this.capsule,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final nextReview = capsule.getNextReview();
    if (nextReview == null) return const SizedBox.shrink();

    final isOverdue = nextReview.isOverdue();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isOverdue
                ? [Colors.red[50]!, Colors.red[100]!]
                : [Colors.green[50]!, Colors.green[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 問題タイトル
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FuriganaText(
                        '問${capsule.questionNumber}. ${capsule.questionTitle}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 復習情報
                      Row(
                        children: [
                          Icon(
                            nextReview.status.emoji == '⏳'
                                ? Icons.schedule
                                : Icons.check_circle,
                            size: 16,
                            color: isOverdue ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            nextReview.interval.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isOverdue ? Colors.red : Colors.green,
                            ),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '期限切れ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 進捗バー
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: capsule.progressPercent,
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(
                        Colors.green[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${capsule.progressPercentInt}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '復習する',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 復習がない状態
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 72,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '今日の復習はありません！',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'すべての復習を完了しました 🎉',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
