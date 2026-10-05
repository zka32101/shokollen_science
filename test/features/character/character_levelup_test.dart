import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shokollen_science/data/rika_characters.dart';
import 'package:shokollen_science/features/character/character_level_assets.dart';
import 'package:shokollen_science/providers/character_provider.dart';

ProviderContainer _container() => ProviderContainer(overrides: [
      characterStateProvider.overrideWith(CharacterNotifier.new),
    ]);

Future<void> _ready(ProviderContainer c, {int coins = 0, int cleared = 0}) async {
  c.read(characterStateProvider); // build
  await Future<void>.delayed(const Duration(milliseconds: 50));
  await c.read(coinProvider.notifier).load();
  if (coins > 0) await c.read(coinProvider.notifier).addCoins(coins);
  await c.read(characterStateProvider.notifier).checkUnlocks(cleared);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('16体・分野が交互・画像ファイルが存在する', () {
    expect(kRikaCharacters.length, 16);
    final fields = ['生物', '物質', 'エネルギー', '地球・宇宙'];
    const bio = {'happakko', 'mushimushi', 'mizukko', 'hitohito'};
    const mat = {'mizubunshi', 'koori', 'jouki', 'dorodoro'};
    const ene = {'hikari', 'onpa', 'denki', 'jishaku'};
    String f(String id) =>
        bio.contains(id) ? fields[0] : mat.contains(id) ? fields[1] : ene.contains(id) ? fields[2] : fields[3];
    for (var i = 0; i < 16; i++) {
      expect(f(kRikaCharacters[i].id), fields[i % 4]);
      expect(File(kRikaCharacters[i].imageAsset!).existsSync(), true);
      for (var n = 1; n <= 3; n++) {
        expect(File('assets/character_levels/${kRikaCharacters[i].id}_lv2_$n.png').existsSync(), true);
      }
    }
    expect(kRikaCharacters.first.unlockAt, 0);
  });

  test('コスト表 50/100/200/500', () {
    expect(kLevelUpCost, {2: 50, 3: 100, 4: 200, 5: 500});
  });

  test('残高不足ではレベルが上がらずコインも減らない', () async {
    SharedPreferences.setMockInitialValues({});
    final c = _container();
    await _ready(c, coins: 49);
    final err = await c.read(characterStateProvider.notifier).levelUp('happakko');
    expect(err, contains('コインが足りません'));
    expect(c.read(characterStateProvider)['happakko']!.level, 1);
    expect(c.read(coinProvider).totalCoins, 49);
  });

  test('Lv5(MAX)まで順に上がり、合計850コイン消費・MAX後はエラー', () async {
    SharedPreferences.setMockInitialValues({});
    final c = _container();
    await _ready(c, coins: 900);
    final n = c.read(characterStateProvider.notifier);
    for (var i = 0; i < 4; i++) {
      expect(await n.levelUp('happakko'), isNull);
    }
    final st = c.read(characterStateProvider)['happakko']!;
    expect(st.level, 5);
    expect(st.isMaxLevel, true);
    expect(st.hasSparkle, true);
    expect(st.levelLabel, contains('MAX'));
    expect(c.read(coinProvider).totalCoins, 50);
    expect(await n.levelUp('happakko'), contains('MAX'));
  });

  test('未解放キャラはレベルアップ不可', () async {
    SharedPreferences.setMockInitialValues({});
    final c = _container();
    await _ready(c, coins: 500);
    expect(await c.read(characterStateProvider.notifier).levelUp('kaseki'),
        isNotNull);
  });

  test('旧キャラIDの保存データが残っていても落ちず、新キャラが解放される', () async {
    SharedPreferences.setMockInitialValues({
      'rika_char_states': jsonEncode({
        'komuji': {'isUnlocked': true, 'level': 3},
        'hanako': {'isUnlocked': true},
      }),
    });
    final c = _container();
    await _ready(c, cleared: 5);
    final s = c.read(characterStateProvider);
    expect(s['happakko']!.isUnlocked, true);
    expect(s['mizubunshi']!.isUnlocked, true);
    expect(s['hikari']!.isUnlocked, true);
    expect(s['taiyou']?.isUnlocked ?? false, false);
    expect(s['happakko']!.level, 1);
  });

  test('レベル別画像の存在チェック（命名規則）', () {
    const a = CharacterLevelAssets({
      'assets/character_levels/happakko_lv2_1.png',
      'assets/character_levels/happakko_lv3_2.png',
      'assets/character_levels/happakko_lvmax.png',
    });
    expect(a.expressions('happakko'), ['assets/character_levels/happakko_lv2_1.png']);
    expect(a.poses('happakko'), ['assets/character_levels/happakko_lv3_2.png']);
    expect(a.maxImage('happakko'), isNotNull);
    expect(a.maxImage('koori'), isNull);
    expect(CharacterLevelAssets.empty.poses('koori'), isEmpty);
  });
}
