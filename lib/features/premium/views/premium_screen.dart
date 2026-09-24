import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../trial/providers/trial_provider.dart';

/// プレミアムプラン紹介・購入画面
///
/// NOTE: RevenueCat 等の実IAP連携は未実装。現時点では UI 導線のみで、
/// 「購入する」ボタンは trialProvider.activatePremium() を呼び本体機能は
/// アンロックされるが、実際の課金処理・レシート検証は行っていない。
/// 本番リリース前に RevenueCat SDK を組み込むこと。
class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  static const List<_PlanFeature> _features = [
    _PlanFeature(icon: '🔬', label: '全ステージ・全学年の理科クイズが遊び放題'),
    _PlanFeature(icon: '🧪', label: '実験ラボ・よそうラボ・失敗ラボが全て解放'),
    _PlanFeature(icon: '🤖', label: 'AIはかせチャットが使い放題'),
    _PlanFeature(icon: '📊', label: '保護者ダッシュボードで週次レポート閲覧'),
    _PlanFeature(icon: '🚫', label: '広告表示なし'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trial = ref.watch(trialProvider).value;
    final isPremium = trial?.isPremium ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('プレミアムプラン'),
        backgroundColor: AppColors.sciencePrimary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.scienceGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  isPremium ? 'プレミアム会員です！' : '小学コレ！理科 プレミアム',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                if (!isPremium)
                  const Text(
                    'すべてのきのうが使い放題に！',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ..._features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(f.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f.label,
                        style: const TextStyle(
                            fontSize: 15, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          if (!isPremium) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.scienceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sciencePrimary, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    '月額プラン',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.scienceSecondary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '¥300 / 月',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.sciencePrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trial != null && trial.isTrialActive
                        ? '無料トライアル残り ${trial.trialDaysRemaining} 日'
                        : '無料トライアルは終了しています',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sciencePrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _purchase(context, ref),
                child: const Text(
                  'プレミアムに登録する',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '※ このボタンは現在プレースホルダーです。実際の決済処理は未実装のため、'
              '本番リリース前に課金SDKとの連携が必要です。',
              style: TextStyle(fontSize: 11, color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const Center(
              child: Text('🎉 いつもありがとうございます！',
                  style: TextStyle(fontSize: 16, color: AppColors.textDark)),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _purchase(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('プレミアムに登録しますか？'),
        content: const Text(
          '（開発中）実際の決済は行われません。動作確認のためプレミアム機能を有効にします。',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(trialProvider.notifier).activatePremium();
            },
            child: const Text('登録する'),
          ),
        ],
      ),
    );
  }
}

class _PlanFeature {
  final String icon;
  final String label;
  const _PlanFeature({required this.icon, required this.label});
}
