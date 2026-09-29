import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
  // ストアから取得できるまでの概算表示。取得できたら実際の価格に差し替える。
  String _monthlyPrice = '¥300 / 月';
  String _annualPrice = '¥2,400 / 年';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await SciencePurchaseService.instance.initialize();
    if (!SciencePurchaseService.instance.isConfigured) return;
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      final monthly = current?.monthly?.storeProduct.priceString;
      final annual = current?.annual?.storeProduct.priceString;
      if (!mounted) return;
      setState(() {
        if (monthly != null) _monthlyPrice = '$monthly / 月';
        if (annual != null) _annualPrice = '$annual / 年';
      });
    } catch (_) {
      // 取得失敗時は概算表示のまま（購入自体は _purchase 側で改めて検証される）
    }
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
                    '14日間の無料期間が終わっても、\nプレミアムならすべてのきのうが使い放題！',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
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
            Text(
              trial != null && trial.isTrialActive
                  ? '無料トライアル残り ${trial.trialDaysRemaining} 日'
                  : '無料トライアルは終了しています',
              style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _PlanCard(
              title: '月額プラン',
              price: _monthlyPrice,
              badge: null,
              enabled: !_isProcessing,
              onTap: () => _purchase(monthly: true),
            ),
            const SizedBox(height: 12),
            _PlanCard(
              title: '年額プラン',
              price: _annualPrice,
              badge: 'おトク',
              enabled: !_isProcessing,
              onTap: () => _purchase(monthly: false),
            ),
            if (_isProcessing) ...[
              const SizedBox(height: 16),
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],
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

  Future<void> _purchase({required bool monthly}) async {
    setState(() => _isProcessing = true);
    final result = monthly
        ? await SciencePurchaseService.instance.purchaseMonthly()
        : await SciencePurchaseService.instance.purchaseAnnual();
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

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String? badge;
  final bool enabled;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.badge,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.scienceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sciencePrimary, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.scienceSecondary),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.sciencePrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.sciencePrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.sciencePrimary),
          ],
        ),
      ),
    );
  }
}
