import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../data/seeds/stages.dart';
import '../../../data/seeds/creatures.dart';
import '../../progress/providers/user_progress_provider.dart';
import '../../progress/views/progress_screen.dart';
import '../../encyclopedia/views/encyclopedia_screen.dart';
import '../../learn/views/learn_tab_screen.dart';
import '../../shop/views/shop_screen.dart';
import '../../trial/providers/trial_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../daily/providers/daily_challenge_provider.dart';
import '../../settings/providers/theme_provider.dart';
import '../../../shared/widgets/doctor_character_widget.dart';
import '../../../shared/widgets/mission_card_widget.dart';
import '../widgets/seasonal_recommendation_widget.dart';
import '../../daily/widgets/daily_login_bonus_widget.dart';
import '../../parent/widgets/praise_received_widget.dart';
import '../../weekly_challenge/widgets/weekly_challenge_widget.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../../progress/providers/daily_mystery_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  int _selectedGrade = 3; // ステージリストの選択学年

  // 今日のステージ（本来は Firestore の学習進度から取得）
  final _todayStage = stagesData[0]; // stage_3_001 昆虫と植物
  final int _totalCreatures = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
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
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(),
          _buildStreakBanner(),
          const DailyLoginBonusWidget(), // デイリーログインボーナス
          const PraiseReceivedWidget(), // 親からのほめメッセージ
          const WeeklyChallengeWidget(), // 今週のチャレンジ
          _buildDailyChallengeCard(),    // デイリーチャレンジ追加
          SeasonalRecommendationWidget(
            onTap: (stageId) => context.push('/quiz/$stageId'),
          ),
          _buildCharacterCard(),         // キャラ図鑑
          _buildWeeklyReportCard(),
          _buildGradeTestCard(),
          const MissionCardWidget(),     // ミッションカード
          const DoctorCharacterWidget(), // 博士キャラ追加
          const SizedBox(height: 8),
          _buildReviewCard(),            // にがて問題追加
          _buildTodayThemeCard(),
          _buildEncyclopediaSection(),
          _buildStageListSection(),
          _buildCollectionAndTestSection(),
          _buildDailyMysteryBadge(),
          _buildInnovationFeatures(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── アプリバー ────────────────────────────────────────
  Widget _buildAppBar() {
    final progressAsync = ref.watch(userProgressProvider);
    final trialAsync = ref.watch(trialProvider);
    final profileAsync = ref.watch(profileProvider);
    final activeProfile = profileAsync.value?.activeProfile;
    final coins = progressAsync.value?.coins ?? 0;
    final isPremium = trialAsync.value?.isPremium ?? false;
    final trialRemaining = trialAsync.value?.trialDaysRemaining ?? 14;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
      Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        gradient: AppColors.scienceGradient,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(activeProfile?.avatarEmoji ?? '🐻',
                          style: const TextStyle(fontSize: 16)),
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
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Text('🪙',
                          style: TextStyle(fontSize: 14)),
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
              const SizedBox(width: 8),
              // プレミアム / トライアル状態
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPremium
                        ? Colors.amber.withOpacity(0.8)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPremium
                        ? '👑 プレミアム'
                        : '⏳ あと${trialRemaining}日',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // ダークモード切り替え
              GestureDetector(
                onTap: () => ref.read(themeProvider.notifier).toggle(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    ref.watch(themeProvider) == ThemeMode.dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // 保護者ダッシュボード
              GestureDetector(
                onTap: () => context.push('/parent-dashboard'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          // トライアル期限切れバナー
          if (!isPremium && trialRemaining <= 0) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _selectedIndex = 3),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 7, horizontal: 12),
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
    const Positioned(
      right: 8,
      top: 4,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.10,
          child: Text('⚛️', style: TextStyle(fontSize: 56)),
        ),
      ),
    ),
    const Positioned(
      right: 76,
      bottom: 6,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.07,
          child: Text('🔭', style: TextStyle(fontSize: 30)),
        ),
      ),
    ),
    ],);
  }

  // ── ストリークバナー ──────────────────────────────────
  Widget _buildStreakBanner() {
    final progressAsync = ref.watch(userProgressProvider);
    final streakDays = progressAsync.value?.streakDays ?? 0;
    final totalPoints = progressAsync.value?.totalPoints ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: streakDays > 0 ? '$streakDays日 ' : '今日から ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      TextSpan(
                        text: streakDays > 0 ? '連続学習中！' : '学習を始めよう！',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '累計 $totalPoints pt',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textGray),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(7, (i) {
                    final weekFilled = streakDays > 0 &&
                        i < (streakDays % 7 == 0 ? 7 : streakDays % 7);
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: weekFilled
                            ? const Color(0xFFE65100)
                            : const Color(0xFFFFD54F).withOpacity(0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: weekFilled
                              ? const Color(0xFFE65100)
                              : const Color(0xFFFFD54F),
                          width: 1.5,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8F00),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '⭐',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                      horizontal: 10, vertical: 4),
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
                    onPressed: () => context
                        .go('/quiz/${_todayStage['id']}'),
                    icon: const Icon(Icons.play_arrow_rounded,
                        size: 22),
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

  // ── 図鑑セクション ────────────────────────────────────
  Widget _buildEncyclopediaSection() {
    // クリア済みステージ数を生き物のアンロック数として使用
    final progressAsync = ref.watch(userProgressProvider);
    final clearedCount = progressAsync.value?.clearedCount ?? 0;
    // クリアステージ数に応じて生き物アンロック（最大_totalCreatures体）
    final completedCreatures = clearedCount.clamp(0, _totalCreatures);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌿', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                '生き物図鑑',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 2),
                child: const Text(
                  'すべて見る →',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.sciencePrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '$completedCreatures / $_totalCreatures 発見',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completedCreatures / _totalCreatures,
                    backgroundColor: AppColors.borderGray,
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.success),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: 8,
            itemBuilder: (_, i) {
              final unlocked = i < completedCreatures;
              return _CreatureCell(
                creatureData: creaturesData[i],
                unlocked: unlocked,
              );
            },
          ),
        ],
      ),
    );
  }

  // ── ステージ一覧（全学年・学年フィルタ付き） ────────────
  Widget _buildStageListSection() {
    final progressAsync = ref.watch(userProgressProvider);
    final clearedStages = progressAsync.value?.clearedStages ?? {};

    final filteredStages = stagesData
        .where((s) => s['gradeLevel'] == _selectedGrade)
        .toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── タイトル ──
          const Row(
            children: [
              Text('📚', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                '学年を選んで学ぼう',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── 学年フィルタチップ ──
          Row(
            children: [3, 4, 5, 6].map((grade) {
              final selected = _selectedGrade == grade;
              // その学年のクリア数
              final gradeStages = stagesData
                  .where((s) => s['gradeLevel'] == grade)
                  .toList();
              final cleared = gradeStages
                  .where((s) => clearedStages.containsKey(s['id']))
                  .length;
              final isComplete = cleared == gradeStages.length;

              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedGrade = grade),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.sciencePrimary
                          : AppColors.scienceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.sciencePrimary
                            : AppColors.borderGray,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${grade}年',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                        ),
                        Text(
                          isComplete
                              ? '✅'
                              : '$cleared/${gradeStages.length}',
                          style: TextStyle(
                            fontSize: 10,
                            color: selected
                                ? Colors.white70
                                : AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // ── ステージリスト ──
          ...filteredStages.map((s) {
            final stageId = s['id'] as String;
            final bestScore = clearedStages[stageId];
            final isCleared = bestScore != null;
            return _StageListTile(
              stageData: s,
              isCleared: isCleared,
              bestScore: bestScore,
              onTap: () => context.go('/quiz/$stageId'),
            );
          }),
        ],
      ),
    );
  }

  // ── コレクション帳・まとめテストセクション ─────────────────
  Widget _buildCollectionAndTestSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📚 学習メニュー',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/collection'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderGray),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                    ),
                    child: const Column(
                      children: [
                        Text('📚', style: TextStyle(fontSize: 28)),
                        SizedBox(height: 4),
                        Text('コレクション帳',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // 学年選択ダイアログ
                    showModalBottomSheet<void>(
                      context: context,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (_) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('学年を選んでください',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [3, 4, 5, 6].map((g) => GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push('/comprehensive-test/$g');
                                },
                                child: Container(
                                  width: 64, height: 64,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [Colors.purple[700]!, Colors.purple[400]!]),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text('$g年',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              )).toList(),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.purple[700]!, Colors.purple[400]!]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.purple.withValues(alpha: 0.3), blurRadius: 6)],
                    ),
                    child: const Column(
                      children: [
                        Text('📝', style: TextStyle(fontSize: 28)),
                        SizedBox(height: 4),
                        Text('まとめテスト',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── デイリーチャレンジカード ─────────────────────────────
  Widget _buildDailyChallengeCard() {
    final dailyAsync = ref.watch(dailyChallengeProvider);
    final daily = dailyAsync.value;
    final completed = daily?.completed ?? false;

    return GestureDetector(
      onTap: completed ? null : () => context.push('/daily-challenge'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: completed
              ? LinearGradient(colors: [Colors.grey[300]!, Colors.grey[200]!])
              : LinearGradient(colors: [Colors.amber[700]!, Colors.orange[500]!]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: completed
              ? []
              : [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Text(completed ? '✅' : '⚡', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    completed ? 'デイリーチャレンジ 完了！' : '今日のデイリーチャレンジ',
                    style: TextStyle(
                      color: completed ? Colors.grey[600] : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    completed ? 'また明日チャレンジしよう' : '3問クリアで 🪙 +30 コイン！',
                    style: TextStyle(
                      color: completed ? Colors.grey[500] : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!completed)
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ── 週次レポートカード ────────────────────────────────────
  Widget _buildWeeklyReportCard() {
    return GestureDetector(
      onTap: () => context.push('/weekly-report'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.purple[600]!, Colors.indigo[500]!]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.purple.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            const Text('📊', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('今週のレポート', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('学習グラフ・弱点チェック', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ── キャラクター図鑑カード ───────────────────────────────────
  Widget _buildCharacterCard() {
    final progressAsync = ref.watch(userProgressProvider);
    final cleared = progressAsync.value?.clearedCount ?? 0;
    return GestureDetector(
      onTap: () => context.push('/characters'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.teal[600]!, Colors.cyan[500]!]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.teal.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            const Text('🔬', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('理科博士コレクション',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  Text('$cleared ステージクリア・16体のキャラを集めよう',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ── 学年末まとめテストカード ────────────────────────────────
  Widget _buildGradeTestCard() {
    return GestureDetector(
      onTap: () => context.push('/grade-test'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.orange[700]!, Colors.deepOrange[500]!]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('学年末まとめテスト', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('認定証をゲットしよう！', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ── にがて問題カード ──────────────────────────────────────
  Widget _buildReviewCard() {
    final progressAsync = ref.watch(userProgressProvider);
    final wrongCount = progressAsync.value?.wrongAnswers.values
        .fold(0, (sum, list) => sum + list.length) ?? 0;
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
                style: TextStyle(fontSize: 13, color: Colors.red[700], fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.red[400]),
          ],
        ),
      ),
    );
  }

  // ── Coming soon タブ ─────────────────────────────────
  Widget _buildComingSoonTab(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 36, color: AppColors.textGray)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15, color: AppColors.textGray),
          ),
        ],
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
      case 'easy': return '⭐ かんたん';
      case 'hard': return '⭐⭐⭐ むずかしい';
      default:     return '⭐⭐ ふつう';
    }
  }

  // ── 今日のふしぎバッジ ────────────────────────────────────────
  Widget _buildDailyMysteryBadge() {
    return Consumer(
      builder: (context, ref, child) {
        final record = ref.watch(dailyMysteryNotifierProvider);
        final isRevealed = record != null;
        final isAnswered = record != null && record.answeredAt != null;

        return GestureDetector(
              onTap: () => context.push('/daily-mystery-omikuji'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.95),
                        const Color(0xFF4F46E5).withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Emoji with status
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: Center(
                          child: Text(
                            isAnswered
                                ? '✨'
                                : isRevealed
                                    ? '📖'
                                    : '📿',
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '今日のふしぎ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAnswered
                                  ? '✅ 完了！'
                                  : isRevealed
                                      ? '🔍 答えを見よう'
                                      : '未引',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
      },
    );
  }

  // ── 革新機能セクション ────────────────────────────────────────
  Widget _buildInnovationFeatures() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '特別チャレンジ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: [
              _buildFeatureCard(
                emoji: '🔬',
                title: 'よそうラボ',
                subtitle: '実験前に予想しよう！',
                color: const Color(0xFF3498DB),
                onTap: () => context.push('/prediction-quiz/exp_magnet_001'),
              ),
              _buildFeatureCard(
                emoji: '🤖',
                title: 'りかハカセ',
                subtitle: 'AIに質問しよう！',
                color: const Color(0xFF5C6BC0),
                onTap: () => context.push('/ai-chat'),
              ),
              _buildFeatureCard(
                emoji: '🕵️',
                title: '失敗ラボ',
                subtitle: '失敗の原因を推理！',
                color: const Color(0xFFF57F17),
                onTap: () => context.push('/troubleshoot/exp_001'),
              ),
              _buildFeatureCard(
                emoji: '⚔️',
                title: '親子バトル',
                subtitle: '親子で予想対決！',
                color: const Color(0xFF6A1B9A),
                onTap: () => context.push('/prediction-battle'),
              ),
              _buildFeatureCard(
                emoji: '🏡',
                title: 'おうちラボ',
                subtitle: '週末リアル実験！',
                color: const Color(0xFF2E7D32),
                onTap: () => context.push('/home-lab'),
              ),
              _buildFeatureCard(
                emoji: '🌌',
                title: '今夜の空',
                subtitle: '星・月を観察しよう',
                color: const Color(0xFF0D1B4B),
                onTap: () => context.push('/tonight-sky'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: -6,
              bottom: -12,
              child: Text(
                emoji,
                style: TextStyle(fontSize: 64, color: Colors.white.withOpacity(0.12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
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
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CreatureCell extends StatelessWidget {
  final Map<String, dynamic> creatureData;
  final bool unlocked;
  const _CreatureCell(
      {required this.creatureData, required this.unlocked});

  static const _categoryEmoji = {
    'insect': '🦋',
    'bird': '🐦',
    'mammal': '🐾',
    'plant': '🌿',
    'other': '🐌',
  };

  @override
  Widget build(BuildContext context) {
    final emoji = _categoryEmoji[creatureData['category']] ?? '🔬';
    return Container(
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.scienceLight
            : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: unlocked
              ? AppColors.sciencePrimary.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          unlocked
              ? Text(emoji, style: const TextStyle(fontSize: 24))
              : const Icon(Icons.lock, color: Colors.grey, size: 20),
          const SizedBox(height: 2),
          Text(
            unlocked
                ? (creatureData['name'] as String)
                    .replaceAll(RegExp(r'[ぁ-ん]+'), '')
                    .substring(0, (creatureData['name'] as String)
                            .length
                            .clamp(0, 4))
                : '???',
            style: TextStyle(
              fontSize: 9,
              color: unlocked
                  ? AppColors.textDark
                  : AppColors.textGray,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StageListTile extends StatelessWidget {
  final Map<String, dynamic> stageData;
  final VoidCallback onTap;
  final bool isCleared;
  final int? bestScore;

  const _StageListTile({
    required this.stageData,
    required this.onTap,
    this.isCleared = false,
    this.bestScore,
  });

  static const _categoryColor = {
    'biology': Color(0xFF43A047),
    'physics': Color(0xFF1E88E5),
    'chemistry': Color(0xFF8E24AA),
    'earth': Color(0xFF6D4C41),
  };

  static const _categoryEmoji = {
    'biology': '🌱',
    'physics': '⚡',
    'chemistry': '🧪',
    'earth': '🌍',
  };

  @override
  Widget build(BuildContext context) {
    final cat = stageData['category'] as String;
    final color = _categoryColor[cat] ?? AppColors.sciencePrimary;
    final emoji = _categoryEmoji[cat] ?? '🔬';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCleared ? const Color(0xFFF0FFF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: color, width: 4),
            top: BorderSide(color: isCleared ? AppColors.success.withOpacity(0.3) : AppColors.borderGray),
            right: BorderSide(color: isCleared ? AppColors.success.withOpacity(0.3) : AppColors.borderGray),
            bottom: BorderSide(color: isCleared ? AppColors.success.withOpacity(0.3) : AppColors.borderGray),
          ),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Text(emoji,
                  style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FuriganaText(
                    stageData['stageName'] as String,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    stageData['description'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isCleared) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 18),
                  Text(
                    '$bestScore%',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ] else
              Icon(Icons.chevron_right, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
