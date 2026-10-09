import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/features/progress/models/badge_model.dart';
import 'package:shokollen_science/features/progress/views/badge_earned_dialog.dart';

void main() {
  for (final size in [const Size(320, 480), const Size(411, 800)]) {
    testWidgets('達成演出つきダイアログがoverflowしない ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (c) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                  context: c,
                  builder: (_) =>
                      BadgeEarnedDialog(badges: allBadges.take(3).toList())),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('おめでとう！'), findsOneWidget);
      expect(find.text('次のバッジを見る →'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('次のバッジを見る →'));
      await tester.pump();
      await tester.tap(find.text('次のバッジを見る →'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
    });
  }
}
