import 'package:flutter/material.dart';
import '../../models/incorrect_monster.dart';

/// モンスター画像表示ウィジェット
/// AI生成画像（assets/images/monsters/）を表示し、未生成の場合は
/// EvolutionState の絵文字にフォールバックする
class MonsterImage extends StatelessWidget {
  final IncorrectMonster monster;
  final double size;

  /// Before/After 比較表示など、monster の実際の進化段階とは
  /// 別の段階を表示したいときに指定する
  final EvolutionState? evolutionStateOverride;

  const MonsterImage({
    super.key,
    required this.monster,
    this.size = 80,
    this.evolutionStateOverride,
  });

  @override
  Widget build(BuildContext context) {
    final state = evolutionStateOverride ?? monster.evolutionState;
    final assetPath =
        'assets/images/monsters/grade${monster.grade}_${state.name}.png';

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Text(
          state.emoji,
          style: TextStyle(fontSize: size * 0.6),
        ),
      ),
    );
  }
}
