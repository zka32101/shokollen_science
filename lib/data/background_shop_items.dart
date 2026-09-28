import 'package:flutter/material.dart';

/// 購入した背景アイテムIDから実際に表示するグラデーションへのマッピング。
/// ショップの `bg_*` アイテムIDと対応させる（shop_screen.dart の
/// _rikaExchangeItems / _rikaSeasonalItems と同じID）。
const Map<String, List<Color>> kBackgroundGradients = {
  'bg_space': [Color(0xFF1A1A3E), Color(0xFF4A3F8F)],
  'bg_forest': [Color(0xFF2E7D32), Color(0xFF66BB6A)],
  'bg_lab': [Color(0xFF37474F), Color(0xFF78909C)],
  'bg_spring_flowers': [Color(0xFFFFC1E3), Color(0xFFFF8FB1)],
  'bg_ocean': [Color(0xFF006064), Color(0xFF00ACC1)],
  'bg_autumn_leaves': [Color(0xFFBF360C), Color(0xFFFF8A65)],
  'bg_snow': [Color(0xFF90A4AE), Color(0xFFECEFF1)],
};
