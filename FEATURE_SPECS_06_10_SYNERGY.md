# ⑥⑦⑧⑨⑩ シナジー機能 実装仕様（簡潔版）

---

## ⑥ 「失敗ラボ推理拡張」— なぜ失敗した？

**実装期間**: 2026-08-01（既存機能拡張）  
**優先度**: 5位  
**コスト**: 低〜中

### 概要
既存「失敗ラボ」を進化させ、失敗の「原因を推理する」探偵モードに。

### 実装
```dart
// experiment_play_screen.dart に新モード追加
enum QuizMode {
  reverse,           // 逆実験（既存）
  failedLab,         // 失敗ラボ（既存）
  quiz,              // クイズ（既存）
  timerQuiz,         // タイマークイズ（既存）
  troubleshoot,      // トラブルシューティング（新規）← ⑥
}

// troubleshoot_mode では
// Q: 「豆電球がつかない。原因は？」
// A: 電池向き反対 / 導線切れ / ソケットゆるい
// → 「ラボたんてい」バッジ進捗
```

### 既存資産の再利用
- `choice_widget.dart` UI そのまま
- 問題データ：20実験 × 5問 = 100問

### バッジ
```dart
BadgeDefinition(
  id: 'troubleshoot_detective',
  name: 'ラボたんてい',
  description: 'トラブルシューティングで失敗原因を3個発見',
  unlockCondition: 'troubleshoot_correct >= 3',
)
```

### チェックリスト
- [ ] troubleshoot_question_data.dart 作成（100問）
- [ ] experiment_play_screen に QuizMode 追加
- [ ] 「ラボたんてい」バッジ定義
- [ ] Firebase Analytics イベント

---

## ⑦ 「季節シンクロ配信」— ホーム「今月のおすすめ」

**実装期間**: 2026-07-04（軽量機能）  
**優先度**: 🥇 Tier S  
**コスト**: 極小

### 概要
6月=梅雨→天気ステージ推し、8月=ペルセウス座流星群→天体推し。

### 実装
```dart
// lib/features/home/widgets/home_recommendation_widget.dart
class HomeRecommendationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = DateTime.now().month;
    
    final recommendation = {
      3: '春の花が咲く季節！「植物」ステージへ',
      6: '梅雨だ。「天気」ステージで雲を学ぼう',
      8: 'ペルセウス座流星群！「天体」がおすすめ',
      10: '秋の実験！「季節」テーマを体験',
      12: 'クリスマス特別ステージ限定配信',
    }[month];
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getSeasonalColors(month),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('今月のおすすめ 🌟', style: TextStyle(fontSize: 18)),
          Text(recommendation ?? '新しい実験に挑戦！'),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _navigateToExperiment(month),
            child: Text('見てみる'),
          ),
        ],
      ),
    );
  }
  
  List<Color> _getSeasonalColors(int month) {
    if (month <= 2 || month == 12) return [Colors.blue, Colors.cyan]; // winter
    if (month <= 5) return [Colors.pink, Colors.green]; // spring
    if (month <= 8) return [Colors.orange, Colors.red]; // summer
    return [Colors.amber, Colors.orange]; // autumn
  }
}
```

### チェックリスト
- [ ] home_recommendation_widget.dart 実装
- [ ] ホーム画面へ組み込み
- [ ] 季節色の配定（春夏秋冬）
- [ ] テスト（各月の表示確認）

---

## ⑧ 「タイムトラベル拡張」— 科学者ストーリー

**実装期間**: 2026-08-22（コンテンツ追加）  
**優先度**: 8位  
**コスト**: 低

### 概要
既存タイムトラベル 4ミッションに、偉人ストーリーを追加。

### 既存ミッション（4個）
1. ガリレオ
2. マリア・キュリー
3. ニュートン
4. 牧野富太郎

### 拡張ストーリー
```dart
class ScientistStory {
  final String scientistName;
  final String birthYear;
  final String achievement;
  final String failureStory;  // 「ニュートンは実験で怪我もした」
  final String relatedExperiment; // "exp_015"
}

// 使用例
ScientistStory(
  scientistName: 'アイザック・ニュートン',
  birthYear: '1643年',
  achievement: '万有引力の法則を発見',
  failureStory: 'ニュートンは目の病気で苦しんだ。\n'
      'でも諦めず、たくさんの実験をして\n'
      'なぜりんごは落ちるのか考え続けたんだ。',
  relatedExperiment: 'exp_015', // 重力・落下のステージ
)
```

### 実装
```dart
// lib/features/time_travel/data/scientist_story_data.dart
final scientistStories = [
  // 既存 4ミッション
  // + 新規偉人ストーリー 4個
  // 計 8ストーリー
];

// time_travel_screen に表示
ListView.builder(
  itemCount: scientistStories.length,
  itemBuilder: (ctx, i) {
    return StoryCard(story: scientistStories[i]);
  },
)
```

### チェックリスト
- [ ] scientist_story_data.dart 作成
- [ ] 偉人テキスト 4個作成（日本語化）
- [ ] 失敗エピソードシナリオ化
- [ ] 時系列クイズ（ニュートン何年生まれ？など）
- [ ] 関連実験へのボタン

---

## ⑨ 「親子バトル化」— 予想バトル5ラウンド

**実装期間**: 2026-08-22  
**優先度**: 8位  
**コスト**: 低

### 概要
既存「親子バトル 5ラウンド」を「予想バトル」に変更。

### 実装
```dart
// lib/features/battle/screens/battle_screen.dart

// 既存：スコアの大きさで勝負
// 新規：予想の正確さで勝負

class BattleRound {
  final String experimentId;
  final String predictionQuestion; // 「つくかな？」
  final String correctAnswer;       // 「つく」
  
  // 子どもが予想、親も予想
  // → 両者の結果を表示（親も間違える！）
  // → 親子で「へぇ〜」と学べる
}
```

### UX
```
[バトル画面]
親と子が同じ実験を見る
  ↓
「磁石はボタンにくっつくかな？」
  ↓
子ども予想：「つく」
親予想：「つかない」
  ↓
結果：「つく」
親も間違えた！😄
  ↓
親「へー、ボタンは鉄だったのか」
→ 親も学ぶ（重要）
```

### チェックリスト
- [ ] battle_screen に prediction モード追加
- [ ] 親子の予想を並べて表示
- [ ] 結果で両者の当外れを判定
- [ ] ボーナスルール（両方正解で +50コイン）

---

## ⑩ 「教科横断バッジ」— shared_core 統合

**実装期間**: 2026-08-29  
**優先度**: 10位  
**コスト**: 低〜中

### 概要
国語・算数・理科全てで特定ステージクリア → シリーズ横断バッジ。

### バッジ定義
```dart
BadgeDefinition(
  id: 'triple_crown_science',
  name: '三冠コレクター',
  description: '国語・算数・理科のコレ全て同じステージをクリア',
  icon: 'assets/badges/triple_crown.png',
  unlockCondition: 'shared_core.checkCrossSubjectBadge()',
  category: BadgeCategory.achievement,
  tier: 3, // ゴールド
)
```

### 実装フロー
```
shared_core/lib/badge_service.dart に以下を追加

Future<void> checkCrossSubjectBadges() async {
  // Firestore: /apps/{app_id}/user/{userId}/progress
  // 国語でステージ3クリア
  // 算数でステージ3クリア
  // 理科でステージ3クリア
  // → 全て確認できたら三冠バッジ付与
}
```

### shared_core の修正
```
変更点：
- BadgeRegistry に「cross_subject」カテゴリ追加
- 複数アプリの進捗を一箇所で追跡できる仕組み
- Firebase でアプリ間データ共有（ユーザーID で統合）
```

### チェックリスト
- [ ] shared_core 打ち合わせ（別チーム）
- [ ] cross_subject_badge.dart 実装
- [ ] Firestore スキーマ設計（複数アプリ対応）
- [ ] バッジ表示ロジック
- [ ] 国語・算数のリリース時期確認

---

## 統合実装タイムライン

```
2026-06-15 ～ 06-20： ① よそうラボ
2026-06-20 ～ 06-27： ② AIはかせ
2026-06-27 ～ 07-04： ③ おうちラボ + ⑦ 季節シンクロ
2026-07-04 ～ 07-25： ④ 今夜の空
2026-07-25 ～ 08-08： ⑤ いきものカメラ
2026-08-01 ～ 08-15： ⑥ 失敗ラボ推理 + Firebase
2026-08-15 ～ 08-22： ⑧ タイムトラベル + ⑨ 親子バトル化
2026-08-22 ～ 08-29： ⑩ 教科横断バッジ（shared_core）
2026-08-29 ～ 08-31： 最終テスト・バグ取り
2026-09-01：         リリース 🚀
```

---

## 共通チェックリスト（全機能）

### 開発
- [ ] 各機能の詳細設計書完成
- [ ] コードレビュー チェックリスト作成
- [ ] テストコード（Unit/Widget）カバー率 80%以上

### QA
- [ ] デバイス実機テスト（Android 15+, iOS 16+）
- [ ] 画面サイズ対応（5.5" ～ 6.7"）
- [ ] オフライン/オンライン切り替えテスト
- [ ] メモリリーク検査

### セキュリティ
- [ ] API キー漏洩チェック（git-secrets）
- [ ] プライバシーポリシー更新
- [ ] GDPR/個情保 対応確認

### 分析 & モニタリング
- [ ] Firebase Analytics イベント全定義完了
- [ ] Crashlytics 設定完了
- [ ] Slow frames / ANR 監視設定

### ストア申請
- [ ] スクリーンショット 5枚（新機能各1-2枚）
- [ ] アプリ説明文更新（新機能盛り込み）
- [ ] キーワード最適化（AI、親子学習、STEM等）
- [ ] テスター招待メール下書き

---

## リスク & 対策

| リスク | 影響 | 対策 |
|--------|------|------|
| Claude API レート制限 | ②③失敗 | キャッシング、クライアント側スロットリング |
| GPS 精度不足（④） | 誤った天体通知 | 精度フィルタ（50m以下のみ利用） |
| カメラAI誤判定（⑤） | ユーザー満足度↓ | 複数候補表示、手動修正ボタン |
| Firebase 移行遅延 | リリース延期 | Phase 3.5 終了後即座に開始 |
| shared_core 対応遅延（⑩） | 教科横断バッジ実装不可 | 複数チーム調整、進捗管理 |

---

**作成日**: 2026-06-10  
**版**: 1.0（簡潔版）  
**詳細化**: リリース前1ヶ月から各機能の詳細テスト設計書へ展開
