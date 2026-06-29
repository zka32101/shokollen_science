import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/home_lab_data.dart';
import '../providers/home_lab_provider.dart';

// ③ おうちラボ: 週末リアル実験ミッション
class HomeLabScreen extends ConsumerStatefulWidget {
  const HomeLabScreen({super.key});

  @override
  ConsumerState<HomeLabScreen> createState() => _HomeLabScreenState();
}

class _HomeLabScreenState extends ConsumerState<HomeLabScreen> {
  bool _showReport = false;
  final _reportController = TextEditingController();

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mission = ref.watch(currentMissionProvider);
    final labState = ref.watch(homeLabProvider);
    final alreadyReported = labState.hasReportedThisWeek(mission.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('おうちラボ 🏡'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeekBadge(),
            const SizedBox(height: 16),
            _buildMissionCard(mission),
            const SizedBox(height: 16),
            _buildMaterialsList(mission),
            const SizedBox(height: 16),
            _buildExpectedResult(mission),
            const SizedBox(height: 16),
            _buildSciencePoint(mission),
            const SizedBox(height: 24),
            if (!alreadyReported) ...[
              if (!_showReport)
                _buildReportButton()
              else
                _buildReportForm(mission),
            ] else
              _buildAlreadyReported(labState.reports
                  .firstWhere((r) => r.missionId == mission.id)),
            const SizedBox(height: 16),
            _buildPastMissions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekBadge() {
    final now = DateTime.now();
    final weekNum =
        ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7).floor() + 1;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '第${weekNum}週のミッション',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${now.month}月${now.day}日〜',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildMissionCard(HomeLabMission mission) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(mission.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${mission.grade}年生むけ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mission.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            mission.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(HomeLabMission mission) {
    return _buildSection(
      title: '🛒 用意するもの',
      color: Colors.green.shade50,
      borderColor: Colors.green.shade200,
      child: Column(
        children: mission.materials
            .map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_box_outline_blank,
                          size: 18, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(m,
                            style: const TextStyle(fontSize: 14, height: 1.4)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildExpectedResult(HomeLabMission mission) {
    return _buildSection(
      title: '🔭 予想される結果',
      color: Colors.blue.shade50,
      borderColor: Colors.blue.shade200,
      child: Text(
        mission.expectedResult,
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildSciencePoint(HomeLabMission mission) {
    return _buildSection(
      title: '💡 理科のポイント',
      color: Colors.amber.shade50,
      borderColor: Colors.amber.shade300,
      child: Text(
        mission.sciencePoint,
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Color color,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildReportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _showReport = true),
        icon: const Text('🧪', style: TextStyle(fontSize: 18)),
        label: const Text(
          'やってみた！報告する (+30コイン)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildReportForm(HomeLabMission mission) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📝 実験結果を教えてね！',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reportController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '「○○になった！」「○○が起きた」「予想と違ったのは...」など',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.green.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
              ),
              filled: true,
              fillColor: Colors.green.shade50,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      setState(() => _showReport = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('キャンセル'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _reportController.text.trim().isEmpty
                      ? null
                      : () => _submitReport(mission),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '報告して +30コイン！',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyReported(HomeLabReport report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text(
                '今週のミッション完了！',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '+30コイン',
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '報告内容: ${report.result}',
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPastMissions() {
    final labState = ref.watch(homeLabProvider);
    final reportedIds = labState.reports.map((r) => r.missionId).toSet();
    if (reportedIds.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'これまでのラボ記録',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...labState.reports.map((r) {
          final mission = homeLabMissions
              .where((m) => m.id == r.missionId)
              .firstOrNull;
          if (mission == null) return const SizedBox.shrink();
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Text(mission.emoji,
                style: const TextStyle(fontSize: 24)),
            title: Text(mission.title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(r.result,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.check_circle,
                color: Colors.green, size: 18),
          );
        }),
      ],
    );
  }

  Future<void> _submitReport(HomeLabMission mission) async {
    final text = _reportController.text.trim();
    if (text.isEmpty) return;

    await ref.read(homeLabProvider.notifier).submitReport(
          missionId: mission.id,
          result: text,
        );

    if (!mounted) return;
    setState(() => _showReport = false);
    _reportController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎉 実験報告完了！'),
        content: const Text('+30コインをゲット！\n来週もおうちラボに挑戦しよう！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
