import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/premium/views/premium_screen.dart';
import '../../features/trial/providers/trial_provider.dart';

/// クイズアクセス制御ウィジェット
///
/// トライアル期間終了かつプレミアム未購入の場合、クイズ本体の代わりに
/// プレミアム登録画面（[PremiumScreen]）を表示してブロックする。
///
/// クイズ・実験ラボなど「答える」系の全画面は、ルーティング（router.dart）で
/// このウィジェットで child をラップすること。
class QuizAccessGuard extends ConsumerWidget {
  /// ラップするウィジェット（クイズ・実験系の画面）
  final Widget child;

  const QuizAccessGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trialAsync = ref.watch(trialProvider);

    return trialAsync.when(
      data: (trial) {
        // プレミアム or トライアル中 → 通常表示
        if (trial.isPremium || trial.isTrialActive) {
          return child;
        }
        // トライアル終了・未購入 → プレミアム登録画面をその場に表示
        return const PremiumScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      // 状態取得エラー時は安全側（アクセス不可）に倒す
      error: (_, __) => const PremiumScreen(),
    );
  }
}
