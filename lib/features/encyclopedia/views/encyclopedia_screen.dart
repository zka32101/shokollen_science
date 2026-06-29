import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../data/seeds/creatures.dart';
import '../../progress/providers/user_progress_provider.dart';

/// 生き物図鑑タブ
class EncyclopediaScreen extends ConsumerStatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  ConsumerState<EncyclopediaScreen> createState() =>
      _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends ConsumerState<EncyclopediaScreen> {
  String _selectedCategory = 'all';

  static const _categories = [
    ('all', '全て', '🔬'),
    ('insect', '昆虫', '🦋'),
    ('bird', '鳥', '🐦'),
    ('mammal', '哺乳類', '🐾'),
    ('plant', '植物', '🌿'),
    ('other', 'その他', '🐌'),
  ];

  static const _categoryEmoji = {
    'insect': '🦋',
    'bird': '🐦',
    'mammal': '🐾',
    'plant': '🌿',
    'other': '🐌',
  };

  static const _categoryLabel = {
    'insect': '昆虫',
    'bird': '鳥',
    'mammal': '哺乳類',
    'plant': '植物',
    'other': 'その他',
  };

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(userProgressProvider);
    final clearedCount = progressAsync.value?.clearedCount ?? 0;

    // アンロック済みクリーチャー数（クリアステージ数と一致、最大16）
    final unlockedCount = clearedCount.clamp(0, creaturesData.length);

    final filtered = _selectedCategory == 'all'
        ? creaturesData
        : creaturesData
            .where((c) => c['category'] == _selectedCategory)
            .toList();

    return Column(
      children: [
        _buildHeader(unlockedCount),
        _buildCategoryFilter(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            physics: const BouncingScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final creature = filtered[i];
              // 全リスト中のインデックスでアンロック判定
              final globalIndex = creaturesData.indexOf(creature);
              final unlocked = globalIndex < unlockedCount;
              return _CreatureCard(
                data: creature,
                unlocked: unlocked,
                categoryEmoji: _categoryEmoji[creature['category']] ?? '🔬',
                onTap: unlocked
                    ? () => _showDetail(context, creature)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int unlockedCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        gradient: AppColors.scienceGradient,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🌿 生き物図鑑',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$unlockedCount / ${creaturesData.length} 体 発見',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          // 進捗円
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: unlockedCount / creaturesData.length,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 5,
                ),
              ),
              Text(
                '${((unlockedCount / creaturesData.length) * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (key, label, emoji) = _categories[i];
          final selected = _selectedCategory == key;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.sciencePrimary
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.sciencePrimary
                      : AppColors.borderGray,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.sciencePrimary
                              .withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Text(
                '$emoji $label',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatureDetailSheet(
        data: data,
        emoji: _categoryEmoji[data['category']] ?? '🔬',
        categoryLabel: _categoryLabel[data['category']] ?? 'その他',
      ),
    );
  }
}

// ── 生き物カード ─────────────────────────────────────────────
class _CreatureCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool unlocked;
  final String categoryEmoji;
  final VoidCallback? onTap;

  const _CreatureCard({
    required this.data,
    required this.unlocked,
    required this.categoryEmoji,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: unlocked ? AppColors.scienceLight : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: unlocked
                ? AppColors.sciencePrimary.withOpacity(0.3)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: AppColors.sciencePrimary.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (unlocked)
              Text(categoryEmoji,
                  style: const TextStyle(fontSize: 36))
            else
              const Icon(Icons.lock_outline,
                  color: Colors.grey, size: 28),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                unlocked ? (data['name'] as String) : '???',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: unlocked
                      ? AppColors.textDark
                      : AppColors.textGray,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unlocked) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.sciencePrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${data['difficultyLevel']}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.sciencePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 詳細ボトムシート ─────────────────────────────────────────
class _CreatureDetailSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  final String emoji;
  final String categoryLabel;

  const _CreatureDetailSheet({
    required this.data,
    required this.emoji,
    required this.categoryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final funFact = data['funFact'] as String?;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ドラッグハンドル
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── ヘッダー ──
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.scienceLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.sciencePrimary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 38)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] as String,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              data['scientificName'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textGray,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.sciencePrimary
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$emoji $categoryLabel',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.sciencePrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // レア度
                      Column(
                        children: [
                          const Text('レア度',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textGray)),
                          Text(
                            '⭐' * (data['difficultyLevel'] as int),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── 説明 ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.scienceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data['description'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 情報行 ──
                  const Text(
                    '📋 くわしい情報',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                      icon: '🏠', label: '生息地',
                      value: data['habitat'] as String),
                  _InfoRow(
                      icon: '✨', label: '特徴',
                      value: data['characteristics'] as String),
                  _InfoRow(
                      icon: '🍽️', label: '食べ物',
                      value: data['diet'] as String),

                  // ── 豆知識 ──
                  if (funFact != null && funFact.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFFFD54F), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💡 豆知識',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            funFact,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textDark,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── 関連ステージ ──
                  if ((data['relatedStageIds'] as List).isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      '📚 関連する学習単元',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: (data['relatedStageIds'] as List)
                          .map((id) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.scienceLight,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppColors.sciencePrimary
                                          .withOpacity(0.3)),
                                ),
                                child: Text(
                                  id as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.sciencePrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
