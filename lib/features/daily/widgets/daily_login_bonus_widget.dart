import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../../progress/providers/user_progress_provider.dart';
import '../providers/daily_login_bonus_provider.dart';

class DailyLoginBonusWidget extends ConsumerWidget {
  const DailyLoginBonusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bonusAsync = ref.watch(dailyLoginBonusProvider);

    return bonusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (bonus) {
        if (bonus.hasClaimedToday) {
          // 本日既に受け取り済み → ミニ表示
          return _BuildClaimedToday(bonus: bonus);
        } else {
          // 本日未受け取り → クリック可能
          return _BuildClaimButton(bonus: bonus, ref: ref);
        }
      },
    );
  }
}

class _BuildClaimButton extends ConsumerWidget {
  final DailyBonusState bonus;
  final WidgetRef ref;

  const _BuildClaimButton({required this.bonus, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showClaimDialog(context, ref, bonus),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.sciencePrimary.withOpacity(0.9),
              AppColors.scienceSecondary.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.sciencePrimary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FuriganaText(
                    '今日のプレゼント',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${bonus.coinsForToday}コイン獲得 • ${bonus.consecutiveDays}日目',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'タップ',
                style: TextStyle(
                  fontSize: 12,
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

  Future<void> _showClaimDialog(
    BuildContext context,
    WidgetRef ref,
    DailyBonusState bonus,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ClaimBonusDialog(bonus: bonus, ref: ref),
    );
  }
}

class _ClaimBonusDialog extends ConsumerStatefulWidget {
  final DailyBonusState bonus;
  final WidgetRef ref;

  const _ClaimBonusDialog({required this.bonus, required this.ref});

  @override
  ConsumerState<_ClaimBonusDialog> createState() => _ClaimBonusDialogState();
}

class _ClaimBonusDialogState extends ConsumerState<_ClaimBonusDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animCtrl.forward();

    // 1秒後にボーナス獲得処理
    Future.delayed(const Duration(milliseconds: 500), _claimBonus);
  }

  Future<void> _claimBonus() async {
    await widget.ref
        .read(dailyLoginBonusProvider.notifier)
        .claimBonus();

    // コイン追加
    await widget.ref
        .read(userProgressProvider.notifier)
        .addCoins(widget.bonus.coinsForToday);

    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0)
              .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 56),
                ),
                const SizedBox(height: 16),
                FuriganaText(
                  'おめでとう！',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sciencePrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.bonus.coinsForToday}コイン獲得！',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                // ストリーク表示
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      FuriganaText(
                        '${widget.bonus.consecutiveDays}日連続！',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // マイルストーン表示
                if (widget.bonus.isMilestone) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1BEE7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🌟 マイルストーン達成！',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _milestoneText(widget.bonus.consecutiveDays),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sciencePrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: const Text(
                    'ホームに戻る',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _milestoneText(int day) {
    return switch (day) {
      7 => '7日連続達成！ウィークリーボックスをゲット 🎁',
      14 => '2週間連続達成！限定キャラ「ニチニチ」をゲット ✨',
      30 => '1ヶ月連続達成！伝説キャラ「マンスリー」をゲット 🌙',
      _ => '連続ボーナス達成！',
    };
  }
}

class _BuildClaimedToday extends StatelessWidget {
  final DailyBonusState bonus;

  const _BuildClaimedToday({required this.bonus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('✅', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日のプレゼント受け取り済み',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '明日も来てね！（${bonus.consecutiveDays}日目）',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
