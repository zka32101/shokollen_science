import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart'
    hide progressProvider, LearningProgress, ProgressNotifier;
import '../../../data/rika_characters.dart';
import '../../../shared/constants/app_colors.dart';

/// キャラクター画像ギャラリー。
///
/// レベルアップ（新キャラ解放）のたびに、これまで集めたキャラクターの
/// イラストをまとめて見返せる画面。現状は1キャラにつき画像は1枚だが、
/// 今後レベル別の追加イラストが増えても、この画面にリストを足すだけで
/// 対応できるようにしてある。
class CharacterGalleryScreen extends StatelessWidget {
  final int totalStagesCleared;
  const CharacterGalleryScreen({super.key, required this.totalStagesCleared});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('キャラクターギャラリー'),
        backgroundColor: AppColors.sciencePrimary,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: kRikaCharacters.length,
        itemBuilder: (context, i) {
          final character = kRikaCharacters[i];
          final unlocked = totalStagesCleared >= character.unlockAt;
          return _CharacterCard(character: character, unlocked: unlocked);
        },
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final BaseCharacter character;
  final bool unlocked;
  const _CharacterCard({required this.character, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: unlocked
                  ? Image.asset(character.imageAsset, fit: BoxFit.cover)
                  : ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                          Colors.grey, BlendMode.saturation),
                      child: Opacity(
                        opacity: 0.5,
                        child: Image.asset(character.imageAsset,
                            fit: BoxFit.cover),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              unlocked ? character.name : '？？？',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
