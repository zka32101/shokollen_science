import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// shared_core の progressProvider と名前衝突しないよう hide
import 'package:shared_core/shared_core.dart'
    hide progressProvider, LearningProgress, ProgressNotifier;
import '../../../data/rika_characters.dart';
import '../../progress/providers/user_progress_provider.dart';

/// 理科コレ キャラクター図鑑。
/// 表示ロジックは shared_core の [CharacterCollectionPage] に委譲。
class CharacterScreen extends ConsumerWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final clearedCount = progress.value?.clearedCount ?? 0;
    return CharacterCollectionPage(
      characters: kRikaCharacters,
      totalStagesCleared: clearedCount,
    );
  }
}
