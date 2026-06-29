import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import '../shared/constants/app_colors.dart';

class AppTheme {
  /// ライトテーマ: shared_core の buildAppTheme() に委譲
  static ThemeData get lightTheme => buildAppTheme(
        primaryColor: AppColors.sciencePrimary,
        secondaryColor: AppColors.scienceSecondary,
        bgColor: AppColors.bgGray,
      );

  /// ダークテーマ: 理科専用（深夜学習に配慮した濃紺）
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: false,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7EB8F7),
          secondary: Color(0xFF5C9BD4),
          surface: Color(0xFF1E1E2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF12121E),
        cardColor: const Color(0xFF1E1E2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );
}
