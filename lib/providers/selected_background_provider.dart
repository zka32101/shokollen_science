import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// せっていから選んだ背景アイテムID（購入済みのもののみ選択可）。
/// nullはデフォルト背景（購入前の状態）。
class SelectedBackgroundNotifier extends Notifier<String?> {
  static const _prefsKey = 'selected_background_id';

  @override
  String? build() {
    Future.microtask(load);
    return null;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_prefsKey);
  }

  Future<void> select(String? backgroundId) async {
    state = backgroundId;
    final prefs = await SharedPreferences.getInstance();
    if (backgroundId == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, backgroundId);
    }
  }
}

final selectedBackgroundProvider =
    NotifierProvider<SelectedBackgroundNotifier, String?>(
  SelectedBackgroundNotifier.new,
);
