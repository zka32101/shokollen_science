import 'package:flutter/material.dart';
import '../data/grade1_2_kanji.dart';

/// {漢字|ふりがな} 形式のテキストを「漢字（ふりがな）」の通常テキストとして表示するウィジェット
///
/// このアプリは3〜6年生向けのため、小学1・2年生で学ぶ漢字（[kGrade1And2Kanji]）は
/// 既に学習済みとみなし、ふりがなを表示しない（漢字のみ表示する）。
///
/// 使い方:
///   FuriganaText('{昆虫|こんちゅう}は{体|からだ}が3つに分かれます')
class FuriganaText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const FuriganaText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final base = style ??
        DefaultTextStyle.of(context).style.copyWith(
              fontSize: 14,
              color: Colors.black87,
            );
    return Text.rich(
      TextSpan(children: _parse(text, base)),
      textAlign: textAlign,
    );
  }

  // 「電磁石」のように、複合語の内側にさらに {漢字|ふりがな} が入れ子になる
  // ケース（例: {電{磁石|じしゃく}|でんじしゃく}）に対応するため、
  // 漢字部分に1段までのネストを許容する。
  static final _pattern = RegExp(r'\{((?:[^{}|]|\{[^{}|]+\|[^{}]+\})+)\|([^{}]+)\}');

  // データ側の入力ミスで { / } / | の対応が崩れている箇所が稀にあり、
  // その場合は正規表現にマッチせず生の記号がそのまま画面に出てしまう。
  // 崩れた記号はふりがな情報として復元できないため、せめて漢字（かんじ）の
  // ような一般的な見た目を保てるよう、プレーンテキスト部分からは
  // 単独で残った { / } / | を取り除く。
  static final _strayMarkers = RegExp(r'[{}|]');

  List<InlineSpan> _parse(String text, TextStyle base) {
    final result = <InlineSpan>[];
    int cursor = 0;

    for (final m in _pattern.allMatches(text)) {
      // ルビ前のプレーンテキスト
      if (m.start > cursor) {
        result.add(TextSpan(
          text: text
              .substring(cursor, m.start)
              .replaceAll(_strayMarkers, ''),
          style: base,
        ));
      }
      // 漢字（ふりがな）形式で表示。ただし1・2年生で学ぶ漢字だけで
      // 構成されている場合はすでに学習済みとみなし、ふりがなを省略する。
      // 入れ子の内側の {漢字|ふりがな} はまず素の漢字に落としてから判定する。
      final kanji = m.group(1)!.replaceAllMapped(
          RegExp(r'\{([^{}|]+)\|[^{}]+\}'), (inner) => inner.group(1)!);
      final isGrade1Or2Only =
          kanji.runes.every((r) => kGrade1And2Kanji.contains(String.fromCharCode(r)));
      result.add(TextSpan(
        text: isGrade1Or2Only ? kanji : '$kanji（${m.group(2)!}）',
        style: base,
      ));
      cursor = m.end;
    }

    if (cursor < text.length) {
      result.add(TextSpan(
        text: text.substring(cursor).replaceAll(_strayMarkers, ''),
        style: base,
      ));
    }
    return result;
  }
}
