import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../features/progress/providers/user_progress_provider.dart';
import '../../../data/seeds/stages.dart';

class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (progress) => _WeeklyReportBody(progress: progress),
      ),
    );
  }
}

class _WeeklyReportBody extends StatelessWidget {
  final dynamic progress;
  const _WeeklyReportBody({required this.progress});

  @override
  Widget build(BuildContext context) {
    final days = _last7Days();
    final activityMap = progress.dailyActivity as Map<String, int>;

    // 過去7日の正解数リスト
    final counts = days.map((d) => activityMap[d] ?? 0).toList();
    final maxCount = max(1, counts.reduce(max));

    // 今週の正解数合計
    final weeklyTotal = counts.fold(0, (a, b) => a + b);

    // 弱点単元（wrongAnswers 上位3件）
    final wrongAnswers = progress.wrongAnswers as Map<String, List<int>>;
    final topWeak = wrongAnswers.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    final weakTop3 = topWeak.take(3).toList();

    return CustomScrollView(
      slivers: [
        // ── AppBar ─────────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 100,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              '📊 今週のレポート',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.scienceGradient,
              ),
            ),
          ),
          backgroundColor: AppColors.sciencePrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),

        // ── コンテンツ ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 7日間バーチャート ─────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📅 7日間の正解数',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _BarChart(
                        days: days,
                        counts: counts,
                        maxCount: maxCount,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── サマリーカード（3枚）────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: '🏆',
                        label: 'クリアステージ',
                        value: '${progress.streakDays * 2}',
                        unit: 'ステージ',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        icon: '⭕',
                        label: '今週の正解数',
                        value: '$weeklyTotal',
                        unit: '問',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        icon: '📈',
                        label: '平均正答率',
                        value: '${progress.averageScore}',
                        unit: '%',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── 弱点単元セクション ─────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💪 にがて単元 TOP3',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (weakTop3.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'にがて単元はありません！すばらしい！🎉',
                            style: TextStyle(
                              color: AppColors.textGray,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                        ...weakTop3.map(
                          (entry) => _WeakUnitTile(
                            stageId: entry.key,
                            wrongNums: entry.value,
                            onReview: () => context.push('/review'),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── ホームに戻るボタン ──────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home),
                    label: const Text(
                      'ホームに戻る',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sciencePrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 過去7日間の日付文字列リスト（古い順）
  List<String> _last7Days() {
    return List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    });
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 7日間バーチャート
// ──────────────────────────────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final List<String> days;
  final List<int> counts;
  final int maxCount;

  const _BarChart({
    required this.days,
    required this.counts,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final todayStr = _todayStr();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(days.length, (i) {
        final day = days[i];
        final count = counts[i];
        final isToday = day == todayStr;
        final barHeight = (count / maxCount) * 80.0;
        final label =
            '${int.parse(day.substring(5, 7))}/${int.parse(day.substring(8, 10))}';

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 正解数テキスト
              Text(
                count > 0 ? '$count' : '',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isToday
                      ? AppColors.sciencePrimary
                      : AppColors.textGray,
                ),
              ),
              const SizedBox(height: 4),
              // バー
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                height: count > 0 ? barHeight.clamp(4.0, 80.0) : 4.0,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.sciencePrimary
                      : const Color(0xFFBDE0F9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              // 日付ラベル
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isToday
                      ? AppColors.sciencePrimary
                      : AppColors.textGray,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// カード風セクション
// ──────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// サマリーカード
// ──────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String unit;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.sciencePrimary,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 弱点単元タイル
// ──────────────────────────────────────────────────────────────────────────────

class _WeakUnitTile extends StatelessWidget {
  final String stageId;
  final List<int> wrongNums;
  final VoidCallback onReview;

  const _WeakUnitTile({
    required this.stageId,
    required this.wrongNums,
    required this.onReview,
  });

  String _stageName() {
    final found = stagesData.firstWhere(
      (s) => s['id'] == stageId,
      orElse: () => {},
    );
    return (found['stageName'] as String?) ?? stageId;
  }

  @override
  Widget build(BuildContext context) {
    final name = _stageName();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // アイコン
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.scienceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.sciencePrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // ステージ名・問題数
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${wrongNums.length}問 にがて',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
          // 復習ボタン
          TextButton(
            onPressed: onReview,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.sciencePrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.sciencePrimary),
              ),
            ),
            child: const Text(
              '復習する',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
