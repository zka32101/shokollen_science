import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/progress/providers/user_progress_provider.dart';

/// ホーム画面に表示する博士キャラ（ポイントに応じてレベルアップ）
class DoctorCharacterWidget extends ConsumerWidget {
  const DoctorCharacterWidget({super.key});

  static const _levels = [
    (emoji: '🐣', name: 'たまご', min: 0),
    (emoji: '🐥', name: 'ひよこ', min: 50),
    (emoji: '🐧', name: 'ペンギン', min: 150),
    (emoji: '🦉', name: 'ふくろう', min: 300),
    (emoji: '🦅', name: 'わしはかせ', min: 600),
    (emoji: '🧑‍🔬', name: 'はかせ', min: 1000),
    (emoji: '👨‍🏫', name: 'だいはかせ', min: 2000),
    (emoji: '🏆', name: '理科マスター', min: 3000),
  ];

  ({String emoji, String name, int min}) _getLevel(int points) {
    for (int i = _levels.length - 1; i >= 0; i--) {
      if (points >= _levels[i].min) return _levels[i];
    }
    return _levels[0];
  }

  ({String emoji, String name, int min})? _getNextLevel(int points) {
    for (final level in _levels) {
      if (level.min > points) return level;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider).value;
    final points = progress?.totalPoints ?? 0;
    final level = _getLevel(points);
    final next = _getNextLevel(points);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          // キャラクター
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF5C9BD4), width: 2),
            ),
            child: Center(child: Text(level.emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(level.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C9BD4).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$points pt',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF5C9BD4), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (next != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (points - (_getLevel(points).min)).toDouble() /
                          (next.min - _getLevel(points).min).toDouble(),
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5C9BD4)),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('次のレベル「${next.name}」まで ${next.min - points}pt',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
                ] else
                  const Text('最高レベル達成！🏆', style: TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
