import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../data/seeds/stages.dart';
import '../../../data/seeds/experiment_data.dart';
import '../../progress/providers/user_progress_provider.dart';
import '../../progress/models/badge_model.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});
  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Column(
        children: [
          // ヘッダー
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.scienceGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Text('📚 コレクション帳',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        if (progress != null)
                          Text(
                            'クリア: ${progress.clearedCount}/36',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabCtrl,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: '📖 ステージ'),
                      Tab(text: '🔬 実験'),
                      Tab(text: '🏅 バッジ'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildStageCollection(progress),
                _buildExperimentCollection(progress),
                _buildBadgeCollection(progress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCollection(dynamic progress) {
    final cleared = progress?.clearedStages as Map<String, int>? ?? {};
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [3, 4, 5, 6].map((grade) {
        final gradeStages = stagesData.where((s) => s['gradeLevel'] == grade).toList();
        final clearedCount = gradeStages.where((s) => cleared.containsKey(s['id'])).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Row(
                children: [
                  Text('$grade年生',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('$clearedCount/${gradeStages.length}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
                ],
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.9,
              children: gradeStages.map((stage) {
                final stageId = stage['id'] as String;
                final isCleared = cleared.containsKey(stageId);
                final score = cleared[stageId] ?? 0;
                final catEmoji = {'biology': '🌱', 'physics': '⚡', 'chemistry': '🧪', 'earth': '🌍'}[stage['category']] ?? '🔬';

                return Container(
                  decoration: BoxDecoration(
                    color: isCleared ? Colors.white : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCleared ? AppColors.success.withValues(alpha: 0.5) : Colors.grey[300]!,
                    ),
                    boxShadow: isCleared ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)] : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isCleared ? catEmoji : '🔒',
                          style: TextStyle(fontSize: isCleared ? 24 : 20)),
                      const SizedBox(height: 4),
                      Text(
                        stage['stageName'] as String,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isCleared ? AppColors.textDark : Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isCleared) ...[
                        const SizedBox(height: 2),
                        Text('$score%',
                            style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // まとめテストボタン
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/comprehensive-test/$grade'),
                icon: const Icon(Icons.quiz_rounded, size: 16),
                label: Text('$grade年生まとめテスト'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple[700],
                  side: BorderSide(color: Colors.purple[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildExperimentCollection(dynamic progress) {
    final cleared = progress?.clearedStages as Map<String, int>? ?? {};
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: experimentData.length,
      itemBuilder: (_, i) {
        final exp = experimentData[i];
        final relatedId = exp['relatedStageId'] as String;
        final isUnlocked = cleared.containsKey(relatedId);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.white : Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnlocked ? Colors.orange.shade200 : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              Text(isUnlocked ? exp['emoji'] as String : '🔒',
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exp['title'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppColors.textDark : Colors.grey[400],
                        )),
                    Text(
                      isUnlocked ? '${exp['grade']}年生 ⏱${exp['estimatedMinutes']}分' : '関連ステージをクリアして解放',
                      style: TextStyle(fontSize: 11, color: isUnlocked ? Colors.orange[700] : Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              if (isUnlocked)
                GestureDetector(
                  onTap: () => context.push('/experiment/${exp['id']}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text('見る', style: TextStyle(fontSize: 11, color: Colors.orange[700], fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeCollection(dynamic progress) {
    final earned = (progress?.earnedBadgeIds as List<String>?) ?? [];
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: allBadges.map((badge) {
        final isEarned = earned.contains(badge.id);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isEarned ? Colors.white : Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isEarned ? Colors.amber.shade300 : Colors.grey[300]!,
              width: isEarned ? 2 : 1,
            ),
            boxShadow: isEarned ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.15), blurRadius: 8)] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isEarned ? badge.emoji : '🔒',
                  style: TextStyle(fontSize: isEarned ? 32 : 24)),
              const SizedBox(height: 4),
              Text(badge.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isEarned ? AppColors.textDark : Colors.grey[400],
                  ),
                  textAlign: TextAlign.center),
              if (isEarned)
                Text(badge.description,
                    style: const TextStyle(fontSize: 9.5, color: AppColors.textGray),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      }).toList(),
    );
  }
}
