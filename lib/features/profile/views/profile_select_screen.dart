import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../providers/profile_provider.dart';
import '../models/profile_model.dart';

class ProfileSelectScreen extends ConsumerWidget {
  const ProfileSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return profileState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('エラーが発生しました')),
      ),
      data: (state) => _ProfileSelectView(state: state),
    );
  }
}

class _ProfileSelectView extends ConsumerWidget {
  final ProfileState state;
  const _ProfileSelectView({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.scienceGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // タイトル
              const Text(
                'だれがあそぶ？',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'プロフィールをえらんでね',
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              // プロフィールグリッド
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    ...state.profiles.map((p) => _ProfileCard(
                          profile: p,
                          isActive: p.id == state.activeProfileId,
                          onTap: () async {
                            await ref
                                .read(profileProvider.notifier)
                                .switchProfile(p.id);
                            if (context.mounted) context.go('/home');
                          },
                          onDelete: state.profiles.length > 1
                              ? () => _confirmDelete(context, ref, p)
                              : null,
                        )),
                    if (state.profiles.length < kMaxProfiles)
                      _AddProfileCard(
                        onTap: () => context.push('/profile-create'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ProfileModel profile) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${profile.nickname} を削除しますか？'),
        content: const Text('進捗データもすべて削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(profileProvider.notifier)
                  .deleteProfile(profile.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ProfileCard({
    required this.profile,
    required this.isActive,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete != null
          ? () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => SafeArea(
                  child: ListTile(
                    leading:
                        const Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('${profile.nickname} を削除'),
                    onTap: () {
                      Navigator.pop(context);
                      onDelete?.call();
                    },
                  ),
                ),
              )
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.sciencePrimary : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: AppColors.sciencePrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'いま選んでるよ',
                  style: TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            Text(profile.avatarEmoji,
                style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 8),
            Text(
              profile.nickname,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.scienceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${profile.gradeLevel}年生',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.sciencePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProfileCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.5), width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 48, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'ついか',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
