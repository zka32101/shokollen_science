import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import '../../../data/rika_characters.dart';

// ── 理科コレ 交換所アイテム ──────────────────────────────────────────────────
const _rikaExchangeItems = [
  AppShopItem(id: 'hint_3', emoji: '💡', name: 'ヒント 3かい分',
      description: 'まちがえたとき、こたえのヒントが使えます',
      category: '学習サポート', coinCost: 30),
  AppShopItem(id: 'hat_lab', emoji: '🥼', name: '白衣',
      description: 'キャラに白衣を着せる', category: '帽子', coinCost: 80),
  AppShopItem(id: 'hat_microscope', emoji: '🔬', name: '顕微鏡ヘッドバンド',
      description: '顕微鏡を頭に装備！', category: '帽子', coinCost: 100),
  AppShopItem(id: 'hat_astronaut', emoji: '👨‍🚀', name: '宇宙飛行士ヘルメット',
      description: '宇宙をめざせ！', category: '帽子', coinCost: 150),
  AppShopItem(id: 'bg_space', emoji: '🌌', name: '宇宙の背景',
      description: '星と銀河の宇宙空間', category: '背景', coinCost: 200),
  AppShopItem(id: 'bg_forest', emoji: '🌲', name: '森の背景',
      description: '生き物がいっぱいの森', category: '背景', coinCost: 200),
  AppShopItem(id: 'bg_lab', emoji: '🧪', name: '実験室の背景',
      description: 'フラスコやビーカーが並ぶ', category: '背景', coinCost: 200),
  AppShopItem(id: 'bgm_nature', emoji: '🌿', name: '自然音BGM',
      description: '小鳥と川の音で集中', category: 'BGM', coinCost: 150),
  AppShopItem(id: 'bgm_lofi', emoji: '🎵', name: '落ち着くLoFi BGM',
      description: '勉強に集中できるBGM', category: 'BGM', coinCost: 150),
  AppShopItem(id: 'frame_experiment', emoji: '⚗️', name: '実験フレーム',
      description: 'フラスコと試験管のフレーム', category: 'フレーム', coinCost: 200),
  AppShopItem(id: 'frame_nature', emoji: '🍃', name: '自然フレーム',
      description: '葉っぱと花のフレーム', category: 'フレーム', coinCost: 200),
  AppShopItem(id: 'stamp_coupon', emoji: '🎁', name: 'LINEスタンプ無料引換券',
      description: '好きなスタンプ1セットが無料に！',
      category: 'スペシャル', coinCost: 1000),
];

// ── 理科コレ 期間限定アイテム ──────────────────────────────────────────────
const _rikaSeasonalItems = <String, List<AppShopItem>>{
  'spring': [
    AppShopItem(id: 'bg_spring_flowers', emoji: '🌸', name: '春の花畑',
        description: 'タンポポと桜の春の背景', category: '期間限定', coinCost: 300),
    AppShopItem(id: 'hat_butterfly', emoji: '🦋', name: '蝶の羽',
        description: '春らしい蝶の羽を装備', category: '期間限定', coinCost: 150),
    AppShopItem(id: 'frame_spring', emoji: '🌱', name: '新芽フレーム',
        description: '芽吹きの季節を表現', category: '期間限定', coinCost: 200),
  ],
  'summer': [
    AppShopItem(id: 'bg_ocean', emoji: '🌊', name: '海の中の背景',
        description: '海の生き物があふれる深海', category: '期間限定', coinCost: 300),
    AppShopItem(id: 'hat_sunflower', emoji: '🌻', name: 'ひまわりリース',
        description: '夏らしいひまわりの冠', category: '期間限定', coinCost: 120),
    AppShopItem(id: 'frame_fireworks', emoji: '🎆', name: '花火フレーム',
        description: '夏の夜空の花火', category: '期間限定', coinCost: 250),
  ],
  'autumn': [
    AppShopItem(id: 'bg_autumn_leaves', emoji: '🍁', name: '紅葉の背景',
        description: '秋の美しい紅葉', category: '期間限定', coinCost: 300),
    AppShopItem(id: 'hat_mushroom', emoji: '🍄', name: 'キノコ帽子',
        description: '秋の森のキノコ', category: '期間限定', coinCost: 120),
    AppShopItem(id: 'frame_harvest', emoji: '🎃', name: '収穫フレーム',
        description: '実りの秋を表現', category: '期間限定', coinCost: 200),
  ],
  'winter': [
    AppShopItem(id: 'bg_snow', emoji: '❄️', name: '雪の結晶の背景',
        description: '冬の静かな雪景色', category: '期間限定', coinCost: 300),
    AppShopItem(id: 'hat_santa', emoji: '🎅', name: 'サンタ帽子',
        description: 'クリスマスにぴったり', category: '期間限定', coinCost: 150),
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
