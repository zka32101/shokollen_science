import 'package:go_router/go_router.dart';
import '../features/auth/views/splash_login_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/quiz/views/quiz_screen.dart';
import '../features/quiz/views/quiz_result_screen.dart';
import '../features/learn/views/learn_screen.dart';
import '../features/experiment/views/experiment_detail_screen.dart';
import '../features/profile/views/profile_select_screen.dart';
import '../features/profile/views/profile_create_screen.dart';
import '../features/daily/views/daily_challenge_screen.dart';
import '../features/review/views/review_screen.dart';
import '../features/progress/views/today_reviews_screen.dart';
import '../features/parent/views/parent_dashboard_screen.dart';
import '../features/parent/views/praise_send_screen.dart';
import '../features/test/views/comprehensive_test_screen.dart';
import '../features/collection/views/collection_screen.dart';
import '../features/onboarding/views/onboarding_screen.dart';
import '../features/weekly_report/views/weekly_report_screen.dart';
import '../features/grade_test/views/grade_test_screen.dart';
import '../features/grade_test/views/certificate_screen.dart';
import '../features/quiz/views/timer_quiz_screen.dart';
import '../features/quiz/views/timer_quiz_result_screen.dart';
import '../features/character/views/character_screen.dart';
import '../features/experiments/views/prediction_quiz_screen.dart';
import '../features/experiments/views/troubleshoot_screen.dart';
import '../features/battle/views/prediction_battle_screen.dart';
import '../features/ai_chat/views/ai_chat_screen.dart';
import '../features/home_lab/views/home_lab_screen.dart';
import '../features/sky/views/tonight_sky_screen.dart';
import '../features/weekly_challenge/views/weekly_challenge_screen.dart';
import '../features/progress/views/daily_mystery_omikuji_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // スプラッシュ / ログイン
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (_, __) => const SplashLoginScreen(),
      ),

      // ホーム
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),

      // クイズ
      GoRoute(
        path: '/quiz/:stageId',
        name: 'quiz',
        builder: (_, state) {
          final stageId =
              state.pathParameters['stageId'] ?? 'stage_3_001';
          return QuizScreen(stageId: stageId);
        },
      ),

      // クイズ結果
      GoRoute(
        path: '/quiz-result',
        name: 'quiz-result',
        builder: (_, __) => const QuizResultScreen(),
      ),

      // まなぶ（学習モード）
      GoRoute(
        path: '/learn/:stageId',
        name: 'learn',
        builder: (_, state) {
          final stageId =
              state.pathParameters['stageId'] ?? 'stage_3_001';
          return LearnScreen(stageId: stageId);
        },
      ),

      // 実験詳細
      GoRoute(
        path: '/experiment/:experimentId',
        name: 'experiment-detail',
        builder: (_, state) {
          final experimentId =
              state.pathParameters['experimentId'] ?? 'exp_magnet_001';
          return ExperimentDetailScreen(experimentId: experimentId);
        },
      ),

      // プロフィール選択
      GoRoute(
        path: '/profile-select',
        name: 'profile-select',
        builder: (_, __) => const ProfileSelectScreen(),
      ),
      // プロフィール作成
      GoRoute(
        path: '/profile-create',
        name: 'profile-create',
        builder: (_, __) => const ProfileCreateScreen(),
      ),
      // デイリーチャレンジ
      GoRoute(
        path: '/daily-challenge',
        name: 'daily-challenge',
        builder: (_, __) => const DailyChallengeScreen(),
      ),
      // 復習モード
      GoRoute(
        path: '/review',
        name: 'review',
        builder: (_, __) => const ReviewScreen(),
      ),
      // 今日の復習（タイムカプセル）
      GoRoute(
        path: '/today-reviews',
        name: 'today-reviews',
        builder: (_, __) => const TodayReviewsScreen(),
      ),
      // 保護者ダッシュボード
      GoRoute(
        path: '/parent-dashboard',
        name: 'parent-dashboard',
        builder: (_, __) => const ParentDashboardScreen(),
      ),
      // まとめテスト
      GoRoute(
        path: '/comprehensive-test/:grade',
        name: 'comprehensive-test',
        builder: (_, state) {
          final grade = int.tryParse(state.pathParameters['grade'] ?? '3') ?? 3;
          return ComprehensiveTestScreen(grade: grade);
        },
      ),
      // コレクション帳
      GoRoute(
        path: '/collection',
        name: 'collection',
        builder: (_, __) => const CollectionScreen(),
      ),
      // オンボーディング
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      // 週次レポート
      GoRoute(
        path: '/weekly-report',
        name: 'weekly-report',
        builder: (_, __) => const WeeklyReportScreen(),
      ),
      // 学年末まとめテスト
      GoRoute(
        path: '/grade-test',
        name: 'grade-test',
        builder: (_, __) => const GradeTestScreen(),
      ),
      // 認定証
      GoRoute(
        path: '/certificate/:grade',
        name: 'certificate',
        builder: (_, state) {
          final grade = int.tryParse(state.pathParameters['grade'] ?? '3') ?? 3;
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CertificateScreen(
            grade: grade,
            correct: extra['correct'] as int? ?? 0,
            total: extra['total'] as int? ?? 20,
          );
        },
      ),
      // タイマークイズ
      GoRoute(
        path: '/quiz-timer/:stageId',
        name: 'quiz-timer',
        builder: (_, state) {
          final stageId = state.pathParameters['stageId'] ?? 'stage_3_001';
          return TimerQuizScreen(stageId: stageId);
        },
      ),
      // タイマークイズ結果
      GoRoute(
        path: '/timer-quiz-result',
        name: 'timer-quiz-result',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return TimerQuizResultScreen(
            stageId: extra['stageId'] as String? ?? 'stage_3_001',
            correct: extra['correct'] as int? ?? 0,
            total: extra['total'] as int? ?? 0,
            allSelected: List<int?>.from(extra['allSelected'] as List? ?? []),
            questions: List<Map<String, dynamic>>.from(
                extra['questions'] as List? ?? []),
          );
        },
      ),
      // キャラクター図鑑
      GoRoute(
        path: '/characters',
        name: 'characters',
        builder: (_, __) => const CharacterScreen(),
      ),

      // ① よそうラボ
      GoRoute(
        path: '/prediction-quiz/:experimentId',
        name: 'prediction-quiz',
        builder: (_, state) {
          final experimentId =
              state.pathParameters['experimentId'] ?? 'exp_magnet_001';
          return PredictionQuizScreen(experimentId: experimentId);
        },
      ),

      // ⑥ 失敗ラボ推理
      GoRoute(
        path: '/troubleshoot/:experimentId',
        name: 'troubleshoot',
        builder: (_, state) {
          final experimentId =
              state.pathParameters['experimentId'] ?? 'exp_001';
          return TroubleshootScreen(experimentId: experimentId);
        },
      ),

      // ⑨ 親子バトル
      GoRoute(
        path: '/prediction-battle',
        name: 'prediction-battle',
        builder: (_, __) => const PredictionBattleScreen(),
      ),

      // ② AIはかせチャット
      GoRoute(
        path: '/ai-chat',
        name: 'ai-chat',
        builder: (_, __) => const AiChatScreen(),
      ),

      // ③ おうちラボ
      GoRoute(
        path: '/home-lab',
        name: 'home-lab',
        builder: (_, __) => const HomeLabScreen(),
      ),

      // ④ 今夜の空
      GoRoute(
        path: '/tonight-sky',
        name: 'tonight-sky',
        builder: (_, __) => const TonightSkyScreen(),
      ),

      // 今週のチャレンジ
      GoRoute(
        path: '/weekly-challenge',
        name: 'weekly-challenge',
        builder: (_, __) => const WeeklyChallengeScreen(),
      ),

      // 今日のふしぎ（おみくじ）
      GoRoute(
        path: '/daily-mystery-omikuji',
        name: 'daily-mystery-omikuji',
        builder: (_, __) => const DailyMysteryOmikujiScreen(),
      ),

      // ほめメッセージ送信（親用）
      GoRoute(
        path: '/praise-send/:stageId',
        name: 'praise-send',
        builder: (_, state) {
          final stageId = state.pathParameters['stageId'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final stageName = extra['stageName'] as String? ?? stageId;
          return PraiseSendScreen(stageId: stageId, stageName: stageName);
        },
      ),
    ],
  );
}
