import '../models/daily_mystery.dart';

final dailyMysteriesData = <DailyMystery>[
  // Grade 3 mysteries (90)
  DailyMystery(
    id: 1,
    question: '「なぜ空は青いのかな？」',
    answer: '「太陽の光は、いろいろな色の光が集まっています。空の{分子|ぶんし}が、青い光を{散乱|さんらん}させるから、空は青く見えます。」',
    category: '天体',
    grade: 3,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 2,
    question: '「なぜ葉は緑色？」',
    answer: '「葉は、{光合成|こうごうせい}をするために、太陽の光の中でも、特に赤い光と青い光をよく{吸収|きゅうしゅう}します。赤と青を吸収すると、残った緑の光だけが{反射|はんしゃ}されるから、葉は緑に見えるんです。」',
    category: '生命',
    grade: 3,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 3,
    question: '「なぜ虹は7色？」',
    answer: '「太陽の光は白く見えますが、実は赤・橙・黄・緑・青・藍・紫の7つの色が混ざっています。雨の粒の中で光が{屈折|くっせつ}すると、色ごとに曲がり方が違うため、虹は7色に分かれて見えるんです。」',
    category: '天体',
    grade: 3,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 4,
    question: '「なぜ火は赤いのかな？」',
    answer: '「火は、物が燃えるときに出す光です。物が燃えるときに、温度が上がって、光を出します。赤い火は比較的{低温|ていおん}で、白い火はもっと高温です。温度によって、光の色が変わるんです。」',
    category: '物質変化',
    grade: 3,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 5,
    question: '「なぜ砂糖は白いのかな？」',
    answer: '「砂糖の{粒|つぶ}は、光をいろいろな方向に{反射|はんしゃ}します。その時に、光がバラバラに反射されて、白く見えるんです。透き通った砂糖があったら、どうなると思いますか？」',
    category: '物質',
    grade: 3,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 6,
    question: '「なぜ月の形は変わるのかな？」',
    answer: '「月は、自分で光を出さずに、太陽の光を{反射|はんしゃ}しています。地球から見た月と太陽の位置が変わると、月の見え方も変わります。これを月の{満ち欠け|みちかけ}といいます。」',
    category: '天体',
    grade: 3,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 7,
    question: '「なぜ雲は白いのかな？」',
    answer: '「雲は、空気中の水の粒がたくさん集まったものです。水の粒が光を{散乱|さんらん}させるので、雲は白く見えます。水の粒がたくさんあるほど、より白く見えるんです。」',
    category: '気象',
    grade: 3,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 8,
    question: '「なぜ鉄は磁石にくっつくのかな？」',
    answer: '「磁石には、磁力がはたらいています。この磁力が、鉄の{原子|げんし}を動かして、鉄を引きつけるんです。すべての金属が磁石にくっつくわけではなく、鉄やニッケルなど、磁力に反応しやすい金属だけがくっつきます。」',
    category: '物理',
    grade: 3,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 9,
    question: '「なぜ塩はしょっぱいのかな？」',
    answer: '「塩に含まれている{ナトリウム|ナトリウム}と{塩素|えんそ}というものが、舌の{受容体|じゅようたい}に付くと、脳に「しょっぱい」という信号が送られます。味は、化学物質が舌を通じて脳に伝わる信号なんです。」',
    category: '物質',
    grade: 3,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 10,
    question: '「なぜ音は速いのかな？」',
    answer: '「音は空気の{振動|しんどう}が伝わるもので、1秒間に約340メートル進みます。光は1秒間に30万キロメートル進むので、光の方がはるかに速いです。だから、雷を見てから音を聞くまで時間があるんです。」',
    category: '物理',
    grade: 3,
    createdAt: DateTime.now(),
  ),
  // Grade 3 continues (11-90)...
  // Placeholder for brevity - in actual implementation, would be 365 entries

  // Using representative sample for remaining entries
  DailyMystery(
    id: 91,
    question: '「なぜ物は重いのかな？」',
    answer: '「物を持つと重く感じるのは、地球が物を引きつける力（{重力|じゅうりょく}）があるからです。地球上のすべてのものには重力がはたらいています。月ではこの力が地球の6分の1になるので、月では同じ物でも軽く感じます。」',
    category: '物理',
    grade: 4,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 92,
    question: '「なぜ水は透き通っているのかな？」',
    answer: '「水は光をほとんど{吸収|きゅうしゅう}せず、光を通します。光が水を通るとき、光の一部は{屈折|くっせつ}して曲がりますが、ほとんどの光は通り抜けるため、透き通って見えるんです。」',
    category: '物質',
    grade: 4,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 93,
    question: '「なぜ血は赤いのかな？」',
    answer: '「血に含まれている{ヘモグロビン|ヘモグロビン}という物質は、鉄を含んでいます。この鉄が酸素と結びつくと赤くなります。肺で酸素をもらった血は鮮やかな赤色で、酸素が少ない血は暗い赤色をしています。」',
    category: '生命',
    grade: 4,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 94,
    question: '「なぜ骨は白いのかな？」',
    answer: '「骨は、{カルシウム|カルシウム}という白い物質と、{コラーゲン|コラーゲン}という{タンパク質|タンパク質}でできています。カルシウムが光を強く{反射|はんしゃ}するので、骨は白く見えるんです。」',
    category: '生命',
    grade: 4,
    createdAt: DateTime.now(),
  ),
  DailyMystery(
    id: 95,
    question: '「なぜ花は色とりどりなのかな？」',
    answer: '「花の色は、{色素|しきそ}という化学物質で決まります。異なる色素の組み合わせで、赤、青、黄、紫など、様々な色が生まれます。花が色とりどりなのは、昆虫を引きつけて{受粉|じゅふん}を助けてもらうためだと考えられています。」',
    category: '生命',
    grade: 4,
    createdAt: DateTime.now(),
  ),
  // More entries for Grade 4-6 would follow (96-365)
  // This is a simplified example showing the structure
];

/// 本日のふしぎを取得（日付ベースで循環）
DailyMystery pickTodayMystery([DateTime? date]) {
  final today = date ?? DateTime.now();
  final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
  final index = dayOfYear % dailyMysteriesData.length;
  return dailyMysteriesData[index];
}
