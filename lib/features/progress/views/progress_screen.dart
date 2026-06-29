import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../data/seeds/stages.dart';
import '../models/badge_model.dart';
import '../models/user_progress_model.dart';
import '../providers/user_progress_provider.dart';

/// 学習記録タブ（ボトムナビ4番目）
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);

    return progressAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.sciencePrimary)),
      error: (e, _) => Center(
          child: Text('エラー: $e',
              style: const TextStyle(color: AppColors.error))),
      data: (progress) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(progress),
            _buildStatsRow(progress),
            _buildBadgeSection(context, progress),
            _buildStageProgressSection(progress),
            // デバッグ: リセットボタン（必要に応じて削除）
            _buildResetButton(context, ref),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── ヘッダー ──────────────────────────────────────────────
  Widget _buildHeader(UserProgress p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: AppColors.scienceGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const Text(
            '📊 学習記録',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // ポイント
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 8),
              Text(
                '${p.totalPoints} pt',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ストリーク
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              p.streakDays > 0
                  ? '🔥 ${p.streakDays}日連続学習中！'
                  : '今日から学習を始めよう！',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── スタッツ ─────────────────────────────────────────────
  Widget _buildStatsRow(UserProgress p) {
    final avgScore = p.clearedStages.isEmpty
        ? '-'
        : '${p.averageScore}%';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _StatTile(
            emoji: '📚',
            value: '${p.clearedCount}',
            label: 'クリア数',
            color: AppColors.sciencePrimary,
          ),
          const SizedBox(width: 10),
          _StatTile(
            emoji: '🏅',
            value: '${p.earnedBadgeIds.length}',
            label: 'バッジ数',
            color: const Color(0xFFFF9800),
          ),
          const SizedBox(width: 10),
          _StatTile(
            emoji: '🎯',
            value: avgScore,
            label: '平均スコア',
            color: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  // ── バッジコレクション ────────────────────────────────────
  Widget _buildBadgeSection(BuildContext context, UserProgress p) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏅', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'バッジコレクション',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.scienceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${p.earnedBadgeIds.length} / ${allBadges.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.sciencePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemCount: allBadges.length,
            itemBuilder: (ctx, i) {
              final badge = allBadges[i];
              final earned = p.earnedBadgeIds.contains(badge.id);
              return GestureDetector(
                onTap: earned
                    ? () => _showBadgeDetail(ctx, badge)
                    : null,
                child: _BadgeTile(badge: badge, earned: earned),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, BadgeModel badge) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: badge.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textGray),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  // ── 学年別進捗 ────────────────────────────────────────────
  Widget _buildStageProgressSection(UserProgress p) {
    const grades = [3, 4, 5, 6];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📖', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                '学年別進捗',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...grades.map((grade) {
            final gradeStages = stagesData
                .where((s) => s['gradeLevel'] == grade)
                .toList();
            final cleared = gradeStages
                .where((s) => p.clearedStages.containsKey(s['id']))
                .length;
            return _GradeProgressRow(
              grade: grade,
              cleared: cleared,
              total: gradeStages.length,
            );
          }),
        ],
      ),
    );
  }

  // ── デバッグ用リセットボタン ────────────────────────────────
  Widget _buildResetButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: TextButton(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('記録をリセット'),
              content: const Text('学習記録をすべてリセットします。この操作は取り消せません。'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('キャンセル')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('リセット',
                        style: TextStyle(color: AppColors.error))),
              ],
            ),
          );
          if (confirmed == true) {
            await ref.read(userProgressProvider.notifier).resetProgress();
          }
        },
        child: const Text(
          '🔄 データをリセット（デバッグ）',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textGray,
          ),
        ),
      ),
    );
  }
}

// ── 補助ウィジェット ─────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.22)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final BadgeModel badge;
  final bool earned;

  const _BadgeTile({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: earned
            ? badge.color.withOpacity(0.1)
            : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: earned
              ? badge.color.withOpacity(0.4)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          earned
              ? Text(badge.emoji,
                  style: const TextStyle(fontSize: 24))
              : const Icon(Icons.lock_outline,
                  color: Colors.grey, size: 20),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              earned ? badge.name : '???',
              style: TextStyle(
                fontSize: 7.5,
                color:
                    earned ? AppColors.textDark : AppColors.textGray,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeProgressRow extends StatelessWidget {
  final int grade;
  final int cleared;
  final int total;

  const _GradeProgressRow({
    required this.grade,
    required this.cleared,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : cleared / total;
    final isComplete = cleared == total && total > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${grade}年生',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              if (isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'コンプリート！',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                '$cleared / $total',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.borderGray,
              valueColor: AlwaysStoppedAnimation(
                isComplete
                    ? AppColors.success
                    : AppColors.sciencePrimary,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
