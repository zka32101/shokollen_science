import 'package:flutter/material.dart';

/// 小学コレ！シリーズ テーマカラー
class AppColors {
  // ============== 理科テーマカラー ==============
  static const sciencePrimary = Color(0xFF3498DB);    // メインブルー
  static const scienceSecondary = Color(0xFF2874A6);  // ダークブルー
  static const scienceLight = Color(0xFFEBF5FB);      // 薄いブルー背景

  // ============== シリーズ共通カラー ==============
  static const socialColor = Color(0xFF2ECC71);       // 社会：緑
  static const mathColor = Color(0xFFE74C3C);         // 算数：赤
  static const languageColor = Color(0xFFF39C12);    // 国語：オレンジ
  static const scienceColor = Color(0xFF3498DB);      // 理科：青
  static const programmingColor = Color(0xFF9B59B6);  // プログラミング：紫
  static const moralColor = Color(0xFF1ABC9C);        // 道徳：ティール

  // ============== 汎用カラー ==============
  static const bgGray = Color(0xFFF5F5F5);
  static const textDark = Color(0xFF333333);
  static const textGray = Color(0xFF666666);
  static const borderGray = Color(0xFFE0E0E0);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // ============== ステータスカラー ==============
  static const success = Color(0xFF27AE60);
  static const error = Color(0xFFE74C3C);
  static const warning = Color(0xFFF39C12);
  static const info = Color(0xFF3498DB);

  // ============== グラデーション ==============
  static const LinearGradient scienceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3498DB), Color(0xFF2874A6)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
  );

  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC0C0C0), Color(0xFF808080)],
  );

  static const LinearGradient bronzeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCD7F32), Color(0xFF8B4513)],
  );
}
