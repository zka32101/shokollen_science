import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../data/seeds/stages.dart';
import '../../../data/seeds/experiment_data.dart';
import '../../progress/providers/user_progress_provider.dart';

/// まなぶタブ - 全学年ステージ一覧
class LearnTabScreen extends ConsumerStatefulWidget {
  const LearnTabScreen({super.key});

  @override
  ConsumerState<LearnTabScreen> createState() => _LearnTabScreenState();
}

class _LearnTabScreenState extends ConsumerState<LearnTabScreen> {
  int _selectedGrade = 3;
  bool _showExperiment = false;

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(userProgressProvider);
    final clearedStages = progressAsync.value?.clearedStages ?? {};

    final gradeStages = stagesData
        .where((s) => s['gradeLevel'] == _selectedGrade)
        .toList();

    return Column(
      children: [
        _buildHeader(),
        if (_showExperiment)
          Expanded(child: _buildExperimentList())
        else ...[
          _buildGradeSelector(clearedStages),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              physics: const BouncingScrollPhysics(),
              itemCount: gradeStages.length,
              itemBuilder: (_, i) => _LearnStageTile(
                stageData: gradeStages[i],
                bestScore: clearedStages[gradeStages[i]['id']],
                onTap: () => context.push(
                  '/learn/${gradeStages[i]['id']}',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _showExperiment
            ? LinearGradient(
                colors: [Colors.orange[700]!, Colors.deepOrange[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppColors.scienceGradient,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              _showExperiment ? '🔬 じっけん' : '📖 まなぶ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // トグル
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                _toggleBtn('📖 まなぶ', !_showExperiment, () {
                  setState(() => _showExperiment = false);
                }),
                const SizedBox(width: 8),
                _toggleBtn('🔬 じっけん', _showExperiment, () {
                  setState(() => _showExperiment = true);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: active
                ? (_showExperiment ? Colors.orange[700] : AppColors.sciencePrimary)
                : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildExperimentList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: experimentData.length,
      itemBuilder: (_, i) {
        final exp = experimentData[i];
        return GestureDetector(
          onTap: () => context.push('/experiment/${exp['id']}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(exp['emoji'] as String,
                      style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exp['title'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          )),
                      const SizedBox(height: 2),
                      Text(
                        '${exp['grade']}年生 ⏱ ${exp['estimatedMinutes']}分',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.orange.shade400),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradeSelector(Map<String, int> clearedStages) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [3, 4, 5, 6].map((grade) {
          final selected = _selectedGrade == grade;
          final gradeStages = stagesData
              .where((s) => s['gradeLevel'] == grade)
              .toList();
          final cleared = gradeStages
              .where((s) => clearedStages.containsKey(s['id']))
              .length;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedGrade = grade),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.sciencePrimary
                      : AppColors.scienceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? AppColors.sciencePrimary
                        : AppColors.borderGray,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${grade}年',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? Colors.white
                            : AppColors.textDark,
                      ),
                    ),
                    Text(
                      '$cleared/${gradeStages.length}',
                      style: TextStyle(
                        fontSize: 10,
                        color: selected
                            ? Colors.white70
                            : AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LearnStageTile extends StatelessWidget {
  final Map<String, dynamic> stageData;
  final int? bestScore;
  final VoidCallback onTap;

  const _LearnStageTile({
    required this.stageData,
    required this.onTap,
    this.bestScore,
  });

  static const _categoryColor = {
    'biology': Color(0xFF43A047),
    'physics': Color(0xFF1E88E5),
    'chemistry': Color(0xFF8E24AA),
    'earth': Color(0xFF6D4C41),
  };
  static const _categoryEmoji = {
    'biology': '🌱',
    'physics': '⚡',
    'chemistry': '🧪',
    'earth': '🌍',
  };

  @override
  Widget build(BuildContext context) {
    final cat = stageData['category'] as String;
    final color = _categoryColor[cat] ?? AppColors.sciencePrimary;
    final emoji = _categoryEmoji[cat] ?? '🔬';
    final isCleared = bestScore != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCleared
                ? AppColors.success.withOpacity(0.4)
                : AppColors.borderGray,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stageData['stageName'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stageData['description'] as String,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: color,
                  size: 18,
                ),
                if (isCleared) ...[
                  const SizedBox(height: 4),
                  Text(
                    '✅ $bestScore%',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
