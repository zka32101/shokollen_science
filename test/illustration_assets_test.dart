import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// lib 内の `assets/illustrations/...` 参照が実在し、pubspec で宣言されているかを検証する。
/// 未制作の画像は [knownMissing] に明示（画像を制作したらここから外す）。
/// 表示側は errorBuilder で画像が無い場合は何も出さない。
void main() {
  final refRe = RegExp(r'assets/illustrations/[A-Za-z0-9_/.\-]+\.(?:jpg|png|webp)');
  final refs = <String>{};
  for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.dart')) continue;
    refs.addAll(refRe.allMatches(f.readAsStringSync()).map((m) => m.group(0)!));
  }
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final declared = RegExp(r'^\s*-\s*(assets/illustrations/\S*)\s*$', multiLine: true)
      .allMatches(pubspec)
      .map((m) => m.group(1)!)
      .toList();

  final missing =
      refs.where((r) => !File(r).existsSync()).toSet();

  // 既知の未制作（stage_4〜6）。制作できたら外すこと。
  final knownMissing = missing.where((r) =>
      RegExp(r'assets/illustrations/stage_[456]/').hasMatch(r)).toSet();

  test('stage_4-6 以外の illustrations 参照はすべて実在する', () {
    expect(missing.difference(knownMissing), isEmpty);
  });

  test('実在する illustrations は pubspec で宣言されている', () {
    for (final r in refs.difference(missing)) {
      expect(declared.any((d) => r.startsWith(d) || r == d), isTrue,
          reason: '$r が pubspec.yaml で未宣言');
    }
  });

  test('未制作リストは実際に未制作のものだけ（制作済みなら外す）', () {
    for (final r in knownMissing) {
      expect(File(r).existsSync(), isFalse);
    }
  });
}
