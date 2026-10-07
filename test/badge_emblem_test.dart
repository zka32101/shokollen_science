import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/features/progress/models/badge_model.dart';
import 'package:shokollen_science/widgets/badge_emblem.dart';

void main() {
  test('理科の全バッジに共通意匠の対応があり、画像ファイルが存在する', () {
    expect(allBadges.length, 24);
    for (final b in allBadges) {
      final name = BadgeEmblem.emblemOf(b.id);
      expect(name, isNotNull, reason: b.id);
      expect(File('assets/badges/badge_$name.webp').existsSync(), true, reason: '${b.id} -> $name');
    }
  });

  testWidgets('対応のあるバッジは画像、ないバッジは絵文字で出る', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(children: [
          BadgeEmblem(badgeId: 'streak_3', fallbackEmoji: '🔥'),
          BadgeEmblem(badgeId: 'unknown_badge', fallbackEmoji: '🔥'),
        ]),
      ),
    ));
    await tester.pump();
    expect(find.byType(Image), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
