import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int kTrialDays = 14;

class TrialState {
  final DateTime installDate;
  final int trialDaysRemaining;
  final bool isPremium;

  const TrialState({
    required this.installDate,
    required this.trialDaysRemaining,
    required this.isPremium,
  });

  /// コンテンツにアクセス可能か（トライアル中 or プレミアム）
  bool get hasAccess => isPremium || trialDaysRemaining > 0;

  /// トライアル期間中か
  bool get isTrialActive => trialDaysRemaining > 0;

  /// トライアル終了・未プレミアム
  bool get isExpired => !isPremium && trialDaysRemaining <= 0;
}

class TrialNotifier extends AsyncNotifier<TrialState> {
  static const _installKey = 'install_timestamp_v1';
  static const _premiumKey = 'is_premium_v1';

  @override
  Future<TrialState> build() async {
    final prefs = await SharedPreferences.getInstance();

    // インストール日を記録（初回のみ）
    var ts = prefs.getInt(_installKey);
    if (ts == null) {
      ts = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_installKey, ts);
    }

    final installDate = DateTime.fromMillisecondsSinceEpoch(ts);
    final daysSince = DateTime.now().difference(installDate).inDays;
    final remaining = (kTrialDays - daysSince).clamp(0, kTrialDays);
    final isPremium = prefs.getBool(_premiumKey) ?? false;

    return TrialState(
      installDate: installDate,
      trialDaysRemaining: remaining,
      isPremium: isPremium,
    );
  }

  /// プレミアムを有効化（RevenueCat 購入後に呼ぶ）
  Future<void> activatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
    ref.invalidateSelf();
  }

  /// デバッグ用：トライアルをリセット
  Future<void> debugResetTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_installKey);
    await prefs.remove(_premiumKey);
    ref.invalidateSelf();
  }
}

final trialProvider =
    AsyncNotifierProvider<TrialNotifier, TrialState>(TrialNotifier.new);
