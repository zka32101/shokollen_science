import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart'
    show ReviewTodayCard, onboardingProvider;

import '../../../shared/constants/app_colors.dart';

/// ホーム画面に出す定着率施策（初回7日間の報酬・今日の復習）。
/// 出すものがなければ何も表示しない。
/// 週次チャレンジはこのアプリ独自の機能（WeeklyChallengeWidget）があるため出さない。
class RetentionSection extends ConsumerWidget {
  const RetentionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final claimable = onboarding.claimable;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          if (claimable.isNotEmpty)
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🎁 はじめての7日間ごほうび（${onboarding.claimedDays.length}/7）',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (final r in claimable)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('${r.day}日目: ${r.title}'),
                        subtitle: Text(r.description),
                        trailing: FilledButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final got = await ref
                                .read(onboardingProvider.notifier)
                                .claim(r.day);
                            if (got != null) {
                              messenger.showSnackBar(SnackBar(
                                  content:
                                      Text('🪙 ${got.coins} コインをもらったよ！')));
                            }
                          },
                          child: Text('🪙 ${r.coins}'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          // 遷移先はこのアプリの「にがて問題」復習画面
          ReviewTodayCard(
            color: AppColors.sciencePrimary,
            onStart: () => context.push('/review'),
          ),
        ],
      ),
    );
  }
}
