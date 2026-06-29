# Sonnet 統合チェックリスト

**現在の状態**: Haiku により以下4機能の軽い実装が完成。Sonnet がこれらを既存コードに統合する作業。

---

## 実装済みファイル一覧（統合対象）

```
lib/features/experiments/widgets/prediction_step_widget.dart
lib/features/experiments/providers/prediction_provider.dart
lib/features/experiments/widgets/prediction_result_widget.dart
lib/features/home/widgets/seasonal_recommendation_widget.dart
lib/features/experiments/data/troubleshoot_data.dart
lib/features/battle/data/prediction_battle_data.dart
```

---

## ① よそうラボ 統合タスク

### Step 1: experiment_play_screen.dart に統合

- [ ] `import prediction_step_widget.dart`
- [ ] `import prediction_provider.dart`
- [ ] `experiment_play_screen.dart` に Step 0（予想）を追加
  - 通常は Step 1-4 を実行
  - 最初に `currentStep == 0` なら `PredictionStepWidget` を表示
  - ユーザーが予想を選択 → `userPrediction` を保存 → Step 1 へ進む

### Step 2: experiment_result_screen.dart に統合

- [ ] `import prediction_result_widget.dart`
- [ ] 既存の `result_widget.dart` の後に `PredictionResultWidget` を挿入
- [ ] `userPrediction` と `experiment.predictionAnswer` を渡す
- [ ] result_screen でクリック後、`predictionProvider.recordPrediction()` を呼び出す

### Step 3: Experiment モデル に予想フィールド追加

- [ ] `lib/data/models/experiment.dart` に以下を追加：
  ```dart
  final String? predictionQuestion;
  final List<String>? predictionChoices;
  final String? predictionAnswer;
  ```

### Step 4: experiments_data.dart に予想データ追加

- [ ] 全20実験に `predictionQuestion`, `predictionChoices`, `predictionAnswer` を埋める
- [ ] 例: `exp_001` (磁石と鉄)
  ```dart
  predictionQuestion: "くぎは磁石につくかな？",
  predictionChoices: ["つく", "つかない", "わからない"],
  predictionAnswer: "つく",
  ```

### Step 5: バッジシステム連動

- [ ] `lib/data/models/badge_definition.dart` に "よそう名人" バッジ追加
  ```dart
  BadgeDefinition(
    id: 'prediction_master',
    name: 'よそう名人',
    description: '予想的中率が90%以上！',
    unlockCondition: 'prediction_rate >= 90',
  )
  ```
- [ ] `ProfileService` に `checkPredictionMasterBadge()` メソッド追加

### 統合後テスト

- [ ] 実験選択 → クイズモード選択 → 「よそうラボ」モード（新）
- [ ] 予想画面表示 確認
- [ ] 予想後にクイズ進行 確認
- [ ] 結果画面に的中率表示 確認
- [ ] 複数回実施 → 的中率グラフ更新 確認
- [ ] 90%達成 → バッジアンロック 確認

---

## ⑦ 季節シンクロ配信 統合タスク

### Step 1: home_screen.dart に統合

- [ ] `import seasonal_recommendation_widget.dart`
- [ ] ホーム画面の最上部（プロフィールバーの下）に以下を追加：
  ```dart
  SeasonalRecommendationWidget(
    onTap: () {
      // 推奨実験に遷移するロジック
      // month に応じた experimentId を取得 → navigator.push()
    },
  )
  ```

### Step 2: 推奨実験へのナビゲーション実装

- [ ] `_getSeasonalRecommendation()` から month に対応する `experimentId` を返す関数を作成
- [ ] `SeasonalRecommendationWidget` の `onTap` で該当実験へ遷移

### 統合後テスト

- [ ] ホーム画面上部に「今月のおすすめ」が表示される
- [ ] 12ヶ月全て異なるテキスト＆色が表示される
- [ ] タップ → 対応実験へ遷移 確認
- [ ] 季節色が正しく表示される（春ピンク、夏オレンジ等）

---

## ⑥ 失敗ラボ推理 統合タスク

### Step 1: experiment_play_screen に新モード追加

- [ ] `QuizMode` enum に `troubleshoot` を追加
- [ ] クイズモード選択画面に「トラブルシューティング」ボタン追加
- [ ] ユーザーが選択 → `troubleshoot_data.dart` から問題を取得

### Step 2: troubleshoot_data.dart を完成させる

- [ ] **今は代表例のみ** → 20実験 × 5問 = 100問を全て埋める
- [ ] 例: `exp_002` (光と影) の 5問
- [ ] 例: `exp_003` (音の振動) の 5問
- [ ] ...以降全実験

### Step 3: 結果画面に「ラボたんてい」バッジ表示

- [ ] バッジ定義に追加：
  ```dart
  BadgeDefinition(
    id: 'troubleshoot_detective',
    name: 'ラボたんてい',
    description: 'トラブルシューティングで失敗原因を3個発見',
    unlockCondition: 'troubleshoot_correct >= 3',
  )
  ```

### 統合後テスト

- [ ] クイズモード選択に「トラブルシューティング」が表示される
- [ ] 選択 → 問題が表示される
- [ ] 正解判定が機能する
- [ ] 3問正解 → バッジアンロック 確認

---

## ⑨ 親子バトル化 統合タスク

### Step 1: battle_screen.dart を予想バトルに変更

- [ ] `lib/features/battle/screens/battle_screen.dart` を開く
- [ ] 既存の「スコアバトル」ロジックを「予想バトル」に置き換え
- [ ] `prediction_battle_data.dart` から `getBattleQuestionsForRound()` で問題取得
- [ ] 5ラウンド分を実施

### Step 2: バトル画面の UI を予想用に変更

- [ ] ラウンド画面で：
  ```
  「磁石と鉄」
  「くぎは磁石につくかな？」
  
  子どもの予想：[選択肢]
  親の予想：[選択肢]
  
  「バトルスタート！」
  ```

### Step 3: 結果判定ロジック

- [ ] `BattleRound` クラスの `winner` プロパティで判定
- [ ] 両方正解 → 同点 + ボーナス +50コイン
- [ ] 片方正解 → その親or子が勝ち
- [ ] どちらも外れ → 「へぇ〜」と学ぶ演出

### Step 4: 結果画面

- [ ] `BattleResult` に基づいて：
  ```
  「やったー！子どもの勝ち！」 or 「お父さん・お母さんの勝ち！」 or 「同点！」
  スコア表示：子ども 3 - 親 2
  ```

### 統合後テスト

- [ ] 親子バトル画面 → 親子で別々に予想選択
- [ ] 5ラウンド進行 確認
- [ ] 結果計算正確か確認
- [ ] 親が間違える場面で「へぇ〜」と学べるか確認

---

## 統合完了後のチェック

### コード品質
- [ ] すべてのインポート正しいか
- [ ] 型チェック `flutter analyze` パス
- [ ] Widget テスト作成（PredictionStepWidget, SeasonalRecommendationWidget）

### 動作確認
- [ ] 全4機能が同時に動作するか（相互干渉なし）
- [ ] SharedPrefs データが正しく保存・読み込みされるか
- [ ] Riverpod の状態が正しく更新されるか

### パフォーマンス
- [ ] メモリリーク確認（DevTools Profiler）
- [ ] フレーム落ち確認（60fps 維持か）

### UI/UX
- [ ] ダークテーマで見た目確認
- [ ] 画面サイズ対応確認（5.5" ～ 6.7"）

---

## API連携準備（Phase 4 用）

以下の実装は Sonnet が次のセッションで対応：

### ② Claude API 本実装用に

- [ ] `claude_service.dart` の `askHaiku()` メソッド本実装（モック差し替え）
- [ ] `monthly_usage_provider.dart` 作成（月制限ロジック）
- [ ] `ai_chat_widget.dart` 拡張

### ④ OpenWeatherMap API 用に

- [ ] `sky_provider.dart` 作成（API呼び出し）
- [ ] `today_sky_widget.dart` 作成（表示UI）

### ⑤ Claude Vision 連携用に

- [ ] `creature_identification_service.dart` 作成
- [ ] `creature_collection_provider.dart` 作成

---

## よくある質問

**Q: いつ実装をテストすればいい？**  
A: 各機能の統合が完了した直後に、上記「統合後テスト」セクションを実施。4機能全て完了後に最終統合テストを実施。

**Q: troubleshoot_data.dart を100問全て書くのは時間かかる？**  
A: はい。代わりに、現在の代表例5-10問で 動作検証 → 本番環境で残り90問は別途 AI で生成するアプローチも検討可能。

**Q: バッジアンロック条件はどう実装する？**  
A: `ProfileService.checkBadges()` でアプリ起動時/実験完了時に全バッジ条件を再評価し、新規アンロックがあれば `badgeUnlockedProvider` を更新。

---

**作成日**: 2026-06-10  
**対象**: Sonnet による Phase 3.5 統合実装  
**進捗**: 👈 現在地 Haiku 実装完成、Sonnet 統合待ち
