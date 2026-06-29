import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/constants/app_colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      emoji: '🔬',
      title: '小学コレ！理科へようこそ',
      description: '小学3〜6年生の理科を\nたのしく学べるアプリです！',
      color1: Color(0xFF5C9BD4),
      color2: Color(0xFF3A7DC9),
    ),
    _OnboardingPage(
      emoji: '📖',
      title: 'まなぶ→クイズで理解が深まる',
      description: 'まず解説を読んで、\nクイズで確認しよう！\nふりがな付きで読みやすい',
      color1: Color(0xFF43A047),
      color2: Color(0xFF2E7D32),
    ),
    _OnboardingPage(
      emoji: '⚡',
      title: 'デイリーチャレンジ',
      description: '毎日3問チャレンジして\nコインをゲット！\nストリークを続けよう',
      color1: Color(0xFFF57C00),
      color2: Color(0xFFE65100),
    ),
    _OnboardingPage(
      emoji: '🐣',
      title: '博士キャラを育てよう',
      description: 'たくさん問題を解くと\n博士キャラがレベルアップ！\n理科マスターを目指せ！',
      color1: Color(0xFF8E24AA),
      color2: Color(0xFF6A1B9A),
    ),
    _OnboardingPage(
      emoji: '🚀',
      title: 'さあ、はじめよう！',
      description: '14日間は全コンテンツ\n無料で使えます。\nプロフィールを作ってスタート！',
      color1: Color(0xFFE53935),
      color2: Color(0xFFC62828),
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/profile-create');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _buildPage(_pages[i]),
          ),
          // ドットインジケーター
          Positioned(
            bottom: 100,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: _currentPage == i ? 1 : 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),
          // ボタン
          Positioned(
            bottom: 32, left: 24, right: 24,
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pageCtrl.previousPage(
                          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('もどる'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _currentPage < _pages.length - 1
                        ? () => _pageCtrl.nextPage(
                            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                        : _finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _pages[_currentPage].color1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'つぎへ' : 'はじめる！',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // スキップ
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: 48, right: 20,
              child: TextButton(
                onPressed: _finish,
                child: const Text('スキップ', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [page.color1, page.color2],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(page.emoji, style: const TextStyle(fontSize: 72))),
                ),
                const SizedBox(height: 40),
                Text(page.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                Text(page.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.7)),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String description;
  final Color color1;
  final Color color2;
  const _OnboardingPage({
    required this.emoji, required this.title, required this.description,
    required this.color1, required this.color2,
  });
}
