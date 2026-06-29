// ③ おうちラボ: 週末リアル実験ミッションデータ
// 1年52週分（grade 3-6 をローテーション）

class HomeLabMission {
  final String id;
  final String title;
  final String description;
  final List<String> materials;
  final int grade;
  final int weekOfYear; // 1-52
  final String expectedResult;
  final String sciencePoint;
  final String emoji;

  const HomeLabMission({
    required this.id,
    required this.title,
    required this.description,
    required this.materials,
    required this.grade,
    required this.weekOfYear,
    required this.expectedResult,
    required this.sciencePoint,
    required this.emoji,
  });
}

// 今週のミッション取得（週番号から）
HomeLabMission getTodaysMission() {
  final now = DateTime.now();
  final weekNum = ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7).floor() + 1;
  return getMissionByWeek(weekNum);
}

HomeLabMission getMissionByWeek(int week) {
  final index = (week - 1) % homeLabMissions.length;
  return homeLabMissions[index];
}

final homeLabMissions = <HomeLabMission>[
  // ── 3年生ミッション ──
  HomeLabMission(
    id: 'hl_001',
    title: '磁石で砂鉄を集めよう',
    description: '公園の砂や土に磁石を近づけてみよう。何かくっつくかな？',
    materials: ['磁石', '紙コップ', '公園の砂（一握り）'],
    grade: 3,
    weekOfYear: 1,
    expectedResult: '砂の中の小さな黒い粒（砂鉄）が磁石にくっついてくる',
    sciencePoint: '砂の中には鉄のつぶが含まれていて、磁石に引き寄せられます。これを「砂鉄」というよ。',
    emoji: '🧲',
  ),
  HomeLabMission(
    id: 'hl_002',
    title: '水に浮くものと沈むもの',
    description: '家の中にあるものを水に入れて、浮くか沈むか予想してから実験しよう！',
    materials: ['洗面器または大きめのボウル', '水', '試すもの（消しゴム・木片・石・プラスチックスプーン・金属スプーンなど）'],
    grade: 3,
    weekOfYear: 2,
    expectedResult: '木やプラスチックは浮き、金属や石は沈む',
    sciencePoint: '物が浮くかどうかは「密度」で決まります。水より密度が小さければ浮き、大きければ沈むんだよ。',
    emoji: '🛁',
  ),
  HomeLabMission(
    id: 'hl_003',
    title: '影の方向を記録しよう',
    description: '晴れた日に、外で同じ場所の影を「朝・昼・夕方」に記録しよう',
    materials: ['棒（30cm程度）', '紙', '鉛筆', 'テープ'],
    grade: 3,
    weekOfYear: 3,
    expectedResult: '朝は西向きに長く、昼は短く、夕方は東向きに長くなる',
    sciencePoint: '太陽は東から南を通って西へ動く。影はその反対方向を向くんだよ。',
    emoji: '☀️',
  ),
  HomeLabMission(
    id: 'hl_004',
    title: '輪ゴムでロケットを飛ばせ！',
    description: '折り紙でロケットを作って、輪ゴムで飛ばしてみよう。長い輪ゴムと短い輪ゴムで飛距離は変わるかな？',
    materials: ['折り紙', '輪ゴム（太さ違いで2種類）', '定規'],
    grade: 3,
    weekOfYear: 4,
    expectedResult: '輪ゴムを長くのばすほど遠くへ飛ぶ',
    sciencePoint: '輪ゴムを引き伸ばすほど、弾性エネルギーが大きくなり、飛距離が伸びます。',
    emoji: '🚀',
  ),
  HomeLabMission(
    id: 'hl_005',
    title: '氷を一番早く溶かすのは？',
    description: '製氷皿の氷を取り出して、いろいろな方法で溶かしてみよう。塩・砂糖・温水・扇風機でどれが一番早い？',
    materials: ['氷（4個）', '塩', '砂糖', 'ぬるい水', 'ストップウォッチ'],
    grade: 3,
    weekOfYear: 5,
    expectedResult: '塩水が最も早く溶け、砂糖水・温水・常温の順',
    sciencePoint: '塩を加えると溶ける温度（融点）が下がります。道路に塩をまくのも同じ原理だよ。',
    emoji: '❄️',
  ),
  // ── 4年生ミッション ──
  HomeLabMission(
    id: 'hl_006',
    title: '豆電球回路を作ろう',
    description: '乾電池・豆電球・導線で回路を作ろう。豆電球を2個つなぐと明るさはどう変わる？',
    materials: ['単3乾電池×2', '豆電球×2', 'ソケット×2', '導線（20cm×3本）'],
    grade: 4,
    weekOfYear: 6,
    expectedResult: '直列は明るくなり、並列は明るさが同じで電池が長持ち',
    sciencePoint: '直列では電圧が2倍になり豆電球が明るく輝く。並列では電気を共有するから長持ちするよ。',
    emoji: '💡',
  ),
  HomeLabMission(
    id: 'hl_007',
    title: '温度で水の体積が変わるか調べよう',
    description: 'ペットボトルに水を入れて、温水と冷水に交互に入れてどう変わるか観察しよう',
    materials: ['ペットボトル（500ml）', 'お湯（60℃程度）', '冷水（10℃程度）', 'タオル'],
    grade: 4,
    weekOfYear: 7,
    expectedResult: 'お湯に入れるとふくらみ、冷水に入れるとへこむ',
    sciencePoint: '温めると空気や水が膨張（ぼうちょう）します。冷やすと縮みます。温度で体積が変わるんだよ。',
    emoji: '🌡️',
  ),
  HomeLabMission(
    id: 'hl_008',
    title: '雨水・水道水・川の水の違いを探ろう',
    description: '違う場所の水をコップに集めて、蒸発させた後の残り物を比べてみよう',
    materials: ['透明なガラスコップ×3', '水道水・雨水・川の水'],
    grade: 4,
    weekOfYear: 8,
    expectedResult: '水道水は何も残らない、川の水は細かい汚れが残ることがある',
    sciencePoint: '水道水は浄水場でろ過・殺菌されています。川の水にはミネラルや微生物が含まれています。',
    emoji: '💧',
  ),
  HomeLabMission(
    id: 'hl_009',
    title: '食塩水の結晶を育てよう',
    description: '食塩をたっぷり溶かした水を蒸発させると、きれいな結晶ができるよ！',
    materials: ['食塩', '水', '皿または平らなガラス容器', '放置する場所（窓際）'],
    grade: 4,
    weekOfYear: 9,
    expectedResult: '数日後に立方体の形をした結晶が出てくる',
    sciencePoint: '食塩（塩化ナトリウム）は立方体の構造をしています。水が蒸発するとその形で固まるんだよ。',
    emoji: '🔷',
  ),
  HomeLabMission(
    id: 'hl_010',
    title: '風速計を手作りしよう',
    description: '紙コップ4個で風速計（アネモメーター）を作ろう。ベランダに出して風の強さを記録しよう。',
    materials: ['紙コップ×4', '割り箸×2', 'ストロー', 'ホッチキス', 'テープ'],
    grade: 4,
    weekOfYear: 10,
    expectedResult: '風が吹くと紙コップが回転し、風が強いほど速く回る',
    sciencePoint: '曲面が風の抵抗を受けて回転する仕組みです。気象観測所でも同じ原理の機器を使っています。',
    emoji: '💨',
  ),
  // ── 5年生ミッション ──
  HomeLabMission(
    id: 'hl_011',
    title: '植物の葉を観察しよう（葉脈標本）',
    description: '木の葉を石灰水に1週間つけると、葉脈だけ残ります！',
    materials: ['落ち葉（クスノキやサクラが良い）', '石灰水（少量）', 'ジップロック', '水'],
    grade: 5,
    weekOfYear: 11,
    expectedResult: '葉の細胞が溶けて網目状の葉脈だけが残る',
    sciencePoint: '葉脈は植物の「血管」。水や栄養を葉全体に運ぶ管の集まりです。',
    emoji: '🍃',
  ),
  HomeLabMission(
    id: 'hl_012',
    title: '手作り水フィルターで水を浄化しよう',
    description: '砂・砂利・活性炭（備長炭）を層にして、濁った水をろ過してみよう',
    materials: ['ペットボトル（500ml）', '砂', '砂利', '備長炭（細かく砕いたもの）', '泥水'],
    grade: 5,
    weekOfYear: 12,
    expectedResult: '3層を通過すると水が透明に近くなる',
    sciencePoint: '浄水場でも同じ原理のろ過が行われています。ただしこれだけでは飲料水にならないよ。',
    emoji: '🚰',
  ),
  HomeLabMission(
    id: 'hl_013',
    title: 'ふりこの長さと周期の関係',
    description: '糸と重りでふりこを作り、糸の長さを変えて1往復の時間を計ろう。',
    materials: ['タコ糸（50cm）', '重り（ナット×3）', 'ストップウォッチ', '定規'],
    grade: 5,
    weekOfYear: 13,
    expectedResult: '糸が長いほど1往復の時間が長くなる（重さは無関係）',
    sciencePoint: 'ふりこの周期は糸の長さだけで決まります。重さや振れ幅は関係ないんだよ（ガリレオの発見）。',
    emoji: '⏰',
  ),
  HomeLabMission(
    id: 'hl_014',
    title: '電気を蓄えよう（コンデンサー実験）',
    description: '手回し発電機で豆電球を光らせながら、コンデンサーに電気を貯めてみよう',
    materials: ['手回し発電機（玩具用）', '豆電球', 'コンデンサー（1F程度、工作キット）', '導線'],
    grade: 5,
    weekOfYear: 14,
    expectedResult: 'コンデンサーに充電後、発電機なしでも豆電球が光る',
    sciencePoint: 'コンデンサーは電気を一時的に貯める部品。スマホのバッテリーも電気を貯める仕組みです。',
    emoji: '⚡',
  ),
  HomeLabMission(
    id: 'hl_015',
    title: '種子の発芽条件を調べよう',
    description: '同じ種子（インゲン豆など）を、水あり/なし・光あり/なしの4条件で育ててみよう',
    materials: ['インゲン豆の種×8', 'コットン×4', 'ジップロック×4', '水'],
    grade: 5,
    weekOfYear: 15,
    expectedResult: '水あり+光なしでも発芽する（光は発芽に不要）',
    sciencePoint: '発芽に必要なのは「水・適切な温度・空気」。光は発芽には不要で、成長に必要なんだよ。',
    emoji: '🌱',
  ),
  // ── 6年生ミッション ──
  HomeLabMission(
    id: 'hl_016',
    title: '塩酸（酢）で金属を溶かそう',
    description: '酢（酢酸）は弱い酸。10円玉（銅）を酢に入れてどうなるか観察しよう。',
    materials: ['食酢', '10円玉×2', '透明なコップ×2', '水（比較用）'],
    grade: 6,
    weekOfYear: 16,
    expectedResult: '酢に入れた10円玉が少しずつきれいになる（酸化膜が溶ける）',
    sciencePoint: '酢の成分「酢酸」は弱い酸。表面の酸化膜（黒ずみ）を溶かすんだよ。強酸（塩酸）なら金属そのものが溶けます。',
    emoji: '🧪',
  ),
  HomeLabMission(
    id: 'hl_017',
    title: '紫キャベツで酸・アルカリ判定',
    description: '紫キャベツを煮た汁は万能試薬！酢・重曹・石鹸水の色が変わるよ',
    materials: ['紫キャベツ', '鍋・水', '酢', '重曹水', '石鹸水', '透明コップ×3'],
    grade: 6,
    weekOfYear: 17,
    expectedResult: '酸性（酢）→赤、中性→紫、アルカリ性（重曹・石鹸）→緑・黄',
    sciencePoint: '紫キャベツのアントシアニンという色素がpHで色が変わります。リトマス試験紙と同じ原理だよ。',
    emoji: '🔬',
  ),
  HomeLabMission(
    id: 'hl_018',
    title: '太陽の高さを測ろう（夏至・冬至比較）',
    description: '棒の影の長さで太陽の高さ（高度）を計算してみよう',
    materials: ['1mの棒', '定規', '方位磁針', '記録ノート'],
    grade: 6,
    weekOfYear: 18,
    expectedResult: '南中時（正午前後）が影が最も短く、太陽が最も高い',
    sciencePoint: '太陽の高度 = arctan(棒の長さ ÷ 影の長さ)。夏は高く、冬は低くなるよ。',
    emoji: '🌞',
  ),
  HomeLabMission(
    id: 'hl_019',
    title: '燃焼で二酸化炭素を確かめよう',
    description: 'ろうそくを燃やし、石灰水に息を吹き込んで白くなるかどうか確かめよう',
    materials: ['ろうそく', 'マッチ', '石灰水（炭酸カルシウム水溶液）', 'ストロー', 'コップ'],
    grade: 6,
    weekOfYear: 19,
    expectedResult: '石灰水に息を吹き込むと白く濁る（CO₂の証明）',
    sciencePoint: '二酸化炭素が石灰水（水酸化カルシウム）と反応して炭酸カルシウムの白い沈殿ができます。',
    emoji: '🕯️',
  ),
  HomeLabMission(
    id: 'hl_020',
    title: 'でんぷんを見つけよう（ヨウ素反応）',
    description: '家の食品（米・パン・野菜など）にヨウ素液を1滴。青紫になればでんぷんあり！',
    materials: ['ヨウ素液（薬局で購入、または殺菌消毒液）', '試す食材×10種', '白い皿'],
    grade: 6,
    weekOfYear: 20,
    expectedResult: 'ご飯・パン・じゃがいもが青紫に変色、肉・魚・砂糖は反応なし',
    sciencePoint: 'ヨウ素はでんぷんと結びついて青紫色に変化します。でんぷんは植物のエネルギー貯蔵物質です。',
    emoji: '🍚',
  ),
];
