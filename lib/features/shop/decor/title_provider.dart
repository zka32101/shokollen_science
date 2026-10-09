import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart' show inventoryProvider;
import '../../progress/providers/daily_mystery_provider.dart' show sharedPreferencesProvider;
import '../../progress/providers/user_progress_provider.dart';
import 'title_items.dart';

const _keyTitle = 'decor_title';

/// いま「つけている」称号ID。何もつけていなければ null。
class TitleNotifier extends Notifier<String?> {
  @override
  String? build() => ref.read(sharedPreferencesProvider).getString(_keyTitle);

  Future<void> select(String? id) async {
    state = id;
    final p = ref.read(sharedPreferencesProvider);
    if (id == null) {
      await p.remove(_keyTitle);
    } else {
      await p.setString(_keyTitle, id);
    }
  }
}

final selectedTitleProvider = NotifierProvider<TitleNotifier, String?>(TitleNotifier.new);

/// 既存の進捗からしょうごう判定用の値を作る。
final titleProgressProvider = Provider<TitleProgress>((ref) {
  final p = ref.watch(userProgressProvider).value;
  if (p == null) return const TitleProgress();
  return TitleProgress(badges: p.earnedBadgeIds.length, streakDays: p.streakDays, cleared: p.clearedCount);
});

/// 解放済みのものだけに絞った「いまの称号」。未解放・知らないIDは null。
final activeTitleProvider = Provider<TitleItem?>((ref) {
  final t = titleItemById(ref.watch(selectedTitleProvider));
  if (t == null) return null;
  final ok = isTitleUnlocked(t, owned: ref.watch(inventoryProvider), progress: ref.watch(titleProgressProvider));
  return ok ? t : null;
});
