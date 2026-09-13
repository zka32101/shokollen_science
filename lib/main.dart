import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart'
    hide progressProvider, LearningProgress, ProgressNotifier, FirebaseService, AppTheme;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'app/router.dart';
import 'app/theme.dart';
import 'features/settings/providers/theme_provider.dart';
import 'providers/character_provider.dart';
import 'services/firebase_service.dart';
import 'features/progress/services/daily_mystery_notification_service.dart';

void main() async {
  developer.log('=== 理科アプリ起動開始 ===', name: 'shokollen_science.main');

  // エラーハンドラーを設定
  FlutterError.onError = (details) {
    developer.log('Flutter Error: ${details.exceptionAsString()}',
        name: 'shokollen_science.error');
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
  };

  try {
    developer.log('WidgetsFlutterBinding.ensureInitialized() 開始',
        name: 'shokollen_science.init');
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('✓ WidgetsFlutterBinding initialized',
        name: 'shokollen_science.init');
    debugPrint('✓ WidgetsFlutterBinding initialized');

    developer.log('FirebaseService.initialize() 開始',
        name: 'shokollen_science.firebase');
    await FirebaseService.initialize();
    developer.log('✓ Firebase initialized',
        name: 'shokollen_science.firebase');
    debugPrint('✓ Firebase initialized');

    developer.log('Timezone 初期化開始',
        name: 'shokollen_science.init');
    tz.initializeTimeZones();
    developer.log('✓ Timezone initialized',
        name: 'shokollen_science.init');
    debugPrint('✓ Timezone initialized');

    try {
      developer.log('Notification 初期化開始',
          name: 'shokollen_science.notifications');
      await DailyMysteryNotificationService.initialize();
      await DailyMysteryNotificationService.scheduleDailyNotifications();
      developer.log('✓ Notifications initialized',
          name: 'shokollen_science.notifications');
      debugPrint('✓ Notifications initialized');
    } catch (e) {
      developer.log('⚠ Notification error: $e',
          name: 'shokollen_science.notifications');
      debugPrint('⚠ Notification error: $e');
    }

    developer.log('runApp() 開始 - MyApp を構築中',
        name: 'shokollen_science.app');
    runApp(
      ProviderScope(
        overrides: [
          characterStateProvider.overrideWith(CharacterNotifier.new),
        ],
        child: const MyApp(),
      ),
    );
    developer.log('✓ runApp() 完了',
        name: 'shokollen_science.app');
  } catch (e, stackTrace) {
    developer.log('Fatal error in main(): $e\nStack: $stackTrace',
        name: 'shokollen_science.error');
    debugPrint('Fatal error in main(): $e');
    debugPrint('Stack trace: $stackTrace');

    // エラー画面を表示
    runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('アプリエラー')),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('起動エラーが発生しました'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SelectableText('Error: $e'),
                    ),
                    const SizedBox(height: 16),
                    const Text('スタックトレース:'),
                    SelectableText('$stackTrace'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp.router(
      title: '小学コレ！理科',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
