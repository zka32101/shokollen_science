import 'package:flutter/services.dart';

/// キャラクターのレベル別画像（Lv.2表情 / Lv.3ポーズ / MAX）の存在を管理する。
///
/// 命名規則（pubspec に `assets/character_levels/` が登録済み）:
///  - Lv.2 表情: assets/character_levels/<id>_lv2_<1-3>.png
///  - Lv.3 ポーズ: assets/character_levels/<id>_lv3_<1-3>.png
///  - MAX: assets/character_levels/<id>_lvmax.png
/// 画像ファイルを置くだけで反映される（コード変更不要）。
class CharacterLevelAssets {
  final Set<String> _assets;
  const CharacterLevelAssets(this._assets);

  static const empty = CharacterLevelAssets({});

  static Future<CharacterLevelAssets> load([AssetBundle? bundle]) async {
    try {
      final m = await AssetManifest.loadFromAssetBundle(bundle ?? rootBundle);
      return CharacterLevelAssets(m.listAssets().toSet());
    } catch (_) {
      return empty;
    }
  }

  static String _dir(String id) => 'assets/character_levels/$id';

  List<String> _existing(Iterable<String> paths) =>
      paths.where(_assets.contains).toList();

  List<String> expressions(String id) =>
      _existing([for (var i = 1; i <= 3; i++) '${_dir(id)}_lv2_$i.png']);

  List<String> poses(String id) =>
      _existing([for (var i = 1; i <= 3; i++) '${_dir(id)}_lv3_$i.png']);

  String? maxImage(String id) {
    final p = '${_dir(id)}_lvmax.png';
    return _assets.contains(p) ? p : null;
  }
}
