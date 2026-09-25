import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../trial/providers/trial_provider.dart';
import '../services/science_purchase_service.dart';

/// プレミアムプラン紹介・購入画面（RevenueCat 連携）
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  static const List<_PlanFeature> _features = [
    _PlanFeature(icon: '🔬', label: '全ステージ・全学年の理科クイズが遊び放題'),
    _PlanFeature(icon: '🧪', label: '実験ラボ・よそうラボ・失敗ラボが全て解放'),
    _PlanFeature(icon: '📊', label: '保護者ダッシュボードで週次レポート閲覧'),
    _PlanFeature(icon: '🚫', label: '広告表示なし'),
  ];

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    SciencePurchaseService.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
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
          ...PremiumScreen._features.map((f) => Padding(
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
                onPressed: _isProcessing ? null : _purchase,
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'プレミアムに登録する',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isProcessing ? null : _restore,
              child: const Text('購入を復元する'),
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

  Future<void> _purchase() async {
    setState(() => _isProcessing = true);
    final result = await SciencePurchaseService.instance.purchaseMonthly();
    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result.outcome) {
      case PurchaseOutcome.success:
        await ref.read(trialProvider.notifier).activatePremium();
        if (!mounted) return;
        _showMessage('🎉 プレミアムに登録しました！');
        break;
      case PurchaseOutcome.cancelled:
        // ユーザーがキャンセル。何もしない。
        break;
      case PurchaseOutcome.notConfigured:
        _showMessage('現在、購入機能を準備中です。しばらくしてから再度お試しください。');
        break;
      case PurchaseOutcome.noOfferings:
        _showMessage('現在、購入可能なプランがありません。しばらくしてから再度お試しください。');
        break;
      case PurchaseOutcome.error:
        _showMessage('購入処理でエラーが発生しました。時間をおいて再度お試しください。');
        break;
    }
  }

  Future<void> _restore() async {
    setState(() => _isProcessing = true);
    final result = await SciencePurchaseService.instance.restore();
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result.outcome == PurchaseOutcome.success) {
      await ref.read(trialProvider.notifier).activatePremium();
      if (!mounted) return;
      _showMessage('購入情報を復元しました！');
    } else {
      _showMessage('復元できる購入情報が見つかりませんでした。');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PlanFeature {
  final String icon;
  final String label;
  const _PlanFeature({required this.icon, required this.label});
}
