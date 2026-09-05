# 実装ガイド: ⑲ 理科おみくじ（Rikka Omikuji - Science Daily Mystery）

**開始日**: 2026-07-02 | **推定工期**: 1 週間 | **優先度**: 🥉次々優先

---

## 📋 概要

**機能名**: 理科おみくじ / Science Daily Mystery  
**説明**: 毎朝 1 回引くと「今日のふしぎ」が出て、夜に答え合わせする 1 分習慣化装置  
**心理学的効果**: 日常的な科学への接触、習慣化、DAU 向上  
**期待効果**: DAU +20%、継続率 +10-15%

---

## 🎯 機能仕様

### 画面フロー

```
ホーム画面
  ↓
[📿 今日のふしぎを引く] バッジ
  ↓
おみくじ画面（アニメーション）
  ↓
「🤔 なぜ空は青い？」表示
  ↓
[後で答えを見る] ボタン
  ↓
ホーム画面に戻る
  ↓
夜（18:00 以降）
  ↓
答え表示「空が青く見える理由は...」
```

### データ構造

```dart
@freezed
class DailyMystery with _$DailyMystery {
  const factory DailyMystery({
    required int id,                    // 1-365
    required String question,           // 「なぜ空は青い？」
    required String answer,             // 答え（ふりがな付き）
    required String category,           // 「天体」など
    required int grade,                 // 3-6
    required DateTime createdAt,
  }) = _DailyMystery;
}

@freezed
class DailyMysteryRecord with _$DailyMysteryRecord {
  const factory DailyMysteryRecord({
    required String userId,
    required int mysteryId,
    required DateTime revealedAt,       // おみくじ引いた日時
    required DateTime? answeredAt,      // 答え見た日時
    required bool isCorrect,            // 予想が正解か
  }) = _DailyMysteryRecord;
}
```

---

## 📊 実装内容

### Data Layer（データ層）

**ファイル一覧:**
- `daily_mystery.dart` — モデル定義（freezed）
- `daily_mystery_repository.dart` — Repository
- `daily_mystery_provider.dart` — Riverpod Provider

**内容:**
- 365 個のふしぎデータ（自動生成 or 手動入力）
- ユーザーの引いた履歴管理
- 本日分の取得ロジック

### UI Layer（UI層）

**ファイル一覧:**
- `daily_mystery_omikuji_screen.dart` — おみくじ引く画面
- `home_screen.dart` 修正 — バッジ追加
- `router.dart` 修正 — ルート追加

**仕様:**
- 🎀 おみくじアニメーション（回転、スローダウン）
- 📝 ふしぎテキスト表示（ふりがな付き）
- ⏰ 夜 18:00 以降に答え表示
- 🔔 プッシュ通知（朝 7:00、夜 18:00）

---

## 🛠️ 実装タスク（1週間）

### Day 1: データ層 ✅ 完成
- [x] `daily_mystery.dart` — モデル定義 (freezed)
- [x] `daily_mystery_repository.dart` — Repository (SharedPreferences)
- [x] `daily_mystery_provider.dart` — Provider (Riverpod StateNotifier)
- [x] 365 個のふしぎデータ生成 (daily_mysteries_data.dart)
- [x] Repository テスト 7本
- [x] Provider テスト 4本

### Day 2: UI 基本 ✅ 完成
- [x] `daily_mystery_omikuji_screen.dart` — 基本 UI (350行)
- [x] おみくじアニメーション実装 (RotationTransition)
- [x] ふりがな対応確認 (FuriganaText使用)
- [x] ホーム画面へのバッジ追加 (_buildDailyMysteryBadge)
- [x] ルート統合 (/daily-mystery-omikuji)
- [x] UI テスト 10本

### Day 3-4: 統合 + テスト ✅ 完成
- [x] コード分析 (dart analyze) — 0エラー、文法完全確認
- [x] ホーム画面バッジの状態同期 ✅
- [x] ルート統合検証 ✅

### Day 5: プッシュ通知 ✅ 完成
- [x] flutter_local_notifications 統合 (DailyMysteryNotificationService)
- [x] 朝 7:00 / 夜 18:00 スケジュール (timezone対応)
- [x] ローカルタイムゾーン対応 (tz.local)
- [x] main.dart統合 (初期化とスケジュール自動実行)
- [x] Provider統合 (daily_mystery_notification_provider.dart)
- [x] テスト 6本

### Day 6-7: ポーリッシュ + QA 🔄 準備中
- [ ] UI ポーリッシュ（アニメーション調整）
- [ ] 実機テスト
- [ ] ベータテスター配布
- [ ] バグ修正 & 最適化

---

## 📝 データ例

```
Mystery ID: 1
Question: 「なぜ空は青いのかな？」
Answer: 「太陽の光は、いろいろな色の光が集まっています。空の{分子|ぶんし}が、青い光を{散乱|さんらん}させるから、空は青く見えます。」
Category: 「天体」
Grade: 3

Mystery ID: 2
Question: 「なぜ葉は緑色？」
Answer: 「葉は、{光合成|こうごうせい}をするために、太陽の光の中でも、特に赤い光と青い光をよく{吸収|きゅうしゅう}します。赤と青を吸収すると、残った緑の光だけが{反射|はんしゃ}されるから、葉は緑に見えるんです。」
Category: 「生命」
Grade: 4
```

---

## 🎨 UI デザイン

### おみくじ画面

```
┌────────────────────────────────┐
│                                │
│        🎀 今日のふしぎ 🎀     │
│                                │
│        ┌──────────────┐       │
│        │ (回転中...)  │ ← アニメ
│        │   🤔         │       │
│        └──────────────┘       │
│                                │
│      スローダウン...           │
│                                │
│        「なぜ空は青い？」      │
│                                │
│    [後で答えを見る] [すぐ見]   │
│                                │
└────────────────────────────────┘
```

### ホーム画面バッジ

```
┌─────────────────────────────┐
│ 📿 今日のふしぎ              │ ← タップで遷移
│ 未引 / 引いた / 答え済み     │
└─────────────────────────────┘
```

---

## 📊 データ生成戦略

### 365 個のふしぎ作成

**方法 1: 自動生成（推奨）**
```dart
// AI がふりがなを自動生成
List<DailyMystery> generateMysteries() {
  final questions = [
    '「なぜ空は青いのかな？」',
    '「なぜ虹は 7 色？」',
    '「なぜ月の形は変わる？」',
    // ... 365 個
  ];

  return questions.map((q) => DailyMystery(
    id: questions.indexOf(q) + 1,
    question: q,
    answer: generateAnswerWithFurigana(q),  // AI
    category: extractCategory(q),
    grade: estimateGrade(q),
    createdAt: DateTime.now(),
  )).toList();
}
```

**方法 2: CSV インポート**
- `assets/data/daily_mysteries.csv`
- 列: id, question, answer, category, grade

---

## 🔔 プッシュ通知

### スケジュール

| 時刻 | メッセージ | 内容 |
|---|---|---|
| 朝 7:00 | 「おはよう！今日のふしぎを引こう」 | おみくじ画面へ |
| 夜 18:00 | 「答えの時間です 🎉」 | 答え表示 |

### 実装

```dart
void scheduleDailyNotifications() {
  // 朝 7:00
  flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    '📿 今日のふしぎ',
    'おはよう！今日のふしぎを引こう',
    nextMorning7AM(),
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    matchDateTimeComponents: DateTimeComponents.time,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );

  // 夜 18:00
  flutterLocalNotificationsPlugin.zonedSchedule(
    1,
    '🎉 答えの時間',
    '今日のふしぎの答えが出ました',
    nextEvening6PM(),
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
```

---

## 📋 実装チェックリスト

### Week 1

- [ ] **Day 1: データ層**
  - [ ] モデル定義（daily_mystery.dart）
  - [ ] Repository 実装
  - [ ] Provider 実装
  - [ ] 365 個のふしぎデータ作成 or CSV 生成

- [ ] **Day 2: UI 基本**
  - [ ] daily_mystery_omikuji_screen.dart
  - [ ] おみくじアニメーション（RotationTransition）
  - [ ] テキスト表示（ふりがな対応）

- [ ] **Day 3: 統合**
  - [ ] ホーム画面バッジ追加
  - [ ] ルーター統合
  - [ ] 本日分取得ロジック

- [ ] **Day 4: テスト**
  - [ ] ユニットテスト（15-20 個）
  - [ ] UI テスト
  - [ ] 実機テスト

- [ ] **Day 5: プッシュ通知**
  - [ ] flutter_local_notifications 設定
  - [ ] 朝 7:00 スケジュール
  - [ ] 夜 18:00 スケジュール

- [ ] **Day 6-7: ポーリッシュ**
  - [ ] アニメーション調整
  - [ ] エラーハンドリング
  - [ ] ベータテスト配布

---

## 🚀 成功指標

| KPI | 目標 | 測定方法 |
|---|---|---|
| DAU | +20% | Analytics |
| 継続率 7 日 | +10-15% | Retention |
| おみくじ引率 | 70%+ | Custom event |
| 答え確認率 | 50%+ | Custom event |

---

## 📌 技術ポイント

1. **タイムゾーン対応**: ユーザーのローカル時刻で 7:00 / 18:00 判定
2. **本日分キャッシュ**: 当日のおみくじは保存して、再読み込みで同じものを表示
3. **ふりがな**: FuriganaText ウィジェット既存利用
4. **アニメーション**: RotationTransition + AnimationController
5. **オフライン対応**: 365 個のデータは assets に内蔵

---

## 💾 工数見積もり

| タスク | 工数 | 優先度 |
|---|---|---|
| モデル + Repository | 4h | 🔴 |
| UI + アニメーション | 6h | 🔴 |
| 統合 + テスト | 4h | 🟡 |
| プッシュ通知 | 4h | 🟡 |
| ポーリッシュ | 4h | 🟡 |
| **合計** | **22h** | — |

**1 週間（40h）で十分（余裕あり）**

---

## 📚 関連ドキュメント

- [テストチェックリスト](TESTING_CHECKLIST_RIKKA_OMIKUJI.md) — 実機テスト項目 (50+ チェック)
- [ベータ配布ガイド](BETA_DISTRIBUTION_GUIDE.md) — テスター配布手順・テンプレート
- [実装ガイド（本ファイル）](IMPL_RIKKA_OMIKUJI.md) — データ層・UI・通知実装詳細

## 🎯 Next Steps

### Week 1 完了 ✅
1. ✅ Days 1-5: フル実装 + テスト
2. ✅ テストチェックリスト作成
3. ✅ ベータ配布ガイド作成

### Week 2 予定
1. 📅 Days 6-7: UI ポーリッシュ + 実機テスト
2. 📅 ベータテスト (2026-07-10 ~ 07-16)
3. 📅 本リリース (2026-07-17)
4. 📅 Google Play 申請 (2026-07-18)

---

## 📊 全体ロードマップ

```
Phase 3-1: ⑲ 理科おみくじ (Week 1)
  ↓ リリース
Phase 3-2: ⑪ おうち実験キット (Week 2-6)
  ↓
Phase 3-3: ⑮ 理科ディベート (Week 7-9)
```

