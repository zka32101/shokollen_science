import 'package:flutter/material.dart';
import 'package:shokollen_science/widgets/ukalab_emoji.dart';

/// 実績バッジの共通意匠（assets/badges/badge_<意匠>.webp）。画像が無いバッジは従来の絵文字で出す。
///
/// 意匠への対応は design/小学コレ！/共通/実績バッジ_意匠対応表_2026-10-07.md（理科）。
class BadgeEmblem extends StatelessWidget {
  const BadgeEmblem({super.key, required this.badgeId, required this.fallbackEmoji, this.size = 32});

  final String badgeId;
  final String fallbackEmoji;
  final double size;

  static const Map<String, String> _emblemOf = {
  'streak_3': 'streak',
  'streak_7': 'streak',
  'streak_14': 'streak',
  'streak_30': 'streak',
  'perfect_score': 'perfect',
  'points_100': 'check',
  'points_500': 'check',
  'points_1000': 'check',
  'first_quiz': 'first_step',
  'five_stages': 'challenge',
  'ten_stages': 'challenge',
  'stage_20': 'challenge',
  'stage_30': 'challenge',
  'stage_40': 'challenge',
  'stage_45': 'challenge',
  'stage_47': 'gradcap',
  'grade3_complete': 'gradcap',
  'grade4_complete': 'gradcap',
  'grade5_complete': 'gradcap',
  'grade6_complete': 'gradcap',
  'experiment_first': 'idea',
  'experiment_5': 'idea',
  'experiment_10': 'idea',
  'science_master': 'gem',
  };

  /// バッジIDに対応する意匠名。なければ null。
  static String? emblemOf(String badgeId) => _emblemOf[badgeId];

  @override
  Widget build(BuildContext context) {
    final name = _emblemOf[badgeId];
    if (name == null) return UkalabEmoji(fallbackEmoji, size: size);
    return Image.asset(
      'assets/badges/badge_$name.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) => UkalabEmoji(fallbackEmoji, size: size),
    );
  }
}
