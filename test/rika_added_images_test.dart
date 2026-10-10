import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/data/seeds/creatures.dart';
import 'package:shokollen_science/data/seeds/learn_content_data.dart';

void main() {
  test('学習画面の image 要素の画像はすべて実在する', () {
    var count = 0;
    for (final sections in learnContentData.values) {
      for (final sec in sections) {
        for (final el in (sec['sections'] as List)) {
          if (el['type'] == 'image') {
            count++;
            expect(File(el['imagePath'] as String).existsSync(), isTrue,
                reason: el['imagePath'] as String);
          }
        }
      }
    }
    expect(count, greaterThanOrEqualTo(11));
  });

  test('追加した10枚の説明画像が学習データに含まれる', () {
    final all = learnContentData.toString();
    for (final n in [
      'stage_3_002_flower', 'stage_3_003_butterfly_life',
      'stage_3_005_magnet_items', 'stage_3_007_shadow', 'stage_3_010_bulb',
      'stage_3_012_grasshopper', 'stage_4_005_expansion',
      'stage_5_001_pollination', 'stage_5_003_medaka_tank',
      'stage_5_005_meander',
    ]) {
      expect(all.contains(n), isTrue, reason: n);
    }
  });

  test('図鑑の全生き物に画像があり id が重複しない', () {
    final ids = <String>{};
    for (final c in creaturesData) {
      final id = c['id'] as String;
      expect(ids.add(id), isTrue, reason: 'dup $id');
      expect(File('assets/illustrations/creatures/$id.jpg').existsSync(), isTrue,
          reason: id);
    }
    expect(ids, containsAll(['creature_017', 'creature_018', 'creature_019']));
  });
}
