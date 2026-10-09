import 'package:shared_core/shared_core.dart' show AppShopItem;

/// 称号の入手方法。コインで買う(purchase)か、進捗で自動解放(achievement)。
enum TitleUnlock { purchase, badges, streak, cleared }

/// 称号の判定に使う進捗の写し(新規計測なし。既存の UserProgress から作る)。
class TitleProgress {
  const TitleProgress({this.badges = 0, this.streakDays = 0, this.cleared = 0});

  final int badges;
  final int streakDays;
  final int cleared;
}

/// ホームのヘッダーに出せる称号。見た目だけで学習には影響しない。
class TitleItem {
  const TitleItem({
    required this.id,
    required this.name,
    required this.description,
    required this.unlock,
    this.coinCost = 0,
    this.threshold = 0,
  });

  final String id;
  final String name;
  final String description;
  final TitleUnlock unlock;

  /// purchase のときの価格。
  final int coinCost;

  /// 達成型のしきい値。
  final int threshold;

  bool get isPurchase => unlock == TitleUnlock.purchase;

  /// 未解放のときに見せる条件の文。
  String get conditionText {
    switch (unlock) {
      case TitleUnlock.purchase:
        return 'ショップで$coinCostコイン';
      case TitleUnlock.badges:
        return 'バッジを$threshold個あつめる';
      case TitleUnlock.streak:
        return '$threshold日れんぞくでがくしゅう';
      case TitleUnlock.cleared:
        return 'ステージを$threshold個クリア';
    }
  }

  AppShopItem toShopItem() => AppShopItem(
        id: id,
        emoji: '🏅',
        name: name,
        description: description,
        category: 'しょうごう',
        coinCost: coinCost,
      );
}

const List<TitleItem> kTitleItems = [
  // ── コインで買う ──
  TitleItem(id: 'title_nazenaze', name: 'なぜなぜはかせ', description: 'ホームにだせるしょうごう', unlock: TitleUnlock.purchase, coinCost: 100),
  TitleItem(id: 'title_jikken', name: 'じっけんたいちょう', description: 'ホームにだせるしょうごう', unlock: TitleUnlock.purchase, coinCost: 200),
  TitleItem(id: 'title_hoshi', name: 'ほしのかんそくか', description: 'ホームにだせるしょうごう', unlock: TitleUnlock.purchase, coinCost: 300),
  TitleItem(id: 'title_fushigi', name: 'ふしぎはっけんか', description: 'ホームにだせるしょうごう', unlock: TitleUnlock.purchase, coinCost: 400),
  TitleItem(id: 'title_daihakase', name: 'りかだいはかせ', description: 'ホームにだせるしょうごう', unlock: TitleUnlock.purchase, coinCost: 500),
  // ── 達成で自動解放 ──
  TitleItem(id: 'title_badge', name: 'バッジコレクター', description: 'バッジをあつめた人のしょうごう', unlock: TitleUnlock.badges, threshold: 5),
  TitleItem(id: 'title_streak', name: 'まいにちけんきゅう', description: 'れんぞくでがくしゅうした人のしょうごう', unlock: TitleUnlock.streak, threshold: 7),
  TitleItem(id: 'title_clear', name: 'ステージめいじん', description: 'ステージをクリアした人のしょうごう', unlock: TitleUnlock.cleared, threshold: 10),
];

TitleItem? titleItemById(String? id) {
  if (id == null) return null;
  for (final t in kTitleItems) {
    if (t.id == id) return t;
  }
  return null;
}

/// 解放済みか。購入型は所持品に入っているか、達成型はしきい値を超えているか。
bool isTitleUnlocked(TitleItem t, {required Set<String> owned, required TitleProgress progress}) {
  switch (t.unlock) {
    case TitleUnlock.purchase:
      return owned.contains(t.id);
    case TitleUnlock.badges:
      return progress.badges >= t.threshold;
    case TitleUnlock.streak:
      return progress.streakDays >= t.threshold;
    case TitleUnlock.cleared:
      return progress.cleared >= t.threshold;
  }
}

/// 交換所に並べる購入型の称号。
List<AppShopItem> titleExchangeItems() => [for (final t in kTitleItems) if (t.isPurchase) t.toShopItem()];
