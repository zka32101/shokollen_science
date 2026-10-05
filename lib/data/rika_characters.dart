import 'package:shared_core/shared_core.dart';

/// 理科コレ キャラクター（16体）。解放順は 生物→物質→エネルギー→地球・宇宙 を交互にしてバランスを取る。
/// unlockAt: UserProgress.clearedCount（クリア済みステージ数）の閾値
/// 画像: assets/characters/<id>.png / Lv.2表情 assets/character_levels/<id>_lv2_<1-3>.png
const List<BaseCharacter> kRikaCharacters = [
  BaseCharacter(
    id: 'happakko',
    imageAsset: 'assets/characters/happakko.png',
    name: 'ハッパっこ',
    emoji: '🍃',
    tier: 1,
    unlockAt: 0,
    subject: '植物・光合成(3年〜6年)',
    backstory:
        'ハッパっこは日なたが大好きな葉っぱの子。\n'
        '「葉っぱは日光を浴びて、でんぷんをつくるんだよ！」が口ぐせ。\n'
        '光合成で酸素を出すのが自慢で、\n'
        '朝いちばんに大きく背のびをするんだって。',
    stampPhrases: [
      '光合成だよ！',
      '日なたぼっこ',
      '葉脈を見つけた',
      'ハッパっこと育てよう',
      '酸素をどうぞ',
      'でんぷんできた',
      '芽が出たよ',
      '理科大好き！',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'mizubunshi',
    imageAsset: 'assets/characters/mizubunshi.png',
    name: 'ミズ水分子',
    emoji: '💧',
    tier: 1,
    unlockAt: 3,
    subject: '水のすがた・水溶液',
    backstory:
        'ミズ水分子は形を自由に変えられる水の子。\n'
        '「水は冷やすと氷、あたためると水蒸気になるよ！」\n'
        'とっても気まぐれで、コップの中でもたまり水でも\n'
        'どこへでもすいっと流れていくんだって。',
    stampPhrases: [
      'ぷるぷる！',
      'H2Oだよ',
      'ミズと実験',
      '水に溶けたよ',
      '流れていくよ',
      'しずくがぽとり',
      'すいすい進もう',
      'もっと知りたい',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'hikari',
    imageAsset: 'assets/characters/hikari.png',
    name: 'ヒカリ光',
    emoji: '💡',
    tier: 1,
    unlockAt: 5,
    subject: '光の性質',
    backstory:
        'ヒカリ光は光の速さで走り回る元気な子。\n'
        '「光はまっすぐ進んで、鏡ではね返るよ！」が決めゼリフ。\n'
        '虫めがねで光を集めるのが得意だけど、\n'
        '日なたでやけどしそうなのが悩みなんだって。',
    stampPhrases: [
      'ピカッ！',
      'まっすぐ進む',
      '鏡で反射！',
      '光を集めたよ',
      '影ができた',
      '虹を見つけた',
      'ヒカリと実験',
      'まぶしいね',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'taiyou',
    imageAsset: 'assets/characters/taiyou.png',
    name: 'タイヨウ',
    emoji: '☀️',
    tier: 1,
    unlockAt: 8,
    subject: '太陽・星と月の動き',
    backstory:
        'タイヨウは空の高いところから見守る太陽の子。\n'
        '「太陽は東からのぼって、南を通って西にしずむよ！」\n'
        'いつも元気だけど、夜は地球の裏側でお休み中。\n'
        '影の長さで時刻を教えてくれる名人なんだ。',
    stampPhrases: [
      'おはよう！',
      '東からのぼるよ',
      '影が動いたよ',
      'あったかいね',
      '南中したよ',
      '日時計で遊ぼう',
      'ぽかぽか',
      'また明日！',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'mushimushi',
    imageAsset: 'assets/characters/mushimushi.png',
    name: 'ムシムシ',
    emoji: '🦋',
    tier: 2,
    unlockAt: 12,
    subject: '昆虫・動物のからだ',
    backstory:
        'ムシムシは野原を飛びまわるちょうちょの子。\n'
        '「昆虫の体は頭・胸・腹、あしは6本だよ！」が口ぐせ。\n'
        'たまご・よう虫・さなぎ・成虫の育ち方を\n'
        '全部知っている生き物はかせなんだ。',
    stampPhrases: [
      '6本あしだよ',
      'ひらひら飛ぶよ',
      'さなぎになるよ',
      'ムシムシと観察',
      '花のみつ、おいしい',
      '羽が生えた！',
      'まだ見てない虫',
      '探検しよう',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'koori',
    imageAsset: 'assets/characters/koori.png',
    name: 'コオリ',
    emoji: '🧊',
    tier: 2,
    unlockAt: 16,
    subject: '水のすがた(固体)・温度',
    backstory:
        'コオリはひんやりクールな氷の子。\n'
        '「水は0度でこおって、ふくらむんだよ！」と教えてくれる。\n'
        'あたたかい部屋が少し苦手で、\n'
        'とけないようにいつも冷凍庫に避難しているんだ。',
    stampPhrases: [
      'ひんやり〜',
      '0度でこおるよ',
      'とけちゃう！',
      '氷はういてる',
      'ふくらむよ',
      'ピキーン！',
      'コオリと実験',
      '冷たいね',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'onpa',
    imageAsset: 'assets/characters/onpa.png',
    name: 'オンパ音波',
    emoji: '🔊',
    tier: 2,
    unlockAt: 20,
    subject: '音の性質',
    backstory:
        'オンパは音のふるえで元気になる音波の子。\n'
        '「音は物がふるえて伝わるんだよ！」が合言葉。\n'
        '糸電話や太鼓のふるえが大好きで、\n'
        '空気のない宇宙では静かになってしまうんだって。',
    stampPhrases: [
      'ブルブル！',
      '音が伝わるよ',
      '大きな音だ',
      '高い音・低い音',
      '糸電話しよう',
      'ふるえてる',
      'オンパと実験',
      '耳をすまそう',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'tsukichan',
    imageAsset: 'assets/characters/tsukichan.png',
    name: 'ツキちゃん',
    emoji: '🌙',
    tier: 2,
    unlockAt: 24,
    subject: '月・星の見え方',
    backstory:
        'ツキちゃんは夜空にすむ月の子。\n'
        '「月の形は、日によって満ち欠けするんだよ！」\n'
        '新月から満月まで約30日かけて変身するのが\n'
        'ひそかな自慢なんだって。',
    stampPhrases: [
      '満月だよ',
      '三日月になった',
      '月がのぼる',
      'ツキちゃんと観察',
      '夜空きれい',
      '形が変わるよ',
      '星も見えるね',
      'おやすみなさい',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'mizukko',
    imageAsset: 'assets/characters/mizukko.png',
    name: 'ミズっこ魚',
    emoji: '🐟',
    tier: 3,
    unlockAt: 28,
    subject: '水の生き物・メダカ',
    backstory:
        'ミズっこは川や池をすいすい泳ぐ魚の子。\n'
        '「メダカのたまごは、だんだん魚のすがたになるよ！」\n'
        'えらで呼吸して、ひれで上手に泳ぐのが得意。\n'
        '水の中の生き物には何でも詳しいんだ。',
    stampPhrases: [
      'すいすい泳ぐ',
      'えらで呼吸',
      'たまごを見つけた',
      'ミズっこと観察',
      '水草の陰にいるよ',
      'ひれを動かすよ',
      'ぽちゃん！',
      '池をのぞこう',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'jouki',
    imageAsset: 'assets/characters/jouki.png',
    name: 'ジョウキ',
    emoji: '♨️',
    tier: 3,
    unlockAt: 32,
    subject: '蒸発と水蒸気・ものの温まり方',
    backstory:
        'ジョウキは湯気の中からあらわれる水蒸気の子。\n'
        '「水は熱するとあわを出して、水蒸気に変わるよ！」\n'
        'ふっとうのとき、あっという間に空へ昇っていく。\n'
        '冷やされるとまた水つぶにもどるんだ。',
    stampPhrases: [
      'ふっとう！',
      'もくもく',
      '蒸発したよ',
      '水にもどった',
      'あわが出たよ',
      'ジョウキと実験',
      'あったかいね',
      '空へ昇ろう',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'denki',
    imageAsset: 'assets/characters/denki.png',
    name: 'デンキ電気',
    emoji: '⚡',
    tier: 3,
    unlockAt: 36,
    subject: '電気の通り道・回路',
    backstory:
        'デンキはパチパチ光る元気な電気の子。\n'
        '「電気はぐるっと輪になっていないと流れないよ！」\n'
        '豆電球をつけるのが大好きで、\n'
        '回路をつなぐのがとても上手なんだ。',
    stampPhrases: [
      'ビリビリ！',
      '回路をつなごう',
      '豆電球ついた',
      '電池をつなぐよ',
      '電気が流れた',
      'スイッチオン',
      'デンキと実験',
      'ショートに注意',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'tenki',
    imageAsset: 'assets/characters/tenki.png',
    name: 'テンキ天気',
    emoji: '⛅',
    tier: 3,
    unlockAt: 40,
    subject: '天気の変化・雲',
    backstory:
        'テンキは空を見て天気を当てる天気の子。\n'
        '「雲の量で、晴れとくもりが決まるんだよ！」\n'
        '雲の動きから、あしたの天気を予想するのが得意。\n'
        '台風の日は少しおとなしくなるんだって。',
    stampPhrases: [
      '晴れたよ',
      '雲が出てきた',
      '雨がふるよ',
      '天気予想しよう',
      '虹が出た',
      '風がふいた',
      'テンキと観察',
      'あしたは晴れかな',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'hitohito',
    imageAsset: 'assets/characters/hitohito.png',
    name: 'ヒトヒト',
    emoji: '🧍',
    tier: 4,
    unlockAt: 44,
    subject: '人のからだ・骨と筋肉',
    backstory:
        'ヒトヒトは体のしくみを教えてくれる人の子。\n'
        '「心臓は血液を全身に送るポンプなんだよ！」\n'
        '骨と筋肉でささえられて動くことや、\n'
        '食べ物が消化されるしくみにとても詳しいんだ。',
    stampPhrases: [
      'ドキドキ',
      '心臓が動くよ',
      '深呼吸しよう',
      '骨と筋肉だよ',
      'ヒトヒトと学ぼう',
      'よくかんで食べよう',
      '脈をはかろう',
      '元気いっぱい',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'dorodoro',
    imageAsset: 'assets/characters/dorodoro.png',
    name: 'ドロドロ',
    emoji: '🟤',
    tier: 4,
    unlockAt: 48,
    subject: '土・地面のようす・水のしみこみ',
    backstory:
        'ドロドロは土の中にすむどろんこの子。\n'
        '「土の粒の大きさで、水のしみこみ方が変わるよ！」\n'
        'すな・どろ・れきの違いを調べるのが大好きで、\n'
        '雨上がりの校庭を見つけると走っていくんだ。',
    stampPhrases: [
      'どろんこ！',
      '水がしみた',
      'すなとどろ',
      '土をほろう',
      'つぶが大きいよ',
      'ドロドロと実験',
      '校庭に行こう',
      '地面の下は？',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'jishaku',
    imageAsset: 'assets/characters/jishaku.png',
    name: 'ジシャク磁石',
    emoji: '🧲',
    tier: 4,
    unlockAt: 52,
    subject: '磁石の性質',
    backstory:
        'ジシャクは鉄を引き寄せる磁石の子。\n'
        '「N極とS極は引き合って、同じ極はしりぞけ合うよ！」\n'
        '鉄のものを見つけると思わずくっついてしまい、\n'
        'よくクリップを引っぱってしまうのが悩み。',
    stampPhrases: [
      'くっついた！',
      'N極とS極',
      '反発するよ',
      '鉄を見つけた',
      '磁石パワー！',
      '方位磁針も磁石',
      'ジシャクと実験',
      '引き合うよ',
    ],
    appSubject: Subject.shokollen,
  ),
  BaseCharacter(
    id: 'kaseki',
    imageAsset: 'assets/characters/kaseki.png',
    name: 'カセキ化石',
    emoji: '🦴',
    tier: 4,
    unlockAt: 56,
    subject: '地層・化石・大地の変化',
    backstory:
        'カセキは大昔のようすを知る化石の子。\n'
        '「地層は、れきや砂やどろが積もってできたんだよ！」\n'
        '貝や植物の化石から、\n'
        '昔そこが海だったことを教えてくれる大地の語り部だ。',
    stampPhrases: [
      '化石を発見！',
      '地層だよ',
      '大昔の海',
      '層が重なる',
      '火山と地震',
      'カセキと発掘',
      'れき・砂・どろ',
      '大地は動く',
    ],
    appSubject: Subject.shokollen,
  ),
];
