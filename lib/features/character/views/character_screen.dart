import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// shared_core の progressProvider と名前衝突しないよう hide
import 'package:shared_core/shared_core.dart'
    hide progressProvider, LearningProgress, ProgressNotifier;
import '../../../data/rika_characters.dart';
import '../../../shared/constants/app_colors.dart';
import '../../progress/providers/user_progress_provider.dart';
import '../character_level_assets.dart';
import '../providers/character_level_assets_provider.dart';
import '../widgets/sparkle_overlay.dart';
import 'character_gallery_screen.dart';
import 'package:shokollen_science/features/shop/decor/decor_scope.dart';

/// 理科コレ キャラクター図鑑（レベルアップ対応）。
/// レベル(1〜5, 5=MAX)の保存・コイン消費は shared_core の
/// [characterStateProvider].levelUp に委譲する。
class CharacterScreen extends ConsumerStatefulWidget {
  const CharacterScreen({super.key});

  @override
  ConsumerState<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends ConsumerState<CharacterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(coinProvider.notifier).load();
      final cleared = ref.read(userProgressProvider).value?.clearedCount ?? 0;
      await ref.read(characterStateProvider.notifier).checkUnlocks(cleared);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider);
    final clearedCount = progress.value?.clearedCount ?? 0;
    final states = ref.watch(characterStateProvider);
    final coins = ref.watch(coinProvider).totalCoins;
    final assets = ref.watch(characterLevelAssetsProvider).value ??
        CharacterLevelAssets.empty;

    return Scaffold(
      backgroundColor: DecorScope.pageBg(context, const Color(0xFFF7F9FC)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 6),
                Text('$coins コイン',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        CharacterGalleryScreen(totalStagesCleared: clearedCount),
                  )),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('ギャラリー'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemCount: kRikaCharacters.length,
              itemBuilder: (context, i) {
                final c = kRikaCharacters[i];
                final st = states[c.id] ?? const CharacterState();
                final unlocked = st.isUnlocked || clearedCount >= c.unlockAt;
                return _CharacterTile(
                  character: c,
                  state: st,
                  unlocked: unlocked,
                  clearedCount: clearedCount,
                  assets: assets,
                  onTap: unlocked
                      ? () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20))),
                            builder: (_) =>
                                CharacterDetailSheet(characterId: c.id),
                          )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 表示用メイン画像: MAXでMAX画像があればそれ、無ければベース画像。
String mainImageFor(
    BaseCharacter c, CharacterState st, CharacterLevelAssets a) {
  if (st.isMaxLevel) {
    final m = a.maxImage(c.id);
    if (m != null) return m;
  }
  return c.imageAsset!;
}

class _CharacterTile extends StatelessWidget {
  final BaseCharacter character;
  final CharacterState state;
  final bool unlocked;
  final int clearedCount;
  final CharacterLevelAssets assets;
  final VoidCallback? onTap;
  const _CharacterTile({
    required this.character,
    required this.state,
    required this.unlocked,
    required this.clearedCount,
    required this.assets,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(mainImageFor(character, state, assets),
        fit: BoxFit.cover);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: unlocked && state.isMaxLevel
              ? Border.all(color: Colors.amber, width: 2)
              : null,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    unlocked
                        ? img
                        : ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                                Colors.grey, BlendMode.saturation),
                            child: Opacity(opacity: 0.4, child: img)),
                    if (unlocked && state.isMaxLevel) const SparkleOverlay(),
                    if (!unlocked)
                      Center(
                        child: Text(
                            'あと${character.unlockAt - clearedCount}ステージ',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54)),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(unlocked ? character.name : '？？？',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark)),
                  ),
                  if (unlocked) ...[
                    const SizedBox(width: 6),
                    Text(state.levelLabel,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: state.isMaxLevel
                                ? Colors.amber.shade800
                                : AppColors.sciencePrimary)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// キャラ詳細（レベル表示・表情/ポーズ・ストーリー・レベルアップ）。
class CharacterDetailSheet extends ConsumerWidget {
  final String characterId;
  const CharacterDetailSheet({super.key, required this.characterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = kRikaCharacters.firstWhere((e) => e.id == characterId);
    final st = ref.watch(characterStateProvider)[c.id] ??
        const CharacterState(isUnlocked: true);
    final assets = ref.watch(characterLevelAssetsProvider).value ??
        CharacterLevelAssets.empty;
    final coins = ref.watch(coinProvider).totalCoins;
    final expressions = st.level >= 2 ? assets.expressions(c.id) : <String>[];
    final poses = st.level >= 3 ? assets.poses(c.id) : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(mainImageFor(c, st, assets), fit: BoxFit.contain),
                  if (st.isMaxLevel) const SparkleOverlay(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('${c.emoji} ${c.name}',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Text('担当：${c.subject}',
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 5; i++)
                  Container(
                    width: 16,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i < st.level ? Colors.amber : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(st.levelLabel,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: st.isMaxLevel
                            ? Colors.amber.shade800
                            : AppColors.sciencePrimary)),
              ],
            ),
          ),
          if (expressions.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('😊 表情', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _ImageRow(paths: expressions),
          ],
          if (poses.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('🙌 ポーズ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _ImageRow(paths: poses),
          ],
          const SizedBox(height: 16),
          if (st.level >= 4) ...[
            const Text('📖 バックストーリー',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(c.backstory, style: const TextStyle(height: 1.7)),
          ] else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text('Lv.4 でバックストーリーが解放されるよ！',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            ),
          const SizedBox(height: 20),
          if (st.isMaxLevel)
            Center(
              child: Text('✨ MAXレベル！',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800)),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => confirmAndLevelUp(context, ref, c, st, coins),
                icon: const Icon(Icons.upgrade, size: 18),
                label: Text(
                    'Lv.${st.level + 1} にレベルアップ（${st.nextLevelCost}コイン）'),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> confirmAndLevelUp(BuildContext context, WidgetRef ref,
    BaseCharacter c, CharacterState st, int coins) async {
  final next = st.level + 1;
  final cost = kLevelUpCost[next]!;
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('${c.name}を Lv.$next にする？'),
      content: Text('${kLevelUpFeatureDesc[next] ?? ''}\n\n'
          '$costコインを使います（持っているコイン: $coins）'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('やめる')),
        ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('レベルアップ')),
      ],
    ),
  );
  if (ok != true) return;
  final err = await ref.read(characterStateProvider.notifier).levelUp(c.id);
  messenger.showSnackBar(SnackBar(
      content: Text(err ??
          (next >= 5
              ? '✨ ${c.name}が MAX レベルになったよ！'
              : '${c.name}が Lv.$next になったよ！'))));
}

class _ImageRow extends StatelessWidget {
  final List<String> paths;
  const _ImageRow({required this.paths});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(paths[i], width: 96, height: 96, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
