import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../data/seeds/experiment_data.dart';

/// 実験タブ - 実験一覧
class ExperimentTabScreen extends StatefulWidget {
  const ExperimentTabScreen({super.key});

  @override
  State<ExperimentTabScreen> createState() => _ExperimentTabScreenState();
}

class _ExperimentTabScreenState extends State<ExperimentTabScreen> {
  int _selectedGrade = 0; // 0=すべて

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedGrade == 0
        ? experimentData
        : experimentData.where((e) => e['grade'] == _selectedGrade).toList();

    return Column(
      children: [
        _buildHeader(),
        _buildGradeFilter(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _ExperimentCard(
              data: filtered[i],
              onTap: () => context.push('/experiment/${filtered[i]['id']}'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[700]!, Colors.deepOrange[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔬 じっけん',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '自分でやってみよう！理科の実験',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _filterChip(0, 'すべて'),
          const SizedBox(width: 6),
          _filterChip(3, '3年'),
          const SizedBox(width: 6),
          _filterChip(4, '4年'),
          const SizedBox(width: 6),
          _filterChip(5, '5年'),
          const SizedBox(width: 6),
          _filterChip(6, '6年'),
        ],
      ),
    );
  }

  Widget _filterChip(int grade, String label) {
    final selected = _selectedGrade == grade;
    return GestureDetector(
      onTap: () => setState(() => _selectedGrade = grade),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.orange[700] : Colors.orange[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.orange[700]! : Colors.orange[200]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Colors.orange[800],
          ),
        ),
      ),
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ExperimentCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // ヘッダー
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Text(data['emoji'] as String,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _badge('${data['grade']}年生', Colors.orange[700]!),
                            const SizedBox(width: 6),
                            _badge(
                              '⏱ ${data['estimatedMinutes']}分',
                              Colors.grey[600]!,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textGray),
                ],
              ),
            ),
            // 材料プレビュー
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📦 用意するもの',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: (data['materials'] as List<String>)
                        .take(4)
                        .map((m) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(m,
                                  style: const TextStyle(fontSize: 11)),
                            ))
                        .toList()
                      ..addAll(
                        (data['materials'] as List<String>).length > 4
                            ? [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '+${(data['materials'] as List<String>).length - 4}個',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange[700]),
                                  ),
                                )
                              ]
                            : [],
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
