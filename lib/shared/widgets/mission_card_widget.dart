import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/mission/providers/mission_provider.dart';
import '../constants/app_colors.dart';

class MissionCardWidget extends ConsumerWidget {
  const MissionCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionAsync = ref.watch(missionProvider);
    return missionAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (state) {
        final completed = state.completedCount;
        final total = state.missions.length;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    const Text('今日のミッション',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('$completed/$total',
                        style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // ミッション一覧
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: state.missions.map((mission) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: mission.completed ? Colors.green[100] : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Text(mission.completed ? '✅' : mission.emoji,
                              style: const TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mission.title,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: mission.completed ? Colors.grey[400] : AppColors.textDark,
                              decoration: mission.completed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: mission.completed ? Colors.grey[100] : Colors.amber[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '🪙 +${mission.coinReward}',
                            style: TextStyle(
                              fontSize: 11,
                              color: mission.completed ? Colors.grey[400] : Colors.amber[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
