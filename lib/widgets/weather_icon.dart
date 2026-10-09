import 'package:flutter/material.dart';
import 'package:shokollen_science/widgets/ukalab_emoji.dart';

/// 天気・月の絵文字を、専用アイコン画像に置き換えて表示する。
/// 対応が無い絵文字は [UkalabEmoji]（従来表示）にフォールバックする。
class WeatherIcon extends StatelessWidget {
  const WeatherIcon(this.emoji, {super.key, this.size = 24});

  final String emoji;
  final double size;

  static const _map = <String, String>{
    '☀': 'sunny',
    '🌞': 'sunny',
    '☁': 'cloudy',
    '⛅': 'partly_cloudy',
    '🌤': 'partly_cloudy',
    '🌥': 'cloudy',
    '🌧': 'rainy',
    '🌦': 'rainy',
    '☔': 'rainy',
    '❄': 'snowy',
    '🌨': 'snowy',
    '⛈': 'thunder',
    '🌩': 'thunder',
    '⚡': 'thunder',
    '🌫': 'fog',
    '🌪': 'typhoon',
    '🌀': 'typhoon',
    '🌈': 'rainbow',
    '💨': 'windy',
    '🌑': 'moon_0_new_moon',
    '🌒': 'moon_1_waxing_crescent',
    '🌓': 'moon_2_first_quarter',
    '🌔': 'moon_3_waxing_gibbous',
    '🌕': 'moon_4_full_moon',
    '🌖': 'moon_5_waning_gibbous',
    '🌗': 'moon_6_last_quarter',
    '🌘': 'moon_7_waning_crescent',
  };

  /// 絵文字に対応するアセット名（無ければ null）。異体字セレクタは無視する。
  static String? assetNameFor(String emoji) =>
      _map[emoji.replaceAll('️', '')];

  @override
  Widget build(BuildContext context) {
    final name = assetNameFor(emoji);
    if (name == null) return UkalabEmoji(emoji, size: size);
    return Image.asset(
      'assets/icons/weather/$name.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => UkalabEmoji(emoji, size: size),
    );
  }
}
