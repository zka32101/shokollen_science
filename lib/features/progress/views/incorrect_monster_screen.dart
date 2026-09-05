import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incorrect_monster.dart';
import '../providers/incorrect_monster_provider.dart';
import 'monster_detail_screen.dart';
import 'widgets/monster_dialogs.dart';
import 'widgets/monster_image.dart';

/// まちがい図鑑スクリーン
/// 間違えた問題をモンスター化した図鑑を表示
class IncorrectMonsterScreen extends ConsumerWidget {
  const IncorrectMonsterScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monsters = ref.watch(incorrectMonstersProvider);
    final monsterCount = ref.watch(monsterCountProvider);

    if (monsters.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('まちがい図鑑'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_very_satisfied,
                size: 64,
                color: Colors.grey[300],
              ),
              SizedBox(height: 16),
              Text(
                'まちがい図鑑はからです！',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'クイズで間違えたらモンスターが登場するよ',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('まちがい図鑑（$monsterCount体）'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ヘッダー: 進化段階別の統計
          _EvolutionStatistics(),
          SizedBox(height: 16),
          // グリッド表示
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: monsters.length,
              itemBuilder: (context, index) {
                final monster = monsters[index];
                return _MonsterCard(
                  monster: monster,
                  onTap: () => _showMonsterDetail(context, monster),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showMonsterDetail(BuildContext context, IncorrectMonster monster) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonsterDetailScreen(monsterId: monster.id),
      ),
    );
  }
}

/// 進化段階別の統計を表示するウィジェット
class _EvolutionStatistics extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byEvolution = ref.watch(monstersByEvolutionProvider);

    return Container(
      color: Colors.blue[50],
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final state in EvolutionState.values)
            _StatItem(
              emoji: state.emoji,
              label: state.label,
              count: byEvolution[state] ?? 0,
            ),
        ],
      ),
    );
  }
}

/// 統計アイテム
class _StatItem extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;

  const _StatItem({
    required this.emoji,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: TextStyle(fontSize: 24)),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '$count体',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// モンスターカード
class _MonsterCard extends StatelessWidget {
  final IncorrectMonster monster;
  final VoidCallback onTap;

  const _MonsterCard({
    required this.monster,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: _getGradientColors(monster.evolutionState),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // モンスター画像
              MonsterImage(monster: monster, size: 56),
              SizedBox(height: 8),

              // モンスター名
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  monster.monsterName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 4),

              // 段階ラベル
              Text(
                monster.evolutionState.label,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 6),

              // 進化ゲージ
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: monster.correctionsCount / 3.0,
                    minHeight: 3,
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(EvolutionState state) {
    return switch (state) {
      EvolutionState.baby => [Colors.blue[300]!, Colors.blue[600]!],
      EvolutionState.juvenile => [Colors.purple[300]!, Colors.purple[600]!],
      EvolutionState.adult => [Colors.green[300]!, Colors.green[600]!],
      EvolutionState.sage => [Colors.amber[300]!, Colors.amber[600]!],
    };
  }
}
