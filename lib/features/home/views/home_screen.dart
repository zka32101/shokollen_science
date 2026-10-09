import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart'
    show coinProvider, inventoryProvider;
import '../../../shared/constants/app_colors.dart';
import '../../../data/seeds/stages.dart';
import '../../progress/providers/user_progress_provider.dart';
import '../../progress/views/progress_screen.dart';
import '../../encyclopedia/views/encyclopedia_screen.dart';
import '../../learn/views/learn_tab_screen.dart';
import '../../shop/views/shop_screen.dart';
import '../../trial/providers/trial_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../daily/providers/daily_challenge_provider.dart';
import '../../../shared/widgets/mission_card_widget.dart';
import '../../daily/widgets/daily_login_bonus_widget.dart';
import '../../parent/widgets/praise_received_widget.dart';
import '../../weekly_challenge/widgets/weekly_challenge_widget.dart';
import '../../profile/models/profile_model.dart';
import '../../../shared/widgets/avatar_image.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../../progress/providers/daily_mystery_provider.dart';
import '../../../providers/selected_background_provider.dart';
import '../../../data/background_shop_items.dart';
import 'package:shokollen_science/widgets/ukalab_emoji.dart';
import 'package:shokollen_science/widgets/title_plate.dart';
import '../../shop/decor/title_provider.dart';

import 'package:shokollen_science/features/shop/decor/decor_scope.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  // 今日のステージ（本来は Firestore の学習進度から取得）
  final _todayStage = stagesData[0]; // stage_3_001 昆虫と植物

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DecorScope.pageBg(context, const Color(0xFFF7F9FC)),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            const LearnTabScreen(),
            const EncyclopediaScreen(),
            const ShopScreen(),
            const ProgressScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }


  // ── ホームタブ ────────────────────────────────────────
  // 主役は「今日のテーマ」1枚。毎日系は横並び、その他の機能は統一色のメニューにまとめる。
  // 図鑑・ステージ一覧は専用タブにあるためホームには置かない。
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(),
          const DailyLoginBonusWidget(),
          const PraiseReceivedWidget(),
          _buildTodayThemeCard(),
          _buildDailyRow(),
          const WeeklyChallengeWidget(),
          const MissionCardWidget(),
          _buildReviewCard(),
          _buildMenuGrid(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── デイリーチャレンジ / 今日のふしぎ（横並び） ─────────────
  Widget _buildDailyRow() {
    final completed = ref.watch(dailyChallengeProvider).value?.completed ?? false;
    final mystery = ref.watch(dailyMysteryNotifierProvider);
    final mysteryDone = mystery != null && mystery.answeredAt != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildDailyTile(
              emoji: completed ? '✅' : '⚡',
              title: 'デイリー',
              subtitle: completed ? 'また明日！' : '3問で🪙+30',
              done: completed,
              onTap: completed ? null : () => context.push('/daily-challenge'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDailyTile(
              emoji: mysteryDone ? '✅' : '✨',
              title: '今日のふしぎ',
              subtitle: mysteryDone ? '完了！' : 'ひいてみよう',
              done: mysteryDone,
              onTap: () => context.push('/daily-mystery-omikuji'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTile({
    required String emoji,
    required String title,
    required String subtitle,
    required bool done,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done ? AppColors.borderGray : AppColors.sciencePrimary,
          ),
        ),
        child: Row(
          children: [
            UkalabEmoji(emoji, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: done ? AppColors.textGray : AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── その他の機能メニュー（3列・統一色） ─────────────────────
  Widget _buildMenuGrid() {
    final items = <(String, String, String)>[
      ('🔬', '理科博士', '/characters'),
      ('📊', 'レポート', '/weekly-report'),
      ('🏆', 'まとめテスト', '/grade-test'),
      ('🔮', 'よそうラボ', '/prediction-quiz/exp_magnet_001'),
      ('🕵️', '失敗ラボ', '/troubleshoot/exp_001'),
      ('⚔️', '親子バトル', '/prediction-battle'),
      ('🏡', 'おうちラボ', '/home-lab'),
      ('🌌', '今夜の空', '/tonight-sky'),
      ('📚', 'コレクション', '/collection'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'もっとあそぶ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: [
              for (final (emoji, label, route) in items)
                GestureDetector(
                  onTap: () => context.push(route),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.scienceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        UkalabEmoji(emoji, size: 26),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── アプリバー ────────────────────────────────────────
  Widget _buildAppBar() {
    final trialAsync = ref.watch(trialProvider);
    final profileAsync = ref.watch(profileProvider);
    final activeProfile = profileAsync.value?.activeProfile;
    // ショップ画面（shared_core の CoinShopPage）と同じ coinProvider を参照し、
    // コイン残高の表示元を統一する（独自 progress.coins との二重管理を解消）。
    final coins = ref.watch(coinProvider).totalCoins;
    final isPremium = trialAsync.value?.isPremium ?? false;
    final activeTitle = ref.watch(activeTitleProvider);
    final trialRemaining = trialAsync.value?.trialDaysRemaining ?? 14;

    // 購入済みの背景がショップで選択されていれば、その配色をヘッダーに反映する。
    final selectedBackgroundId = ref.watch(selectedBackgroundProvider);
    final ownedItems = ref.watch(inventoryProvider);
    final backgroundColors =
        selectedBackgroundId != null && ownedItems.contains(selectedBackgroundId)
            ? kBackgroundGradients[selectedBackgroundId]
            : null;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            gradient: backgroundColors != null
                ? LinearGradient(
                    colors: backgroundColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppColors.scienceGradient,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '小学コレ！',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        '理科',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // プロフィール切り替えボタン
                  GestureDetector(
                    onTap: () => context.push('/profile-select'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AvatarImage(
                            imagePath:
                                activeProfile?.avatarImagePath ??
                                ProfileModel.avatarChoices[0],
                            size: 28, // きせかえフレームが出る最小サイズ(DecorFrame)
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activeProfile?.nickname ?? 'たろう',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // コイン残高
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '$coins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // トライアル残日数（プレミアム会員には表示しない）
                  if (!isPremium) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⏳ あと$trialRemaining日',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ],
                  const SizedBox(width: 6),
                  // せってい（ダークモード切替・保護者ダッシュボードは設定画面に移動）
                  GestureDetector(
                    onTap: () => context.push('/settings'),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              // 選んだ称号(名前の下)。未選択なら何も出さない
              if (activeTitle != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TitlePlate(key: const ValueKey('home_title_plate'), name: activeTitle.name),
                ),
              ],
              // トライアル期限切れバナー
              if (!isPremium && trialRemaining <= 0) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 3),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('⚠️ ', style: TextStyle(fontSize: 14)),
                        Text(
                          'トライアル終了！プレミアムにアップグレードしよう',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── ストリークバナー ──────────────────────────────────
  // ── 今日のテーマカード ────────────────────────────────
  Widget _buildTodayThemeCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.sciencePrimary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 背景の大きい絵文字
          Positioned(
            right: 12,
            top: 8,
            child: Text(
              '🔬',
              style: TextStyle(
                fontSize: 72,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '📅 今日のテーマ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FuriganaText(
                  _todayStage['stageName'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _todayStage['description'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                // 学年・難易度バッジ
                Row(
                  children: [
                    _Badge(
                      '${_todayStage['gradeLevel']}年生',
                      const Color(0xFF42A5F5),
                    ),
                    const SizedBox(width: 6),
                    _Badge(
                      _diffLabel(_todayStage['difficultyLevel'] as String),
                      const Color(0xFF26C6DA),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 探索ボタン
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/quiz/${_todayStage['id']}'),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text(
                      '探索を開始 →',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.sciencePrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }








  // ── にがて問題カード ──────────────────────────────────────
  Widget _buildReviewCard() {
    final progressAsync = ref.watch(userProgressProvider);
    final wrongCount =
        progressAsync.value?.wrongAnswers.values.fold(
          0,
          (sum, list) => sum + list.length,
        ) ??
        0;
    if (wrongCount == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/review'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Text('📝', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'にがて問題 $wrongCount問 — やり直してみよう！',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.red[400]),
          ],
        ),
      ),
    );
  }


  // ── ボトムナビ ────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.sciencePrimary,
        unselectedItemColor: Colors.grey[400],
        selectedFontSize: 10,
        unselectedFontSize: 10,
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book_rounded),
            label: 'まなぶ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nature_outlined),
            activeIcon: Icon(Icons.nature_rounded),
            label: '図鑑',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront_rounded),
            label: 'ショップ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events_rounded),
            label: '記録',
          ),
        ],
      ),
    );
  }

  String _diffLabel(String level) {
    switch (level) {
      case 'easy':
        return '⭐ かんたん';
      case 'hard':
        return '⭐⭐⭐ むずかしい';
      default:
        return '⭐⭐ ふつう';
    }
  }


}

// ── 補助ウィジェット ──────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}



