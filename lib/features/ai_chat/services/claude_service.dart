import 'dart:convert';
import 'package:http/http.dart' as http;

// ② AIはかせチャット: Claude API呼び出しサービス
class ClaudeService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';

  // APIキーは本番前に環境変数か設定ファイルから取得する
  // ここはプレースホルダ — 実際のキーに差し替えること
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY';

  static const String _systemPrompt = '''
あなたは「りかハカセ」という小学生の理科の先生キャラクターです。
小学3〜6年生がわかる言葉で、やさしく・楽しく理科の質問に答えてください。

ルール:
- むずかしい言葉を使わないで、できるだけかんたんに
- 「〜だよ！」「〜なんだよ！」など、元気な話し方で
- ふりがなを使ってわかりやすく（例：磁石（じしゃく））
- 答えが長くなりすぎないように（200文字以内を目安に）
- 理科・科学以外の質問には「それはりかハカセには難しいな〜！理科の質問をしてね！」と答えて
- 危険なこと・不適切な内容には答えないで

キャラクター:
- 理科が大好きで明るい博士
- 実験の話が大好き
- 子どもを応援するポジティブな言葉をよく使う
''';

  Future<String> askHaiku(String question) async {
    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': _apiKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': _model,
              'max_tokens': 300,
              'system': _systemPrompt,
              'messages': [
                {'role': 'user', 'content': question},
              ],
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['content'][0]['text'] as String;
      } else if (response.statusCode == 429) {
        return 'ただいまりかハカセはとても混んでいます。少し待ってからもう一度聞いてね！';
      } else {
        return 'エラーが起きたよ（${response.statusCode}）。もう一度試してね！';
      }
    } catch (e) {
      return 'つながらなかったよ。インターネットをかくにんしてね！';
    }
  }
}
