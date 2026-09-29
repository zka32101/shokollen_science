import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_core/shared_core.dart'
    show coinProvider, inventoryProvider;
import '../../../shared/constants/app_colors.dart';
import '../../profile/providers/profile_provider.dart';
import '../../progress/providers/user_progress_provider.dart';
import '../../profile/models/profile_model.dart';
import '../../../shared/widgets/avatar_image.dart';
import '../../../providers/selected_background_provider.dart';
import '../../../data/background_shop_items.dart';

/// せってい画面（国語コレの settings_screen 構成を参考に、理科コレ向けに簡略化）
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider).value;
    final activeProfile = ref.watch(profileProvider).value?.activeProfile;
    final coins = ref.watch(coinProvider).totalCoins;

    return Scaffold(
      appBar: AppBar(
        title: const Text('せってい'),
        backgroundColor: AppColors.sciencePrimary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'がくしゅうしゃ'),
          ListTile(
            leading: AvatarImage(
              imagePath:
                  activeProfile?.avatarImagePath ??
                  ProfileModel.avatarChoices[0],
              size: 32,
            ),
            title: Text(activeProfile?.nickname ?? 'なし'),
            subtitle: Text(activeProfile?.gradeLabel ?? ''),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => context.push('/profile-select'),
          ),
          const Divider(),
          _SectionHeader(title: 'きろく'),
          ListTile(
            leading: const Text('🔥', style: TextStyle(fontSize: 20)),
            title: const Text('れんぞく学習'),
            trailing: Text(
              '${progress?.streakDays ?? 0}日',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Text('🪙', style: TextStyle(fontSize: 20)),
            title: const Text('コイン'),
            trailing: Text(
              '$coins',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Text('🏁', style: TextStyle(fontSize: 20)),
            title: const Text('クリアしたステージ'),
            trailing: Text(
              '${progress?.clearedCount ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Text('🧪', style: TextStyle(fontSize: 20)),
            title: const Text('やったじっけん'),
            trailing: Text(
              '${progress?.completedExperimentIds.length ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          _SectionHeader(title: '見た目'),
          _BackgroundSelector(),
          const Divider(),
          _SectionHeader(title: 'プレミアム'),
          ListTile(
            leading: const Text('🏆', style: TextStyle(fontSize: 20)),
            title: const Text('プレミアムプラン'),
            subtitle: const Text('全きのう使い放題・広告なし'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => context.push('/premium'),
          ),
          const Divider(),
          _SectionHeader(title: 'ほごしゃ向け'),
          ListTile(
            leading: const Text('👨‍👩‍👧', style: TextStyle(fontSize: 20)),
            title: const Text('保護者ダッシュボード'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => context.push('/parent-dashboard'),
          ),
          const Divider(),
          _SectionHeader(title: 'アプリについて'),
          ListTile(
            leading: const Text('🏅', style: TextStyle(fontSize: 20)),
            title: const Text('バッジコレクション'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => context.push('/collection'),
          ),
          ListTile(
            leading: const Text('📱', style: TextStyle(fontSize: 20)),
            title: const Text('他のアプリを見る'),
            subtitle: const Text('小学コレ！シリーズの他の教科アプリを紹介します'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => launchUrl(
              Uri.parse('https://sites.google.com/view/yourwishapps'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.red),
              label: const Text(
                'がくしゅうきろくをリセット',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _confirmReset(context, ref),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('きろくをリセットしますか？'),
        content: const Text('すべての学習記録とバッジが消えます。この操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(userProgressProvider.notifier).resetProgress();
            },
            child: const Text('リセット', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// 所持している背景アイテムだけを選べる（未所持はショップ購入を促す）。
class _BackgroundSelector extends ConsumerWidget {
  static const _labels = {
    'bg_space': '🌌 宇宙の背景',
    'bg_forest': '🌲 森の背景',
    'bg_lab': '🧪 実験室の背景',
    'bg_spring_flowers': '🌸 春の花畑',
    'bg_ocean': '🌊 海の中の背景',
    'bg_autumn_leaves': '🍁 紅葉の背景',
    'bg_snow': '❄️ 雪の結晶の背景',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(inventoryProvider);
    final selected = ref.watch(selectedBackgroundProvider);
    final ownedBackgrounds =
        kBackgroundGradients.keys.where(owned.contains).toList();

    if (ownedBackgrounds.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'ショップで背景を購入すると、ここから選べるようになります',
          style: TextStyle(fontSize: 12, color: AppColors.textGray),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('デフォルト'),
            selected: selected == null,
            onSelected: (_) =>
                ref.read(selectedBackgroundProvider.notifier).select(null),
          ),
          for (final id in ownedBackgrounds)
            ChoiceChip(
              label: Text(_labels[id] ?? id),
              selected: selected == id,
              onSelected: (_) =>
                  ref.read(selectedBackgroundProvider.notifier).select(id),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.sciencePrimary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
