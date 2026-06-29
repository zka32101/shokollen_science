# ② 「AIはかせ」— Claude Haiku本実装 × 月制限付き

**実装期間**: 2026-06-15 〜 2026-06-27（10営業日）  
**優先度**: 🥇 Tier S  
**インパクト**: 月¥100課金の価値を正当化する目玉機能 × 親負担軽減  
**開発コスト**: 低〜中（3-5日API接続 + 2日テスト）

---

## 📖 概要

既にモック実装済みの `claude_service.dart` を **Claude Haiku API本実装** に差し替え。  
「なぜ磁石はくっつくの？」という無限の「なぜ？」に小学生向けに回答。

### システムプロンプト（小学生向け）
```
あなたは「りかはかせ」です。小学生の理科の質問に丁寧に答えます。

【ルール】
1. 難しい言葉は使わず、身近な例えで説明する
2. 最後は「だから、～なんだね」で〆める
3. 理科の話題のみ（他の話は「りかのことを教えてね」と返す）
4. 回答は3文以内（読みやすく）

【例】
Q: なんで磁石はくぎにくっつくの？
A: 磁石には見えない力「磁力」があってね。
   くぎも、その力に吸い寄せられるんだよ。
   だから、ぴたっとくっつくんだね！
```

---

## 🎮 UX フロー

```
[実験クリア画面]
        ↓
   [結果表示]
        ↓
   [ほめカードボタン]
   [ほかのボタン]
   [もっと知りたい？] ← ★新ボタン
        ↓
[AIはかせチャット画面] ★
┌─────────────────────────────────┐
│ りかはかせへ相談 📚              │
│                                 │
│ 「磁石ってなんで...」          │
│                                 │
│ [チャット履歴]                 │
│ Q: なんで磁石はくぎに...       │
│ はかせ: 磁石には見えない力... │
│                                 │
│ [入力欄]                        │
│ ┌──────────────────────────┐  │
│ │ つぎの質問は？ [送信]      │  │
│ └──────────────────────────┘  │
│                                 │
│ 今月 3/5 質問済み (残り 2回)  │
│ 💡 プレミアムなら無制限     │
└─────────────────────────────────┘

（プレミアム版の場合）
├─ 「無制限にもっと聞ける」バナー
└─ 月制限表示なし
```

---

## 📊 データモデル

### AIMessage (新規)
```dart
class AIMessage {
  final String id;
  final String userId;
  final String experimentId;
  final DateTime timestamp;
  final String userQuestion;
  final String hakaseResponse;
  final int tokenCount;
}

class AIUsageStats {
  final String userId;
  final int currentMonth; // YYYYMM format
  final int questionsAsked;
  final int totalTokensUsed;
  bool get isLimitReached => questionsAsked >= monthlyLimit;
  
  static const int monthlyLimit = 5; // 無料版
  static const int premiumLimit = -1; // 無制限
}
```

### Subscription (existing, extended)
```dart
class ChildProfile {
  // ... 既存フィールド ...
  
  bool get isPremium => 
    subscription == SubscriptionType.premium;
}

enum SubscriptionType {
  free,           // 無料（5質問/月）
  monthly,        // 月¥100（無制限）
  onetime,        // 買い切り¥1000（無制限）
}
```

---

## 💾 データベース設計

### SharedPreferences (ローカル)
```
Key Format:
ai_usage_{userId}:{YYYYMM}:questions = 3
ai_usage_{userId}:{YYYYMM}:tokens = 1250
ai_chat_{experimentId}_{timestamp}:message = {...}

Example:
ai_usage_user001:202606:questions = 3
ai_usage_user001:202606:tokens = 1250
ai_chat_exp_001_1718540000:message = {
  "question": "磁石ってなに？",
  "response": "磁石は...",
  "tokens": 150
}
```

### Firestore (クラウド、Phase 4 以降)
```
/users/{userId}/aiUsage/{YYYYMM}
  {
    questionsAsked: 3,
    totalTokensUsed: 1250,
    lastQuestion: 2026-06-18T14:30:00Z,
  }

/users/{userId}/aiMessages/{messageId}
  {
    experimentId: "exp_001",
    userQuestion: "磁石ってなに？",
    response: "磁石は...",
    tokenCount: 150,
    timestamp: 2026-06-18T14:30:00Z,
  }
```

---

## 🔐 API接続設計

### Claude Haiku API セットアップ

#### 環境変数（.env）
```
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxx
```

#### Firebase Remote Config（本番）
- API キー → GitHub Secrets → Cloud Function → FCM で配布
- または Firebase Remote Config で直接設定（本番推奨）

### claude_service.dart（モック→本実装）

#### 現在（モック）
```dart
class ClaudeService {
  Future<String> askHaiku(String question) async {
    // モック実装
    return "磁石には見えない力があってね...";
  }
}
```

#### 新規（本実装）
```dart
import 'package:anthropic/anthropic.dart'; // SDK追加

class ClaudeService {
  final Anthropic _client;
  final String _systemPrompt = '''
あなたは「りかはかせ」です。小学生の理科の質問に丁寧に答えます。

【ルール】
1. 難しい言葉は使わず、身近な例えで説明する
2. 最後は「だから、～なんだね」で〆める
3. 理科の話題のみ（他の話は「りかのことを教えてね」と返す）
4. 回答は3文以内（読みやすく）
5. 絵文字は控えめに使う
6. 小学3-6年の範囲内で

【話し方の例】
- 「ね」「よ」で親しみやすく
- 「だからね」「つまり」で説明的に
- 「すごいね！」で褒める
  ''';
  
  ClaudeService() 
    : _client = Anthropic(
        apiKey: _getApiKey(), // 環境変数 or RemoteConfig
      );
  
  Future<AIResponse> askHaiku(
    String question, {
    required String userId,
    required String experimentId,
    required int monthlyQuestionsUsed,
    required bool isPremium,
  }) async {
    // 月制限チェック
    if (!isPremium && monthlyQuestionsUsed >= 5) {
      throw Exception('今月の質問数が上限に達しました。プレミアムにアップグレード！');
    }
    
    try {
      final message = await _client.messages.create(
        model: 'claude-3-5-haiku-20241022', // 最新Haiku
        maxTokens: 256,
        system: _systemPrompt,
        messages: [
          Message(
            role: 'user',
            content: _sanitizeQuestion(question),
          ),
        ],
      );
      
      final responseText = message.content[0].text;
      final tokensUsed = message.usage?.outputTokens ?? 0;
      
      return AIResponse(
        question: question,
        response: responseText,
        tokensUsed: tokensUsed,
        timestamp: DateTime.now(),
      );
    } on AnthropicException catch (e) {
      // API エラーハンドリング
      if (e.statusCode == 429) {
        throw Exception('質問が多すぎます。少し待ってから試してね。');
      } else if (e.statusCode == 401) {
        throw Exception('APIキーが無効です。開発者に連絡してください。');
      } else {
        throw Exception('はかせが考え中です。もう一度試してね。');
      }
    }
  }
  
  String _sanitizeQuestion(String question) {
    // XSS対策、長さチェック
    if (question.length > 200) {
      return question.substring(0, 200);
    }
    return question
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('javascript:', '')
        .trim();
  }
  
  static String _getApiKey() {
    // 優先度：環境変数 > Firebase Remote Config > デフォルト（エラー）
    final envKey = Platform.environment['ANTHROPIC_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    
    // Firebase RemoteConfig（実装は別途）
    // final remoteKey = await FirebaseRemoteConfig.instance.getString('anthropic_api_key');
    
    throw Exception('ANTHROPIC_API_KEY not configured');
  }
}

class AIResponse {
  final String question;
  final String response;
  final int tokensUsed;
  final DateTime timestamp;
  
  AIResponse({
    required this.question,
    required this.response,
    required this.tokensUsed,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'question': question,
    'response': response,
    'tokensUsed': tokensUsed,
    'timestamp': timestamp.toIso8601String(),
  };
}
```

---

## 🔄 Riverpod 状態管理

```dart
// AI使用量プロバイダー
class AIUsageNotifier extends StateNotifier<AIUsageStats> {
  AIUsageNotifier(this._profileService)
    : super(AIUsageStats(
        userId: '',
        currentMonth: int.parse(
          DateFormat('yyyyMM').format(DateTime.now())
        ),
        questionsAsked: 0,
        totalTokensUsed: 0,
      ));
  
  final ProfileService _profileService;
  
  Future<void> incrementQuestionCount(int tokensUsed) async {
    final currentMonth = int.parse(
      DateFormat('yyyyMM').format(DateTime.now())
    );
    
    // 月初判定：月が変わったらリセット
    if (currentMonth != state.currentMonth) {
      await _resetMonthlyUsage(currentMonth);
    }
    
    final key = 'ai_usage_$currentMonth';
    final newCount = (state.questionsAsked) + 1;
    final newTokens = (state.totalTokensUsed) + tokensUsed;
    
    await _profileService.setInt('$key:questions', newCount);
    await _profileService.setInt('$key:tokens', newTokens);
    
    state = AIUsageStats(
      userId: state.userId,
      currentMonth: currentMonth,
      questionsAsked: newCount,
      totalTokensUsed: newTokens,
    );
  }
  
  Future<void> _resetMonthlyUsage(int newMonth) async {
    // 前月のデータは保持、新月は0初期化
    state = AIUsageStats(
      userId: state.userId,
      currentMonth: newMonth,
      questionsAsked: 0,
      totalTokensUsed: 0,
    );
  }
}

final aiUsageProvider = StateNotifierProvider<AIUsageNotifier, AIUsageStats>(
  (ref) => AIUsageNotifier(ref.watch(profileServiceProvider)),
);

// チャット履歴プロバイダー
final aiChatHistoryProvider = StateNotifierProvider<
    AIChatHistoryNotifier,
    List<AIMessage>>((ref) {
  return AIChatHistoryNotifier(ref.watch(profileServiceProvider));
});

class AIChatHistoryNotifier extends StateNotifier<List<AIMessage>> {
  AIChatHistoryNotifier(this._profileService) : super([]);
  
  final ProfileService _profileService;
  
  Future<void> addMessage(AIMessage message) async {
    final key = 'ai_chat_${message.experimentId}_${message.timestamp.millisecondsSinceEpoch}';
    await _profileService.setString(key, jsonEncode(message.toJson()));
    
    state = [...state, message];
  }
  
  List<AIMessage> getHistoryForExperiment(String experimentId) {
    return state.where((msg) => msg.experimentId == experimentId).toList();
  }
}
```

---

## 🎨 UI コンポーネント

### ai_chat_widget.dart（拡張）

```dart
class AIChatWidget extends ConsumerStatefulWidget {
  final String experimentId;
  
  const AIChatWidget({
    required this.experimentId,
    Key? key,
  }) : super(key: key);
  
  @override
  ConsumerState<AIChatWidget> createState() => _AIChatWidgetState();
}

class _AIChatWidgetState extends ConsumerState<AIChatWidget> {
  late TextEditingController _questionController;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
  }
  
  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
  
  void _sendQuestion() async {
    if (_questionController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final question = _questionController.text;
      _questionController.clear();
      
      final profile = ref.read(activeProfileProvider);
      final aiUsage = ref.read(aiUsageProvider);
      final isPremium = profile?.subscription?.isPremium ?? false;
      
      // 月制限チェック
      if (!isPremium && aiUsage.isLimitReached) {
        _showLimitDialog();
        return;
      }
      
      // API呼び出し
      final response = await ref
        .read(claudeServiceProvider)
        .askHaiku(
          question,
          userId: profile?.id ?? '',
          experimentId: widget.experimentId,
          monthlyQuestionsUsed: aiUsage.questionsAsked,
          isPremium: isPremium,
        );
      
      // 履歴に追加
      final message = AIMessage(
        id: Uuid().v4(),
        userId: profile?.id ?? '',
        experimentId: widget.experimentId,
        timestamp: DateTime.now(),
        userQuestion: question,
        hakaseResponse: response.response,
        tokenCount: response.tokensUsed,
      );
      
      ref.read(aiChatHistoryProvider.notifier).addMessage(message);
      
      // 使用量更新
      ref.read(aiUsageProvider.notifier).incrementQuestionCount(
        response.tokensUsed,
      );
      
    } on Exception catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('質問数が上限です'),
        content: Text('無料版は月5質問までです。\nプレミアムなら無制限！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // 課金画面へ遷移
            },
            child: Text('プレミアムに'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final chatHistory = ref.watch(aiChatHistoryProvider);
    final aiUsage = ref.watch(aiUsageProvider);
    final profile = ref.watch(activeProfileProvider);
    final isPremium = profile?.subscription?.isPremium ?? false;
    
    final experimentHistory = chatHistory
        .where((msg) => msg.experimentId == widget.experimentId)
        .toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('りかはかせへ相談 📚'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 使用量表示
          if (!isPremium)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'この月 ${aiUsage.questionsAsked}/5 質問済み (残り ${5 - aiUsage.questionsAsked}回)',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          
          // チャット履歴
          Expanded(
            child: experimentHistory.isEmpty
              ? Center(
                  child: Text('質問を送って、りかはかせに聞いてみよう！'),
                )
              : ListView.builder(
                  itemCount: experimentHistory.length,
                  itemBuilder: (ctx, i) {
                    final msg = experimentHistory[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ユーザー質問
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: EdgeInsets.all(8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg.userQuestion,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        // はかせ回答
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.all(8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(msg.hakaseResponse),
                          ),
                        ),
                      ],
                    );
                  },
                ),
          ),
          
          // 入力欄
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'つぎの質問は？',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _sendQuestion,
                  icon: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🛡️ セキュリティ & コンプライアンス

### API キー管理
```
開発環境: .env ファイル
本番環境: Firebase Remote Config または Cloud Secret Manager
PR: API キーを .gitignore に追加
```

### ユーザーデータ
- チャット履歴は Firestore 暗号化保存
- API レスポンスはキャッシュしない（個人情報含む可能性）
- GDPR対応：削除要求 → 履歴削除処理

### コンテンツフィルター
- 質問内容のサニタイズ（XSS対策）
- 理科以外の質問 → はかせが「理科の話をしてね」と返す

---

## 📊 分析 & モニタリング

### Firebase Analytics
```dart
analytics.logEvent(
  name: 'ai_question_asked',
  parameters: {
    'experiment_id': experimentId,
    'question_length': question.length,
    'is_premium': isPremium,
  },
);

analytics.logEvent(
  name: 'ai_monthly_limit_reached',
  parameters: {
    'month': DateFormat('yyyyMM').format(DateTime.now()),
  },
);

analytics.logEvent(
  name: 'ai_api_error',
  parameters: {
    'error_message': errorMsg,
    'error_code': errorCode,
  },
);
```

### Crashlytics
```dart
FirebaseCrashlytics.instance.log('AI API call failed: $error');
```

---

## 💰 コスト見積もり

### Claude Haiku API 価格（2024年）
- 入力: $0.80 / 100万トークン
- 出力: $4.00 / 100万トークン

### シナリオ計算（ユーザー1000人想定）
```
想定：月3回/人 × 平均 150トークン質問 × 150トークン回答

月間コスト：
- 質問トークン：3000 × 150 × 1000 / 1000000 × $0.80 = $3.60
- 回答トークン：3000 × 150 × 1000 / 1000000 × $4.00 = $18.00
- 合計：約¥2,650/月（レート140円）

ユーザーあたり：¥2.65

→ 月¥100 × 10% 有料化転換で十分黒字
```

---

## 🧪 テストケース

| ケース | 入力 | 期待結果 |
|--------|------|---------|
| 正常系 | 「磁石ってなに？」 | はかせが3文以内で回答 |
| 月制限達成（無料） | 5回質問後 | 「プレミアムに」ダイアログ |
| 月制限パス（有料） | 無制限質問 | エラーなし |
| 理科外質問 | 「パパって誰？」 | 「りかのこと教えてね」 |
| API エラー（429） | 短時間多数呼び出し | レート制限エラー表示 |
| XSS試行 | `<script>alert('xss')</script>` | サニタイズされて送信 |
| 長い質問 | 201文字以上 | 200文字にカット |
| オフライン | ネット切断時 | 「接続を確認してね」 |

---

## 📝 実装チェックリスト

- [ ] anthropic SDK を pubspec.yaml に追加
- [ ] .env ファイル作成 & ANTHROPIC_API_KEY 設定
- [ ] .env を .gitignore に追加
- [ ] Claude API コンソールでテスト用キー取得
- [ ] claude_service.dart を本実装に差し替え
- [ ] AIUsageNotifier, AIMessage 実装
- [ ] aiUsageProvider, aiChatHistoryProvider 実装
- [ ] ai_chat_widget.dart UI 拡張
- [ ] 月制限ロジック実装 & テスト
- [ ] Firebase Remote Config キー配布（本番）
- [ ] Firebase Analytics イベント定義
- [ ] Crashlytics統合テスト
- [ ] セキュリティレビュー（API キー管理）
- [ ] 負荷テスト（1000 req/day想定）
- [ ] CBT テスター 5名でテスト
- [ ] プライバシーポリシー更新

---

**作成日**: 2026-06-10  
**設計版**: 1.0  
**API仕様参考**: https://docs.anthropic.com/claude/reference/messages  
**next: 統合テスト設計（実装後）**
