import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/widgets/parental_gate.dart';

Future<void> _pumpHost(WidgetTester tester, void Function(bool) onResult) async {
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async => onResult(await requireParentalGate(context)),
          child: const Text('open'),
        ),
      ),
    ),
  ));
}

int _answer(WidgetTester tester) {
  final q = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .firstWhere((d) => d.contains(' × '));
  final m = RegExp(r'(\d+) × (\d+)').firstMatch(q)!;
  return int.parse(m.group(1)!) * int.parse(m.group(2)!);
}

void main() {
  setUp(() {
    ParentalGateLockout.reset();
    ParentalGateLockout.now = DateTime.now;
  });

  test('問題は2桁×1桁のかけ算で、九九の表の範囲では解けない', () {
    final rnd = Random(1);
    for (var i = 0; i < 200; i++) {
      final c = ParentalGateChallenge(rnd);
      expect(c.a, inInclusiveRange(13, 19));
      expect(c.b, inInclusiveRange(6, 9));
      expect(c.check('${c.answer}'), isTrue);
      expect(c.check('${c.answer + 1}'), isFalse);
      expect(c.check('abc'), isFalse);
    }
  });

  testWidgets('正解を入れると通れる', (tester) async {
    bool? result;
    await _pumpHost(tester, (r) => result = r);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '${_answer(tester)}');
    await tester.tap(find.text('つぎへ'));
    await tester.pumpAndSettle();
    expect(result, true);
    expect(find.text('🔒 保護者の方へ確認'), findsNothing);
  });

  testWidgets('やめるでは通れない', (tester) async {
    bool? result;
    await _pumpHost(tester, (r) => result = r);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('やめる'));
    await tester.pumpAndSettle();
    expect(result, false);
  });

  testWidgets('間違えても1・2回目は続けて答えられ、3回目でロックされる', (tester) async {
    bool? result;
    await _pumpHost(tester, (r) => result = r);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    for (var i = 0; i < 2; i++) {
      await tester.enterText(find.byType(TextField), '${_answer(tester) + 1}');
      await tester.tap(find.text('つぎへ'));
      await tester.pumpAndSettle();
      expect(result, isNull, reason: '${i + 1}回目の間違いでは、ゲートは閉じない');
      expect(find.textContaining('答えが違います'), findsOneWidget);
    }
    await tester.enterText(find.byType(TextField), '${_answer(tester) + 1}');
    await tester.tap(find.text('つぎへ'));
    await tester.pumpAndSettle();
    expect(result, false);
    expect(ParentalGateLockout.isLocked, isTrue);

    // ロック中は、問題が出ずに待つよう案内される。
    result = null;
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('🔒 保護者の方へ確認'), findsNothing);
    expect(find.textContaining('しばらくお待ちください'), findsOneWidget);
    await tester.tap(find.text('とじる'));
    await tester.pumpAndSettle();
    expect(result, false);
  });

  test('ロックは60秒たつと解ける', () {
    var t = DateTime(2026, 1, 1, 12);
    ParentalGateLockout.now = () => t;
    ParentalGateLockout.lock();
    expect(ParentalGateLockout.isLocked, isTrue);
    t = t.add(const Duration(seconds: 59));
    expect(ParentalGateLockout.isLocked, isTrue);
    t = t.add(const Duration(seconds: 2));
    expect(ParentalGateLockout.isLocked, isFalse);
  });

  // 小さい画面(360x640dp)でキーボード(300dp)が出ても、「つぎへ」が隠れず押せること。
  testWidgets('小さい画面+キーボード表示中でも「つぎへ」を押して進める', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 640);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    bool? result;
    await _pumpHost(tester, (r) => result = r);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '${_answer(tester)}');
    await tester.pumpAndSettle();

    await tester.tap(find.text('つぎへ'));
    await tester.pumpAndSettle();
    expect(result, true);
    expect(tester.takeException(), isNull, reason: 'レイアウトがはみ出している');
  });
}
