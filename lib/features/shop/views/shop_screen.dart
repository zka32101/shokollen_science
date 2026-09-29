import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import '../../../data/rika_characters.dart';

// ── 理科コレ 交換所アイテム ──────────────────────────────────────────────────
const _rikaExchangeItems = [
  // 2026-09: 帽子・BGMカテゴリは装着・再生の仕組みが未実装で
  // 買っても何も起きなかったため削除。背景は selectedBackgroundProvider で
  // 実際にホーム画面に反映されるようになったので残す。
  // 2026-09: 学習サポート（ヒント）は使い道が実装されていないため削除。
  AppShopItem(id: 'bg_space', emoji: '🌌', name: '宇宙の背景',
      description: '星と銀河の宇宙空間', category: '背景', coinCost: 200),
  AppShopItem(id: 'bg_forest', emoji: '🌲', name: '森の背景',
      description: '生き物がいっぱいの森', category: '背景', coinCost: 200),
  AppShopItem(id: 'bg_lab', emoji: '🧪', name: '実験室の背景',
      description: 'フラスコやビーカーが並ぶ', category: '背景', coinCost: 200),
  AppShopItem(id: 'frame_experiment', emoji: '⚗️', name: '実験フレーム',
      description: 'フラスコと試験管のフレーム', category: 'フレーム', coinCost: 200),
  AppShopItem(id: 'frame_nature', emoji: '🍃', name: '自然フレーム',
      description: '葉っぱと花のフレーム', category: 'フレーム', coinCost: 200),
  // 2026-09: LINEスタンプ引換券は運用フローが用意できていないため削除。
  // ── アバターアイコン（最初の4体は無料、残り12体はここで購入） ──────
  // ProfileModel.avatarChoices / avatarShopItemIds と対応
  AppShopItem(id: 'avatar_usagi', emoji: '🐰', name: 'ウサギアバター',
      description: 'プロフィールのアバターに使える', category: 'アバター', coinCost: 50,
      kind: ShopItemKind.avatar,
      assetPath: 'packages/shared_core/lib/assets/avatars/avatar_usagi.jpg'),
  AppShopItem(id: 'avatar_tora', emoji: '🐯', name: 'トラアバター',
      description: 'プロフィールのアバターに使える', category: 'アバター', coinCost: 50,
      kind: ShopItemKind.avatar,
      assetPath: 'packages/shared_core/lib/assets/avatars/avatar_tora.jpg'),
  AppShopItem(id: 'avatar_raion', emoji: '🦁', name: 'ライオンアバター',
      description: 'プロフィールのアバターに使える', category: 'アバター', coinCost: 50,
      kind: ShopItemKind.avatar,
      assetPath: 'packages/shared_core/lib/assets/avatars/avatar_raion.jpg'),
  AppShopItem(id: 'avatar_kaeru', emoji: '🐸', name: 'カエルアバター',
      description: 'プロフィールのアバターに使える', category: 'アバター', coinCost: 50,
      kind: ShopItemKind.avatar,
      assetPath: 'packages/shared_core/lib/assets/avatars/avatar_kaeru.jpg'),
  AppShopItem(id: 'avatar_ahiru', emoji: '🦆', name: 'アヒルアバター',
      description: 'プロフィールのアバターに使える', category: 'アバター', coinCost: 60,
      kind: ShopItemKind.avatar,
      assetPath: 'packages/shared_core/lib/assets/avatars/avatar_ahiru.jpg'),
  AppShopItem(id: 'avatar_buta', emoji: '🐷', name: 'ブタアバター',
      description: 'プロフィールのアバターに使える', category: 'アバター', coinCost: 60,
      kind: ShopItemKind.avatar,
      assetPath: 'packages/shared_core/lib/assets/avatars/avatar_buta.jpg'),
  AppShopItem(id: 'avatar_koala', emoji: '🐨', name: 'コアラアバター',
      description: 'プロフィールのアバターに使える', category: 'アバター', coinCost: 60,
      kind: ShopItemKind.avatar,
      assetPath: 'packages/shared_core/lib/assets/avatars/avatar_koala.jpg'),
  AppShopItem(id: 'avatar_kirin', emoji: '🦒', name: 'キリンアバター',
      description: 'プロフィールのアバターに使える', category: 'アバター', coinCost: 60,
      kind: ShopItemKind.avatar,
      assetPath: 'packages/shared_core/lib/assets/avatars/avatar_kirin.jpg'),
  AppShopItem(id: 'avatar_kangaroo', emoji: '🦘', name: 'カンガルーアバター',
      description: 'プロフィールのアバターに使える', category: 'アバター', coinCost: 70,
      kind: ShopItemKind.avatar,
      assetPath: 'packages/shared_core/lib/assets/avatars/avatar_kangaroo.jpg'),
  AppShopItem(id: 'avatar_inu', emoji: '🐶', name: 'イヌアバター',
      description: 'プロフィールのアバターに使える', category: 'アバター', coinCost: 70,
      kind: ShopItemKind.avatar,
      assetPath: 'packages/shared_core/lib/assets/avatars/avatar_inu.jpg'),
  AppShopItem(id: 'avatar_araiguma', emoji: '🦝', name: 'アライグマアバター',
      description: 'プロフィールのアバターに使える', category: 'アバター', coinCost: 70,
      kind: ShopItemKind.avatar,
      assetPath: 'packages/shared_core/lib/assets/avatars/avatar_arai_guma.jpg'),
  AppShopItem(id: 'avatar_namakemono', emoji: '🦥', name: 'ナマケモノアバター',
      description: 'プロフィールのアバターに使える', category: 'アバター', coinCost: 70,
      kind: ShopItemKind.avatar,
      assetPath: 'packages/shared_core/lib/assets/avatars/avatar_namakemono.jpg'),
];

// ── 理科コレ 期間限定アイテム ──────────────────────────────────────────────
const _rikaSeasonalItems = <String, List<AppShopItem>>{
  'spring': [
    AppShopItem(id: 'bg_spring_flowers', emoji: '🌸', name: '春の花畑',
        description: 'タンポポと桜の春の背景', category: '期間限定', coinCost: 300),
    AppShopItem(id: 'frame_spring', emoji: '🌱', name: '新芽フレーム',
        description: '芽吹きの季節を表現', category: '期間限定', coinCost: 200),
  ],
  'summer': [
    AppShopItem(id: 'bg_ocean', emoji: '🌊', name: '海の中の背景',
        description: '海の生き物があふれる深海', category: '期間限定', coinCost: 300),
    AppShopItem(id: 'frame_fireworks', emoji: '🎆', name: '花火フレーム',
        description: '夏の夜空の花火', category: '期間限定', coinCost: 250),
  ],
  'autumn': [
    AppShopItem(id: 'bg_autumn_leaves', emoji: '🍁', name: '紅葉の背景',
        description: '秋の美しい紅葉', category: '期間限定', coinCost: 300),
    AppShopItem(id: 'frame_harvest', emoji: '🎃', name: '収穫フレーム',
        description: '実りの秋を表現', category: '期間限定', coinCost: 200),
  ],
  'winter': [
    AppShopItem(id: 'bg_snow', emoji: '❄️', name: '雪の結晶の背景',
        description: '冬の静かな雪景色', category: '期間限定', coinCost: 300),
    AppShopItem(id: 'frame_winter', emoji: '☃️', name: '雪だるまフレーム',
        description: '冬の温かいフレーム', category: '期間限定', coinCost: 200),
  ],
};

/// 理科コレ コインショップ。
/// 表示ロジックはすべて [CoinShopPage] に委譲する。
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CoinShopPage(
      characters: kRikaCharacters,
      exchangeItems: _rikaExchangeItems,
      seasonalItems: _rikaSeasonalItems,
    );
  }
}
