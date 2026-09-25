import 'package:purchases_flutter/purchases_flutter.dart';

/// 小学コレ！理科用 RevenueCat サービス（月額¥300 固定）。
///
/// ダッシュボードに商品/オファリングが未登録の場合は
/// 例外を投げず null / false を返し、呼び出し側でフォールバック表示する。
class SciencePurchaseService {
  SciencePurchaseService._();
  static final SciencePurchaseService instance = SciencePurchaseService._();

  static const String _googleKey = 'goog_MkXRvFoWQEuQHtjhIHDCzczDbQL';
  static const String premiumEntitlementId = '小学コレ理科_pro';

  bool _configured = false;
  bool get isConfigured => _configured;

  Future<void> initialize() async {
    if (_configured || _googleKey.isEmpty) return;
    try {
      await Purchases.configure(PurchasesConfiguration(_googleKey));
      _configured = true;
    } catch (e) {
      // 初期化失敗時は未設定として扱う（アプリはクラッシュさせない）
      // ただし原因はログに残す（読み込みエラーの原因調査用）。
      // ignore: avoid_print
      print('[RevenueCat] initialize 失敗: $e');
      _configured = false;
    }
  }

  /// プレミアム有効なら期限日（無期限なら遠い未来）、無効なら null。
  Future<DateTime?> premiumExpiry() async {
    if (!_configured) return null;
    try {
      return _expiryOf(await Purchases.getCustomerInfo());
    } catch (_) {
      return null;
    }
  }

  /// 購入を実行する。
  ///
  /// 戻り値:
  /// - [PurchaseOutcome.success] + 有効期限: 購入成功
  /// - [PurchaseOutcome.cancelled]: ユーザーがキャンセル
  /// - [PurchaseOutcome.notConfigured]: RevenueCat 未設定（APIキー未設定）
  /// - [PurchaseOutcome.noOfferings]: ダッシュボードに商品未登録
  /// - [PurchaseOutcome.error]: その他のエラー
  Future<PurchaseResult> purchaseMonthly() async {
    if (!_configured) {
      return const PurchaseResult(outcome: PurchaseOutcome.notConfigured);
    }
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      final package = current?.monthly;
      if (package == null) {
        return const PurchaseResult(outcome: PurchaseOutcome.noOfferings);
      }
      final result = await Purchases.purchasePackage(package);
      return PurchaseResult(
        outcome: PurchaseOutcome.success,
        expiry: _expiryOf(result.customerInfo),
      );
    } on PurchasesErrorCode catch (e) {
      // ignore: avoid_print
      print('[RevenueCat] purchaseMonthly 失敗: $e');
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return const PurchaseResult(outcome: PurchaseOutcome.cancelled);
      }
      return const PurchaseResult(outcome: PurchaseOutcome.error);
    } catch (e) {
      // ignore: avoid_print
      print('[RevenueCat] purchaseMonthly 失敗: $e');
      // purchase_cancelled 判定（PlatformException経由で来る場合の保険）
      final message = e.toString();
      if (message.contains('PurchaseCancelledError') ||
          message.contains('cancelled')) {
        return const PurchaseResult(outcome: PurchaseOutcome.cancelled);
      }
      return const PurchaseResult(outcome: PurchaseOutcome.error);
    }
  }

  Future<PurchaseResult> restore() async {
    if (!_configured) {
      return const PurchaseResult(outcome: PurchaseOutcome.notConfigured);
    }
    try {
      final info = await Purchases.restorePurchases();
      final expiry = _expiryOf(info);
      return PurchaseResult(
        outcome: expiry != null
            ? PurchaseOutcome.success
            : PurchaseOutcome.noOfferings,
        expiry: expiry,
      );
    } catch (_) {
      return const PurchaseResult(outcome: PurchaseOutcome.error);
    }
  }

  DateTime? _expiryOf(CustomerInfo info) {
    final entitlement = info.entitlements.active[premiumEntitlementId];
    if (entitlement == null) return null;
    final expiration = entitlement.expirationDate;
    return (expiration != null ? DateTime.tryParse(expiration) : null) ??
        DateTime(2100);
  }
}

enum PurchaseOutcome { success, cancelled, notConfigured, noOfferings, error }

class PurchaseResult {
  final PurchaseOutcome outcome;
  final DateTime? expiry;
  const PurchaseResult({required this.outcome, this.expiry});
}
