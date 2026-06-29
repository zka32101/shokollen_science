import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

// shared_core の BadgeModel・BadgeCategory・EarnedBadge を再エクスポート
export 'package:shared_core/shared_core.dart'
    show BadgeModel, BadgeCategory, EarnedBadge;

/// 後方互換エクステンション
/// badge.name, badge.color を使っている既存コードを無変更で動かす
extension BadgeScienceExt on BadgeModel {
  /// title の別名（既存コードの badge.name 参照を維持）
  String get name => title;

  /// カテゴリから理科アプリ専用カラーを導出
  Color get color => switch (category) {
        BadgeCategory.streak   => const Color(0xFFFF5722),
        BadgeCategory.score    => const Color(0xFFFFD700),
        BadgeCategory.content1 => const Color(0xFF4CAF50),
        BadgeCategory.content2 => const Color(0xFF2196F3),
        BadgeCategory.special  => const Color(0xFF9C27B0),
        _                      => const Color(0xFF9E9E9E),
      };
}

/// 全バッジ定義（22種類）
const List<BadgeModel> allBadges = [
  // ── ストリーク ──────────────────────────────────────────────
  BadgeModel(
    id: 'streak_3',
    title: '3日連続！',
    description: '3日間連続で学習した',
    emoji: '🔥',
    category: BadgeCategory.streak,
    requiredCount: 3,
  ),
  BadgeModel(
    id: 'streak_7',
    title: '1週間チャレンジ',
    description: '7日間連続で学習した',
    emoji: '💎',
    category: BadgeCategory.streak,
    requiredCount: 7,
  ),
  BadgeModel(
    id: 'streak_14',
    title: '2週間マスター',
    description: '14日間連続で学習した',
    emoji: '🌟',
    category: BadgeCategory.streak,
    requiredCount: 14,
  ),
  BadgeModel(
    id: 'streak_30',
    title: '30日の探究者',
    description: '30日間連続で学習した',
    emoji: '👑',
    category: BadgeCategory.streak,
    requiredCount: 30,
  ),

  // ── 満点 ────────────────────────────────────────────────────
  BadgeModel(
    id: 'perfect_score',
    title: '満点マスター',
    description: '全問正解を達成した',
    emoji: '🏆',
    category: BadgeCategory.score,
    requiredCount: 1,
  ),

  // ── ポイント ─────────────────────────────────────────────────
  BadgeModel(
    id: 'points_100',
    title: '100ポイント達成',
    description: '合計100ポイントを獲得した',
    emoji: '💯',
    category: BadgeCategory.score,
    requiredCount: 100,
  ),
  BadgeModel(
    id: 'points_500',
    title: '500ポイント達成',
    description: '合計500ポイントを獲得した',
    emoji: '🎯',
    category: BadgeCategory.score,
    requiredCount: 500,
  ),
  BadgeModel(
    id: 'points_1000',
    title: '1000ポイント突破',
    description: '合計1000ポイントを獲得した',
    emoji: '⚡',
    category: BadgeCategory.score,
    requiredCount: 1000,
  ),

  // ── ステージ数マイルストーン ────────────────────────────────
  BadgeModel(
    id: 'first_quiz',
    title: 'はじめの一歩',
    description: 'はじめてクイズをクリアした',
    emoji: '🌱',
    category: BadgeCategory.special,
    requiredCount: 1,
  ),
  BadgeModel(
    id: 'five_stages',
    title: '5ステージ突破',
    description: '5つのステージを満点クリアした',
    emoji: '⭐',
    category: BadgeCategory.special,
    requiredCount: 5,
  ),
  BadgeModel(
    id: 'ten_stages',
    title: '10ステージ突破',
    description: '10のステージを満点クリアした',
    emoji: '🎖️',
    category: BadgeCategory.special,
    requiredCount: 10,
  ),
  BadgeModel(
    id: 'stage_20',
    title: '20ステージ突破',
    description: '20のステージを満点クリアした',
    emoji: '🚀',
    category: BadgeCategory.special,
    requiredCount: 20,
  ),
  BadgeModel(
    id: 'stage_30',
    title: '30ステージ突破',
    description: '30のステージを満点クリアした',
    emoji: '🌈',
    category: BadgeCategory.special,
    requiredCount: 30,
  ),
  BadgeModel(
    id: 'stage_40',
    title: '40ステージ突破',
    description: '40のステージを満点クリアした',
    emoji: '💫',
    category: BadgeCategory.special,
    requiredCount: 40,
  ),
  BadgeModel(
    id: 'stage_45',
    title: '45ステージ突破',
    description: '45のステージを満点クリアした',
    emoji: '🌠',
    category: BadgeCategory.special,
    requiredCount: 45,
  ),
  BadgeModel(
    id: 'stage_47',
    title: '理科マスター前夜',
    description: '47のステージをすべて満点クリアした',
    emoji: '✨',
    category: BadgeCategory.special,
    requiredCount: 47,
  ),

  // ── 学年コンプリート ────────────────────────────────────────
  BadgeModel(
    id: 'grade3_complete',
    title: '3年生コンプリート',
    description: '3年生の全12単元を満点クリアした',
    emoji: '🔭',
    category: BadgeCategory.content2,
    requiredCount: 12,
  ),
  BadgeModel(
    id: 'grade4_complete',
    title: '4年生コンプリート',
    description: '4年生の全11単元を満点クリアした',
    emoji: '🌡️',
    category: BadgeCategory.content2,
    requiredCount: 11,
  ),
  BadgeModel(
    id: 'grade5_complete',
    title: '5年生コンプリート',
    description: '5年生の全12単元を満点クリアした',
    emoji: '⚗️',
    category: BadgeCategory.content2,
    requiredCount: 12,
  ),
  BadgeModel(
    id: 'grade6_complete',
    title: '6年生コンプリート',
    description: '6年生の全12単元を満点クリアした',
    emoji: '🧬',
    category: BadgeCategory.content2,
    requiredCount: 12,
  ),

  // ── 理科マスター（全ステージ制覇） ─────────────────────────
  BadgeModel(
    id: 'science_master',
    title: '理科マスター',
    description: 'すべての47ステージを満点クリアした',
    emoji: '🔬',
    category: BadgeCategory.special,
    requiredCount: 47,
  ),
];
