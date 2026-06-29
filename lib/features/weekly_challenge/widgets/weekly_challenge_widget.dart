import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/weekly_challenge_provider.dart';

class WeeklyChallengeWidget extends ConsumerWidget {
  const WeeklyChallengeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weeklyChallengeProvider);

    return state.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) => _Card(data: data),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.data});
  final WeeklyChallengeState data;

  @override
  Widget build(BuildContext context) {
    final progress = data.completedCount / data.missions.length;
    final hasBonus = data.allComplete && !data.bonusClaimed;

    return GestureDetector(
      onTap: () => context.push('/weekly-challenge'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasBonus
                ? [const Color(0xFFFFF8E1), const Color(0xFFFFECB3)]
                : [const Color(0xFFEDE7F6), const Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasBonus
                ? const Color(0xFFFFC107)
                : const Color(0xFF9575CD).withValues(alpha: 0.4),
            width: hasBonus ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(hasBonus ? '🎁' : '🎯',
                style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '今週のチャレンジ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4527A0),
                        ),
                      ),
                      if (hasBonus) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('受け取れる！',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          const Color(0xFF9575CD).withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF7C4DFF)),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.completedCount}/${data.missions.length} クリア',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF7E57C2)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF9575CD)),
          ],
        ),
      ),
    );
  }
}
