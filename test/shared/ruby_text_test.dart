import 'package:flutter_test/flutter_test.dart';
import 'package:shokollen_science/shared/utils/ruby_text.dart';

void main() {
  test('{漢字|よみ} を 漢字（よみ） にする', () {
    expect(rubyToPlain('{昆虫|こんちゅう}と{植物|しょくぶつ}'),
        '昆虫（こんちゅう）と植物（しょくぶつ）');
  });

  test('入れ子と、記法のない文字列', () {
    expect(rubyToPlain('{電{磁石|じしゃく}|でんじしゃく}'), '電磁石（でんじしゃく）');
    expect(rubyToPlain('チョウの育ち'), 'チョウの育ち');
  });
}
