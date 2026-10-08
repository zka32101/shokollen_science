import 'package:flutter/material.dart';

/// 小学コレ！シリーズ共通の起動画面（白背景・縦一枚）。
///
/// 中央に教科アプリアイコン+読み込み表示、下寄りにシリーズロゴ、最下部に組織ロゴ。
/// 起動中の画面（初期化前）とアプリ内スプラッシュの両方でこのウィジェットを使い、
/// 見た目を1枚に揃える。ダークモードでも白背景固定。
class BrandedSplash extends StatelessWidget {
  const BrandedSplash({super.key});

  static const Color splashBackground = Color(0xFFFFFFFF);
  static const Color progressColor = Color(0xFF3498DB);
  static const String iconAsset = 'assets/branding/app_icon.png';
  static const String seriesLogoAsset = 'assets/branding/series_logo.png';
  static const String orgLogoAsset = 'assets/branding/yourwish_logo.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: splashBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(iconAsset,
                          key: const ValueKey('splash_app_icon'),
                          width: 168,
                          height: 168,
                          fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: progressColor),
                    ),
                  ],
                ),
              ),
            ),
            Image.asset(seriesLogoAsset,
                key: const ValueKey('splash_series_logo'),
                width: 260,
                fit: BoxFit.contain),
            const SizedBox(height: 16),
            Image.asset(orgLogoAsset,
                key: const ValueKey('splash_company_logo'),
                height: 84,
                fit: BoxFit.contain),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
