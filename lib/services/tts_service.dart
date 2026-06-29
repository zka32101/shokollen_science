import 'package:flutter_tts/flutter_tts.dart';

/// テキスト読み上げサービス
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.85);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  /// ふりがなマークアップを除去して読み上げ
  Future<void> speak(String text) async {
    await _init();
    // {漢字|ふりがな} → ふりがな のみ読む
    final plain = text.replaceAllMapped(
      RegExp(r'\{([^|{}]+)\|([^}]+)\}'),
      (m) => m.group(2)!,
    );
    await _tts.speak(plain);
  }

  Future<void> stop() async => _tts.stop();
}

final ttsService = TtsService();
