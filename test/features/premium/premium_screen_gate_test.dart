import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shokollen_science/features/premium/views/premium_screen.dart';
import 'package:shokollen_science/widgets/parental_gate.dart';

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
    SharedPreferences.setMockInitialValues({});
    ParentalGateLockout.reset();
  });

  Future<void> pump(WidgetTester tester) async {
    // 料金プランが画面内に入る縦長の画面にする。
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: PremiumScreen()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('購入ボタンを押すと保護者ゲートが出て、「やめる」では購入処理に進まない', (tester) async {
    await pump(tester);

    await tester.tap(find.text('月額プラン'));
    await tester.pumpAndSettle();
    expect(find.text('🔒 保護者の方へ確認'), findsOneWidget);

    await tester.tap(find.text('やめる'));
    await tester.pumpAndSettle();
    expect(find.text('🔒 保護者の方へ確認'), findsNothing);
    // 購入処理に進んでいれば、設定前の案内メッセージが出る。
    expect(find.textContaining('購入機能を準備中'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('年額プランでも、ゲートが出る', (tester) async {
    await pump(tester);
    await tester.tap(find.text('年額プラン'));
    await tester.pumpAndSettle();
    expect(find.text('🔒 保護者の方へ確認'), findsOneWidget);
  });

  testWidgets('間違えると購入処理に進まない', (tester) async {
    await pump(tester);
    await tester.tap(find.text('月額プラン'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '${_answer(tester) + 1}');
    await tester.tap(find.text('つぎへ'));
    await tester.pumpAndSettle();
    expect(find.textContaining('答えが違います'), findsOneWidget);
    expect(find.textContaining('購入機能を準備中'), findsNothing);
  });

  testWidgets('ゲートに正解すると、購入処理に進む', (tester) async {
    await pump(tester);
    await tester.tap(find.text('月額プラン'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '${_answer(tester)}');
    await tester.tap(find.text('つぎへ'));
    await tester.pumpAndSettle();
    expect(find.text('🔒 保護者の方へ確認'), findsNothing);
    // テストでは RevenueCat が未設定のため、購入処理に進むとこの案内が出る。
    expect(find.textContaining('購入機能を準備中'), findsOneWidget);
  });
}
