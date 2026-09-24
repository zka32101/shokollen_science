import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../data/seeds/experiment_data.dart';
import '../../progress/providers/user_progress_provider.dart';
import '../../progress/views/badge_earned_dialog.dart';

class ExperimentDetailScreen extends ConsumerStatefulWidget {
  final String experimentId;
  const ExperimentDetailScreen({super.key, required this.experimentId});

  @override
  ConsumerState<ExperimentDetailScreen> createState() =>
      _ExperimentDetailScreenState();
}

class _ExperimentDetailScreenState
    extends ConsumerState<ExperimentDetailScreen> {
  bool _isSubmitting = false;

  Future<void> _markDone() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final result = await ref
        .read(userProgressProvider.notifier)
        .completeExperiment(widget.experimentId);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.coinsEarned > 0
            ? 'じっけんかんりょう！ +${result.coinsEarned}コイン'
            : 'すでにチェックずみだよ'),
        duration: const Duration(seconds: 2),
      ),
    );

    if (result.badges.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => BadgeEarnedDialog(badges: result.badges),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = experimentData.firstWhere(
      (e) => e['id'] == widget.experimentId,
      orElse: () => experimentData[0],
    );
    final progressAsync = ref.watch(userProgressProvider);
    final isDone =
        progressAsync.value?.isExperimentCompleted(widget.experimentId) ??
            false;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, data),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(data),
                  const SizedBox(height: 16),
                  _buildMaterialsCard(data),
                  const SizedBox(height: 12),
                  _buildStepsCard(data),
                  const SizedBox(height: 12),
                  _buildPointCard(data),
                  const SizedBox(height: 12),
                  _buildSafetyCard(data),
                  const SizedBox(height: 20),
                  _buildDoneButton(isDone),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton(bool isDone) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: (_isSubmitting || isDone) ? null : _markDone,
        icon: Icon(isDone ? Icons.check_circle : Icons.check_circle_outline),
        label: Text(
          isDone ? 'じっけんしたよ ✅' : 'じっけんした！チェックする',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDone ? Colors.green[600] : Colors.orange[700],
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.green[600],
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, Map<String, dynamic> data) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: Colors.orange[700],
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          data['title'] as String,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[800]!, Colors.deepOrange[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              data['emoji'] as String,
              style: const TextStyle(fontSize: 64),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(Map<String, dynamic> data) {
    return Row(
      children: [
        _infoChip('${data['grade']}年生', Icons.school_rounded,
            Colors.orange[700]!),
        const SizedBox(width: 8),
        _infoChip(
            '⏱ 約${data['estimatedMinutes']}分', Icons.timer_rounded, Colors.grey[600]!),
      ],
    );
  }

  Widget _infoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 13, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMaterialsCard(Map<String, dynamic> data) {
    final materials = data['materials'] as List<String>;
    return _sectionCard(
      title: '📦 用意するもの',
      color: Colors.blue[600]!,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: materials
            .map((m) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_box_outline_blank,
                          size: 14, color: Colors.blue[400]),
                      const SizedBox(width: 4),
                      Text(m, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStepsCard(Map<String, dynamic> data) {
    final steps = data['steps'] as List<String>;
    return _sectionCard(
      title: '🧪 実験の手順',
      color: Colors.green[600]!,
      child: Column(
        children: steps.asMap().entries.map((e) {
          final i = e.key;
          final step = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(step,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                            height: 1.5)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPointCard(Map<String, dynamic> data) {
    return _sectionCard(
      title: '💡 学びのポイント',
      color: Colors.amber[700]!,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          data['point'] as String,
          style: const TextStyle(
              fontSize: 14, color: AppColors.textDark, height: 1.6),
        ),
      ),
    );
  }

  Widget _buildSafetyCard(Map<String, dynamic> data) {
    return _sectionCard(
      title: '⚠️ 安全上の注意',
      color: Colors.red[600]!,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Text(
          data['safetyNote'] as String,
          style: const TextStyle(
              fontSize: 13, color: AppColors.textDark, height: 1.6),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
