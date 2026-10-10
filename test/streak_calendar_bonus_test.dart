import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/features/progress/study_dates.dart';
import 'package:shokollen_science/reward_assets.dart';
import 'package:shokollen_science/widgets/streak_calendar.dart';

void main() {
  test('bonusStickerAssets boundaries', () {
    expect(
        bonusStickerAssets(
            firstAttempt: false, personalBest: false, firstPerfect: false),
        isEmpty);
    expect(
        bonusStickerAssets(
            firstAttempt: true, personalBest: false, firstPerfect: false),
        ['assets/reward/sticker_rocket.webp']);
    expect(
        bonusStickerAssets(
            firstAttempt: true, personalBest: true, firstPerfect: true),
        hasLength(2));
    expect(
        bonusStickerAssets(
            firstAttempt: false, personalBest: true, firstPerfect: true),
        ['assets/reward/sticker_trophy_blue.webp',
          'assets/reward/sticker_rainbow_star.webp']);
  });

  test('assets exist', () {
    for (final f in [
      'calendar_frame', 'stamp_ring_rainbow', 'stamp_coin', 'sticker_rocket',
      'sticker_trophy_blue', 'sticker_rainbow_star'
    ]) {
      expect(File('assets/reward/$f.webp').existsSync(), isTrue, reason: f);
    }
  });

  test('study dates pure functions', () {
    expect(backfillStudyDates(3, '2026-03-01'),
        ['2026-02-27', '2026-02-28', '2026-03-01']);
    expect(backfillStudyDates(0, '2026-03-01'), isEmpty);
    expect(addStudyDate(['2026-03-01'], '2026-03-01'), ['2026-03-01']);
    expect(addStudyDate(['2020-01-01', '2026-03-01'], '2026-03-02'),
        ['2026-03-01', '2026-03-02']);
  });

  testWidgets('StreakCalendar no overflow at 320px', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final days = {
      for (var i = 1; i <= 31; i++) DateTime(2026, 3, i),
    };
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: StreakCalendar(studiedDays: days, month: DateTime(2026, 3)),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.text('31'), findsOneWidget);
  });
}
