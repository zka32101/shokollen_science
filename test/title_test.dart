import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart' show inventoryProvider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shokollen_science/features/progress/providers/daily_mystery_provider.dart' show sharedPreferencesProvider;
import 'package:shokollen_science/features/shop/decor/title_items.dart';
import 'package:shokollen_science/features/shop/decor/title_provider.dart';
import 'package:shokollen_science/widgets/title_plate.dart';

void main() {
  test('称号は8個・購入5(100〜500コイン)・達成3、IDは重複しない', () {
    expect(kTitleItems.length, 8);
    expect(kTitleItems.where((t) => t.isPurchase).length, 5);
    expect(kTitleItems.where((t) => t.isPurchase).every((t) => t.coinCost >= 100 && t.coinCost <= 500), true);
    expect(kTitleItems.map((t) => t.id).toSet().length, 8);
    expect(titleExchangeItems().length, 5);
    expect(File('assets/title_plate/plate_rika.webp').existsSync(), true);
  });

  test('購入型は所持品、達成型はしきい値で解放される', () {
    const none = TitleProgress();
    final buy = titleItemById('title_jikken')!;
    expect(isTitleUnlocked(buy, owned: {}, progress: none), false);
    expect(isTitleUnlocked(buy, owned: {'title_jikken'}, progress: none), true);

    final badge = titleItemById('title_badge')!;
    expect(isTitleUnlocked(badge, owned: {}, progress: const TitleProgress(badges: 4)), false);
    expect(isTitleUnlocked(badge, owned: {}, progress: const TitleProgress(badges: 5)), true);
    final streak = titleItemById('title_streak')!;
    expect(isTitleUnlocked(streak, owned: {}, progress: const TitleProgress(streakDays: 6)), false);
    expect(isTitleUnlocked(streak, owned: {}, progress: const TitleProgress(streakDays: 7)), true);
    final clear = titleItemById('title_clear')!;
    expect(isTitleUnlocked(clear, owned: {}, progress: const TitleProgress(cleared: 10)), true);
    expect(clear.conditionText, contains('10'));
    expect(titleItemById('nope'), isNull);
  });

  test('未解放の称号を選んでいても activeTitle には出ない/所持で出る', () async {
    SharedPreferences.setMockInitialValues({'decor_title': 'title_hoshi'});
    final p = await SharedPreferences.getInstance();
    final c = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(p)]);
    addTearDown(c.dispose);
    c.read(inventoryProvider);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(c.read(activeTitleProvider), isNull);
    c.read(inventoryProvider.notifier).state = {'title_hoshi'};
    expect(c.read(activeTitleProvider)?.name, 'ほしのかんそくか');
    await c.read(selectedTitleProvider.notifier).select(null);
    expect(c.read(activeTitleProvider), isNull);
    expect(p.getString('decor_title'), isNull);
  });

  testWidgets('TitlePlate は長い名前でも overflow しない', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: Center(child: TitlePlate(name: 'とてもとてもながいしょうごうめい')))));
    expect(find.text('とてもとてもながいしょうごうめい'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
