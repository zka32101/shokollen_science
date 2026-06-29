import 'package:flutter/material.dart';

class SeasonalRecommendationWidget extends StatelessWidget {
  final Function(String stageId) onTap;

  const SeasonalRecommendationWidget({
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final month = DateTime.now().month;
    final rec = _getRecommendation(month);
    final colors = _getColors(month);

    return GestureDetector(
      onTap: () => onTap(rec.stageId),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(rec.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今月のおすすめ 🌟',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rec.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    rec.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'GO →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _SeasonalRec _getRecommendation(int month) {
    switch (month) {
      case 1:
        return _SeasonalRec(
          emoji: '⛄',
          title: '新年！実験チャレンジ',
          description: '得意な分野から理科の達人を目指そう',
          stageId: 'stage_3_001',
        );
      case 2:
        return _SeasonalRec(
          emoji: '🌱',
          title: '春の準備：植物を学ぼう',
          description: 'タネが芽を出す季節。植物ステージに挑戦！',
          stageId: 'stage_3_002',
        );
      case 3:
        return _SeasonalRec(
          emoji: '🌸',
          title: '春！花が咲く季節',
          description: '植物ステージで、春の花の秘密を探ろう',
          stageId: 'stage_3_002',
        );
      case 4:
        return _SeasonalRec(
          emoji: '🐛',
          title: 'GW自然観察',
          description: 'おでかけで昆虫や植物を観察しよう',
          stageId: 'stage_3_001',
        );
      case 5:
        return _SeasonalRec(
          emoji: '☔',
          title: '梅雨がやってくる',
          description: '天気ステージで雲のでき方を学ぼう',
          stageId: 'stage_3_008',
        );
      case 6:
        return _SeasonalRec(
          emoji: '🌧️',
          title: '雨と天気の実験',
          description: '梅雨の時期に天気の仕組みを理解しよう',
          stageId: 'stage_3_008',
        );
      case 7:
        return _SeasonalRec(
          emoji: '☀️',
          title: '夏休み！実験チャレンジ',
          description: '時間のある夏に色んな実験をやってみよう',
          stageId: 'stage_3_004',
        );
      case 8:
        return _SeasonalRec(
          emoji: '🌠',
          title: 'ペルセウス座流星群',
          description: '今夜の空を見てみて。天体ステージがおすすめ！',
          stageId: 'stage_4_007',
        );
      case 9:
        return _SeasonalRec(
          emoji: '🔭',
          title: '秋の夜長に天体観測',
          description: 'きれいな星が見える季節。天体で学ぼう',
          stageId: 'stage_4_007',
        );
      case 10:
        return _SeasonalRec(
          emoji: '🍂',
          title: '秋の生き物観察',
          description: '秋の動植物のしくみを学ぼう',
          stageId: 'stage_4_001',
        );
      case 11:
        return _SeasonalRec(
          emoji: '🍁',
          title: '紅葉と色の変化',
          description: 'なぜ葉は赤くなる？植物の秘密を探ろう',
          stageId: 'stage_3_002',
        );
      case 12:
        return _SeasonalRec(
          emoji: '❄️',
          title: '冬の光と温度の実験',
          description: '寒い冬に水・氷・温度の変化を調べよう',
          stageId: 'stage_4_003',
        );
      default:
        return _SeasonalRec(
          emoji: '🔬',
          title: '新しい実験に挑戦！',
          description: 'きょうも理科の達人を目指して頑張ろう',
          stageId: 'stage_3_001',
        );
    }
  }

  List<Color> _getColors(int month) {
    if (month <= 2 || month == 12) {
      return [const Color(0xFF1565C0), const Color(0xFF00BCD4)]; // 冬
    } else if (month <= 5) {
      return [const Color(0xFFE91E63), const Color(0xFF4CAF50)]; // 春
    } else if (month <= 8) {
      return [const Color(0xFFFF6F00), const Color(0xFFE53935)]; // 夏
    } else {
      return [const Color(0xFFEF6C00), const Color(0xFFF9A825)]; // 秋
    }
  }
}

class _SeasonalRec {
  final String emoji;
  final String title;
  final String description;
  final String stageId;

  _SeasonalRec({
    required this.emoji,
    required this.title,
    required this.description,
    required this.stageId,
  });
}
