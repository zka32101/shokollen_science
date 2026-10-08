import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/widgets/startup_splash.dart';

void main() {
  testWidgets('起動画面: 白背景・アプリアイコン/シリーズロゴ/組織ロゴの3つが縦に並ぶ', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StartupSplash()));
    await tester.pump();
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFFFFFFF));
    final icon = find.byKey(const ValueKey('splash_app_icon'));
    final series = find.byKey(const ValueKey('splash_series_logo'));
    final org = find.byKey(const ValueKey('splash_company_logo'));
    expect(icon, findsOneWidget);
    expect(series, findsOneWidget);
    expect(org, findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final assets = tester
        .widgetList<Image>(find.byType(Image))
        .map((i) => (i.image as AssetImage).assetName)
        .toSet();
    expect(assets, containsAll([
      'assets/branding/app_icon.png',
      'assets/branding/series_logo.png',
      'assets/branding/yourwish_logo.png',
    ]));
    expect(tester.getCenter(series).dy, greaterThan(tester.getCenter(icon).dy));
    expect(tester.getCenter(org).dy, greaterThan(tester.getCenter(series).dy));
    expect(tester.takeException(), isNull);
  });
}
