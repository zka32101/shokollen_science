/// データ中の {漢字|よみ} 記法を「漢字（よみ）」の普通の文字列にする。
/// ふりがな付きウィジェットを使えない場所(単純な Text など)で使う。
String rubyToPlain(String s) {
  // {電{磁石|じしゃく}|でんじしゃく} のような1段の入れ子にも対応する
  final pattern = RegExp(r'\{((?:[^{}|]|\{[^{}|]+\|[^{}]+\})+)\|([^{}]+)\}');
  return s.replaceAllMapped(pattern, (m) {
    final kanji = m.group(1)!.replaceAllMapped(
        RegExp(r'\{([^{}|]+)\|[^{}]+\}'), (n) => n.group(1)!);
    return '$kanji（${m.group(2)}）';
  });
}
