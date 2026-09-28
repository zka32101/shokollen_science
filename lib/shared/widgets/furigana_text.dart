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

  List<InlineSpan> _parse(String text, TextStyle base) {
    final result = <InlineSpan>[];
    final pattern = RegExp(r'\{([^|{}]+)\|([^}]+)\}');
    int cursor = 0;

    for (final m in pattern.allMatches(text)) {
      // ルビ前のプレーンテキスト
      if (m.start > cursor) {
        result.add(TextSpan(
          text: text.substring(cursor, m.start),
          style: base,
        ));
      }
      // 漢字（ふりがな）形式で表示。ただし1・2年生で学ぶ漢字だけで
      // 構成されている場合はすでに学習済みとみなし、ふりがなを省略する。
      final kanji = m.group(1)!;
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
        text: text.substring(cursor),
        style: base,
      ));
    }
    return result;
  }
}
