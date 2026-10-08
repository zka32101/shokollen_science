import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import '../../../data/rika_characters.dart';
import '../decor/decor_items.dart';
import '../decor/decor_screen.dart';

// ── 理科コレ 交換所アイテム ──────────────────────────────────────────────────
final _rikaExchangeItems = <AppShopItem>[
  // 2026-09: 帽子・BGMカテゴリは装着・再生の仕組みが未実装で
  // 買っても何も起きなかったため削除。
  // 2026-09: 学習サポート（ヒント）は使い道が実装されていないため削除。
  // 2026-09: LINEスタンプ引換券は運用フローが用意できていないため削除。
  // 2026-09: 背景・フレームも社会コレ等と方針を揃えて削除。
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
  ...decorExchangeItems(),
];

// ── 理科コレ 期間限定アイテム ──────────────────────────────────────────────
// 2026-09: 背景・フレームの販売を廃止したため季節限定アイテムも無効化。

/// 理科コレ コインショップ。
/// 表示ロジックはすべて [CoinShopPage] に委譲する。
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CoinShopPage(
          characters: kRikaCharacters,
          exchangeItems: _rikaExchangeItems,
          seasonalItems: decorSeasonalItems(),
        ),
        // 買った背景・フレーム・エフェクトをえらんでつける画面へ
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'decor_fab',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DecorScreen())),
            icon: const Icon(Icons.palette_outlined),
            label: const Text('きせかえ'),
          ),
        ),
      ],
    );
  }
}
