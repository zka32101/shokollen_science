import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/branded_splash.dart';
import '../../profile/providers/profile_provider.dart';

/// スプラッシュ画面 - 自動遷移（ボタンなし）
class SplashLoginScreen extends ConsumerStatefulWidget {
  const SplashLoginScreen({super.key});

  @override
  ConsumerState<SplashLoginScreen> createState() => _SplashLoginScreenState();
}

class _SplashLoginScreenState extends ConsumerState<SplashLoginScreen> {
  @override
  void initState() {
    super.initState();

    // 起動画面（StartupSplash）が先に出ているため短く待って自動遷移
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _navigate();
    });
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!mounted) return;

    if (!onboardingDone) {
      context.go('/onboarding');
      return;
    }

    // profileProvider の非同期ロードが完了するまで待つ
    // (ref.read(profileProvider).value はロード中に null になり、
    //  プロフィール作成済みでも毎回プロフィール作成画面に飛ばされるバグの原因だった)
    ProfileState profileState;
    try {
      profileState = await ref.read(profileProvider.future);
    } catch (_) {
      profileState = const ProfileState();
    }
    if (!mounted) return;
    if (!profileState.hasProfiles) {
      // プロフィール未作成 → 作成画面へ
      context.go('/profile-create');
    } else {
      // プロフィール作成済み → ホームへ直遷移（profile-select をスキップ）
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 起動画面（StartupSplash）と同じ見た目。アニメを再生し直さない。
    return const BrandedSplash();
  }
}
