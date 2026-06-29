// ④ 今夜の空: 月別の天体イベントと観察ガイド（静的データ）

class SkyEvent {
  final String id;
  final String title;
  final String description;
  final String observationTip;
  final String emoji;
  final int month;
  final String? relatedStageId;
  final double rarity; // 0.0-1.0 珍しさ

  const SkyEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.observationTip,
    required this.emoji,
    required this.month,
    this.relatedStageId,
    required this.rarity,
  });
}

// 月相計算（簡易版）
double getMoonPhase(DateTime date) {
  // 2000年1月6日 = 新月（JD 2451549.5）
  const referenceNewMoon = 2451549.5;
  final jd = date.millisecondsSinceEpoch / 86400000.0 + 2440587.5;
  final daysSinceNew = (jd - referenceNewMoon) % 29.53058867;
  return daysSinceNew / 29.53058867;
}

String getMoonPhaseName(double phase) {
  if (phase < 0.03 || phase > 0.97) return '🌑 新月';
  if (phase < 0.22) return '🌒 三日月';
  if (phase < 0.28) return '🌓 上弦の月';
  if (phase < 0.47) return '🌔 十三夜ごろ';
  if (phase < 0.53) return '🌕 満月';
  if (phase < 0.72) return '🌖 十六夜ごろ';
  if (phase < 0.78) return '🌗 下弦の月';
  return '🌘 有明月';
}

String getMoonPhaseDescription(double phase) {
  if (phase < 0.03 || phase > 0.97) {
    return '今夜は新月。月は見えないけど、星がたくさん見えるチャンス！';
  }
  if (phase < 0.28) return '細い月が西の空に見えるよ。日没後すぐに探してみよう！';
  if (phase < 0.53) return '明るい月が夜空を照らしている。南の空を見上げてみよう！';
  if (phase < 0.78) return '満月を過ぎた月が夜中に昇ってくるよ。東の空を見てみよう！';
  return '夜明け前の空に月が見えるよ。早起きしてチャレンジ！';
}

// 月別の主要天文イベント
List<SkyEvent> getMonthEvents(int month) {
  return skyEvents.where((e) => e.month == month).toList();
}

SkyEvent getMainEventForMonth(int month) {
  final events = getMonthEvents(month);
  if (events.isEmpty) return skyEvents.first;
  events.sort((a, b) => b.rarity.compareTo(a.rarity));
  return events.first;
}

final skyEvents = <SkyEvent>[
  // 1月
  SkyEvent(
    id: 'sky_01_orion',
    title: 'オリオン座が最も高く輝く季節！',
    description: '1月はオリオン座が南の空に高く見える絶好のシーズン。3つ並んだ星（三ツ星）を探してみよう！',
    observationTip: '南の空を見上げて、横に3つ並んだ明るい星を探そう。その左上の赤い星がベテルギウス（赤色超巨星）だよ。',
    emoji: '⭐',
    month: 1,
    relatedStageId: 'stage_5_007',
    rarity: 0.8,
  ),
  SkyEvent(
    id: 'sky_01_jupiter',
    title: '木星が夜空に輝いている',
    description: '双眼鏡があれば木星の縞模様と4つの大きな衛星（ガリレオ衛星）が見えるかも！',
    observationTip: 'とても明るく輝く星状の点。点滅しないのが惑星の特徴だよ。',
    emoji: '🪐',
    month: 1,
    relatedStageId: 'stage_5_007',
    rarity: 0.7,
  ),

  // 2月
  SkyEvent(
    id: 'sky_02_sirius',
    title: 'シリウスが最も高く見える！',
    description: '全天で最も明るい恒星「シリウス」が南の空に輝く。青白い光が特徴！',
    observationTip: 'オリオン座の三ツ星の延長線上に最も明るく輝く星がシリウス。-1.5等星でとても明るいよ。',
    emoji: '💫',
    month: 2,
    relatedStageId: 'stage_5_007',
    rarity: 0.8,
  ),

  // 3月
  SkyEvent(
    id: 'sky_03_spring_equinox',
    title: '春分の日：昼と夜がほぼ同じ長さ',
    description: '3月20日前後が春分の日。東から太陽が昇り、真西に沈む。昼と夜の長さが同じ！',
    observationTip: '春分の日の日の出・日の入りの方角を方位磁針で測ってみよう。ほぼ真東・真西になるはず！',
    emoji: '🌸',
    month: 3,
    relatedStageId: 'stage_3_003',
    rarity: 0.7,
  ),
  SkyEvent(
    id: 'sky_03_leo',
    title: 'しし座が昇ってくる',
    description: '春の空にしし座が見えるようになる。大きな疑問符（？）のような形を探してみよう。',
    observationTip: 'しし座の目印は「大鎌（おおがま）」と呼ばれる逆向きの疑問符の形。一番明るい星はレグルス（1等星）。',
    emoji: '🦁',
    month: 3,
    relatedStageId: 'stage_5_007',
    rarity: 0.6,
  ),

  // 4月
  SkyEvent(
    id: 'sky_04_lyrid',
    title: 'しぶんぎ座流星群（4/21-22）',
    description: '4月21-22日ごろが極大期。空が暗い場所では1時間に10-20個見えることも！',
    observationTip: '夜中から夜明け前が見やすい。ヘルクレス座方向から流れ星が出てくるよ。防寒対策をしてゆっくり観察しよう。',
    emoji: '🌠',
    month: 4,
    relatedStageId: 'stage_5_007',
    rarity: 0.9,
  ),

  // 5月
  SkyEvent(
    id: 'sky_05_spring_triangle',
    title: '春の大三角が輝く',
    description: 'アークトゥルス・スピカ・デネボラで作る「春の大三角」が南の空に！',
    observationTip: 'まず北斗七星を見つけ、柄の曲線を南へのばすとオレンジ色のアークトゥルスが見える。',
    emoji: '🔺',
    month: 5,
    relatedStageId: 'stage_5_007',
    rarity: 0.65,
  ),

  // 6月
  SkyEvent(
    id: 'sky_06_summer_solstice',
    title: '夏至（6/21ごろ）：一年で一番昼が長い日',
    description: '太陽が一番高く昇る日。正午の影が一年で最も短くなるよ！',
    observationTip: '正午に棒を立てて影の長さを測ってみよう。冬至と比べると2倍以上の差があるよ。',
    emoji: '☀️',
    month: 6,
    relatedStageId: 'stage_3_003',
    rarity: 0.7,
  ),
  SkyEvent(
    id: 'sky_06_scorpius',
    title: 'さそり座が南の空に昇ってくる',
    description: 'S字形のさそり座が梅雨の晴れ間に見えることがある。アンタレス（赤い星）を探そう。',
    observationTip: '南の低い空を見よう。赤みがかった明るい星（アンタレス）がさそり座の心臓部！',
    emoji: '🦂',
    month: 6,
    relatedStageId: 'stage_5_007',
    rarity: 0.7,
  ),

  // 7月
  SkyEvent(
    id: 'sky_07_tanabata',
    title: '七夕：織姫と彦星が最接近',
    description: 'ベガ（織姫星）とアルタイル（彦星）が天の川をはさんで輝く！',
    observationTip: '南の高い空に輝く明るい白い星がベガ（こと座）。やや南東にアルタイル（わし座）。その間が天の川。',
    emoji: '🎋',
    month: 7,
    relatedStageId: 'stage_5_007',
    rarity: 0.85,
  ),
  SkyEvent(
    id: 'sky_07_mars',
    title: '夏の夜空に火星が輝く',
    description: '赤っぽく輝く惑星・火星が見える季節。点滅しない赤い光を探してみよう。',
    observationTip: '星は点滅する（きらきら）が惑星は点滅しない（じーっと輝く）。これが惑星の見分け方！',
    emoji: '🔴',
    month: 7,
    relatedStageId: 'stage_5_007',
    rarity: 0.6,
  ),

  // 8月
  SkyEvent(
    id: 'sky_08_perseid',
    title: 'ペルセウス座流星群（8/12-13）',
    description: '年間最大の流星群！ピーク時は1時間に60個以上の流れ星が見えることも！！',
    observationTip: '8月12-13日の夜中から夜明け前が最多。ペルセウス座（北東の空）から放射状に流れてくるよ。光害の少ない場所で観察しよう！',
    emoji: '🌠',
    month: 8,
    relatedStageId: 'stage_5_007',
    rarity: 1.0,
  ),

  // 9月
  SkyEvent(
    id: 'sky_09_harvest_moon',
    title: '中秋の名月（十五夜）',
    description: '9月の満月は「中秋の名月」。一年で最も美しいとされる月を楽しもう！',
    observationTip: '東から昇ってくる満月を観察しよう。月のクレーターや「月のうさぎ」の模様を探してみて。',
    emoji: '🌕',
    month: 9,
    relatedStageId: 'stage_5_007',
    rarity: 0.9,
  ),

  // 10月
  SkyEvent(
    id: 'sky_10_orionid',
    title: 'オリオン座流星群（10/21ごろ）',
    description: 'ハレー彗星の残した塵による流星群。1時間に20個程度見える。',
    observationTip: 'オリオン座の方向（東〜南東）から流れ星が出てくるよ。20時以降から深夜が見やすい。',
    emoji: '☄️',
    month: 10,
    relatedStageId: 'stage_5_007',
    rarity: 0.8,
  ),

  // 11月
  SkyEvent(
    id: 'sky_11_leonid',
    title: 'しし座流星群（11/17ごろ）',
    description: '33年周期で大出現することで有名。今年の出現数は気象庁で確認しよう。',
    observationTip: '深夜2時以降が見やすい。しし座のカマ型の部分から流れてくるよ。',
    emoji: '🦁',
    month: 11,
    relatedStageId: 'stage_5_007',
    rarity: 0.75,
  ),

  // 12月
  SkyEvent(
    id: 'sky_12_geminid',
    title: 'ふたご座流星群（12/13-14）★年間最多',
    description: '年間最多の流星群！1時間に100個以上も見えることがある。防寒して観察しよう！',
    observationTip: '12月13日夜から14日朝が極大期。ふたご座（南の高い空）から流れ星が出てくる。1年の中で最も信頼できる流星群！',
    emoji: '🌠',
    month: 12,
    relatedStageId: 'stage_5_007',
    rarity: 1.0,
  ),
  SkyEvent(
    id: 'sky_12_winter_solstice',
    title: '冬至（12/22ごろ）：一年で一番夜が長い日',
    description: '太陽が一番低くなる日。日の出が遅く・日の入りが早い。かぼちゃ食べてゆず湯に入ろう！',
    observationTip: '冬至の翌日から少しずつ昼が長くなっていくよ。日の出・日の入りの時刻を毎日記録してみよう！',
    emoji: '❄️',
    month: 12,
    relatedStageId: 'stage_3_003',
    rarity: 0.7,
  ),
];
