import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../progress/providers/user_progress_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../data/seeds/stages.dart';
import '../providers/praise_provider.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});
  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  bool _unlocked = false;
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) return _buildPinScreen(context);
    return _buildDashboard(context);
  }

  Widget _buildPinScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.scienceGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text('保護者ダッシュボード',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('確認のため、お子様の生まれた年を入力してください',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                      decoration: const InputDecoration(
                        hintText: '----',
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('もどる'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 4桁入力で解除（年度チェックは簡易）
                            if (_pinController.text.length == 4) {
                              setState(() => _unlocked = true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.sciencePrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('かくにん', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final progressAsync = ref.watch(userProgressProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.sciencePrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('保護者ダッシュボード',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              background: DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.scienceGradient),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: progressAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
              error: (_, __) => const Center(child: Text('エラー')),
              data: (progress) {
                final profile = profileAsync.value?.activeProfile;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // プロフィール
                      if (profile != null) _profileCard(profile),
                      const SizedBox(height: 16),
                      // 未ほめステージ（ほめ導線）
                      _buildPraiseSection(context),
                      // サマリー
                      _summaryRow(progress),
                      const SizedBox(height: 16),
                      // 学年別進捗
                      _sectionTitle('📚 学年別クリア状況'),
                      const SizedBox(height: 8),
                      ...[3, 4, 5, 6].map((grade) => _gradeProgress(grade, progress.clearedStages)),
                      const SizedBox(height: 16),
                      // バッジ
                      _sectionTitle('🏅 獲得バッジ: ${progress.earnedBadgeIds.length}/10'),
                      const SizedBox(height: 8),
                      _badgeBar(progress.earnedBadgeIds.length),
                      const SizedBox(height: 16),
                      // アドバイス
                      _adviceCard(progress),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPraiseSection(BuildContext context) {
    final pendingAsync = ref.watch(pendingPraiseProvider);
    return pendingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (pending) {
        if (pending.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('💌 ほめてあげましょう！（${pending.length}件）'),
            const SizedBox(height: 8),
            ...pending.map((stage) => _praiseStageCard(context, stage)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _praiseStageCard(BuildContext context, Map<String, String> stage) {
    final stageId = stage['stageId'] ?? '';
    final stageName = stage['stageName'] ?? stageId;
    return GestureDetector(
      onTap: () => context.push(
        '/praise-send/$stageId',
        extra: {'stageName': stageName},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE91E8C).withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '全問正解！',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  Text(
                    stageName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'ほめる 💌',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Text(profile.avatarEmoji as String, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.nickname as String,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${profile.gradeLevel}年生',
                  style: const TextStyle(fontSize: 13, color: AppColors.textGray)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(dynamic progress) {
    return Row(
      children: [
        _summaryCard('🎯', 'クリア数', '${progress.clearedCount}/36ステージ', AppColors.sciencePrimary),
        const SizedBox(width: 10),
        _summaryCard('⭐', '平均スコア', '${progress.averageScore}%', AppColors.success),
        const SizedBox(width: 10),
        _summaryCard('🔥', '連続日数', '${progress.streakDays}日', Colors.orange),
      ],
    );
  }

  Widget _summaryCard(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGray)),
          ],
        ),
      ),
    );
  }

  Widget _gradeProgress(int grade, Map<String, int> cleared) {
    final gradeStages = stagesData.where((s) => s['gradeLevel'] == grade).toList();
    final clearedCount = gradeStages.where((s) => cleared.containsKey(s['id'])).length;
    final total = gradeStages.length;
    final avg = gradeStages.isEmpty ? 0 : gradeStages
        .where((s) => cleared.containsKey(s['id']))
        .fold(0, (sum, s) => sum + (cleared[s['id']] ?? 0)) ~/ (clearedCount == 0 ? 1 : clearedCount);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$grade年生', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('$clearedCount/$total クリア  平均$avg%',
                  style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : clearedCount / total,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.sciencePrimary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeBar(int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text('$count個獲得', style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
        ],
      ),
    );
  }

  Widget _adviceCard(dynamic progress) {
    String advice;
    if (progress.clearedCount == 0) {
      advice = 'まだ学習を始めていません。一緒にスタートしてみましょう！';
    } else if (progress.averageScore < 60) {
      advice = '正答率が低めです。「まなぶ」タブで解説を読んでからクイズに挑戦すると効果的です。';
    } else if (progress.streakDays == 0) {
      advice = '毎日少しずつ学習するとより効果的です。デイリーチャレンジを活用しましょう！';
    } else {
      advice = '順調に学習が進んでいます！この調子で続けましょう。ストリーク${progress.streakDays}日は素晴らしいです！';
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.scienceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sciencePrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(advice, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark));
  }
}
