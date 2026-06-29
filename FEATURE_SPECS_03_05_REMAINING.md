# ③④⑤ 詳細仕様書（簡潔版）

---

## ③ 「おうちラボ」— 週末リアル実験ミッション

**実装期間**: 2026-06-20 〜 2026-07-04（10営業日）  
**優先度**: 🥇 Tier S  
**コスト**: 低

### 概要
週1回、家にあるもので安全にできる実験ミッションを配信。アプリの外 = 本物の理科体験へ誘導。

### データモデル
```dart
class HomeLab Mission {
  final String id;
  final String title;              // 「こおりに しおをかけるとどうなる？」
  final String description;
  final List<String> materials;    // 「氷、塩、糸」
  final int grade;                 // 3-6
  final DateTime publishedAt;      // 金曜夜配信
  final DateTime deadline;         // 翌金曜まで報告可能
}

class HomeLab Report {
  final String missionId;
  final String userId;
  final DateTime submittedAt;
  final String? photoDirect;       // 写真URL（オプション）
  final String resultDescription;  // 「こおりが溶けました」
  final int coinsRewarded;         // +30
}
```

### 画面フロー
```
ホーム → [おうちラボ] → 週末ミッション表示
                    → 「やってみた！」報告ボタン
                    → 写真 + テキスト入力
                    → +30コイン & 限定バッジ
```

### Firestore スキーマ
```
/homeLab/missions/{missionId}
  {
    title, description, materials[], grade, publishedAt, deadline
  }

/users/{userId}/homeLab/{reportId}
  {
    missionId, submittedAt, resultDescription, timestamp
  }
```

### 実装ポイント
- **ミッションデータ**: 52週分プリセット（1年運用）
- **報告機能**: 写真不要（テキストのみで十分）
- **金曜配信**: Cloud Function で自動配信
- **既存資産**: quests_screen.dart のミッション配信ロジック再利用

### KPI
- 報告率：週10+報告（DAU×10%程度）
- 親満足度：「スマホの学習が好きになった」コメント

---

## ④ 「今夜の空」— リアルタイム天体・気象連動

**実装期間**: 2026-07-11 〜 2026-07-25（10営業日）  
**優先度**: 5位  
**コスト**: 中

### 概要
位置情報 + 天文計算で「今日の本物の空」とステージが連動。

### データモデル
```dart
class SkyEvent {
  final DateTime eventTime;
  final String eventType;         // "moon_phase", "planet", "weather"
  final String description;        // 「今夜21時、南の空に木星が見える」
  final String relatedExperimentId;
}

class UserObservation {
  final String skyEventId;
  final String userId;
  final DateTime observedAt;
  final String note;              // 「木星が見えた！」
  final int coinsRewarded;        // +20
}
```

### 外部API
```
OpenWeatherMap (無料枠)：
- 1000 call/day 無料
- 位置情報から天気を取得

Skyfield / Astropy:
- 月齢、惑星位置を計算（オフライン）
- ライブラリ選定：flutter_astro_lib (pub.dev)
```

### 画面フロー
```
ホーム → [今夜の空] セクション追加
  ├─ 「今夜21時、南の空に木星が見える🪐」
  └─ [5年天体ステージへ行く] ボタン
     
クリック後：
  → 天体ステージへ誘導 + ボーナス +20コイン
  → 「観察報告」ボタンで実際に見た記録
```

### 実装ポイント
- **位置情報**: Android/iOS パーミッション設定
- **天気API**: キャッシュ（更新は1時間ごと）
- **天文計算**: オフラインで動作（レイテンシ改善）
- **既存連動**: 天体・天気ステージの「今月のおすすめ」に統合

### KPI
- 該当ステージ試行率：+40% 増加
- 観察報告：週5+

---

## ⑤ 「いきものカメラ」— AI判定図鑑

**実装期間**: 2026-07-25 〜 2026-08-08（10営業日）  
**優先度**: 6位  
**コスト**: 中

### 概要
撮影した虫・花・鳥を Claude Vision で判定 → マイ図鑑に登録。

### データモデル
```dart
class Creature {
  final String id;
  final String name;              // 「ダンゴムシ」
  final String scientificName;    // Armadillidium vulgare
  final String description;       // 「実は昆虫じゃなく..」
  final String imageUrl;
  final List<String> relatedExperiments; // ["exp_003", "exp_004"]
  final bool isSeasonalOnly;      // セミは夏のみ
  final String season;            // "summer"
}

class UserCreatureCollection {
  final String userId;
  final String creatureId;
  final DateTime firstFoundAt;
  final String capturedImageUrl;  // ユーザー撮影
  final int creaturesCollected;   // total count
}
```

### API フロー
```
撮影 → Claude Vision API
  ↓
「これはダンゴムシだね。実は甲殻類（えびやかに仲間）なんだよ」
  ↓
マイ図鑑に登録
  ↓
「捕獲数：23体」バッジ進捗
```

### 画面フロー
```
ホーム → [いきものカメラ] （新規タブ）
  ├─ [カメラボタン] 📷
  │  └─ 撮影 → AI判定
  │     └─ 「ダンゴムシだね」確認
  │        └─ [図鑑に追加] → +コイン
  │
  └─ [マイ図鑑] 
     └─ 收集したいきもの一覧（400体想定）
        └─ 季節別フィルタ
```

### Claude Vision 連携
```dart
Future<String> identifyCreature(File imageFile) async {
  final base64Image = base64Encode(await imageFile.readAsBytes());
  
  const systemPrompt = '''
あなたは理科図鑑のはかせです。
写真から虫・花・鳥を判定し、小学生向けに説明してください。

【フォーマット】
名前：{名前}
説明：{小学生向け説明 2文}
関連実験：{実験IDがあれば}

例：
名前：ダンゴムシ
説明：実は昆虫じゃなくて、えびやかになかま（甲殻類）なんだよ。
丸まるのは敵から身を守るためなんだね。
  ''';
  
  final response = await claudeService.askHaiku(
    'この写真のいきものは？',
    imageBase64: base64Image,
    systemPrompt: systemPrompt,
  );
  
  return response; // JSON parse して図鑑登録
}
```

### Firestore スキーマ
```
/creatureCatalog/{creatureId}
  {
    name, scientificName, description, season, relatedExperiments[]
  }

/users/{userId}/creatureCollection/{collectionId}
  {
    creatureId, capturedAt, capturedImageUrl
  }
```

### 実装ポイント
- **カメラプラグイン**: camera 3.x
- **クロップ機能**: 虫を中央に構図できる UI
- **図鑑構造**: 300体想定（大陸・季節・分類別）
- **既存資産**: キャラクターコレクション画面の UI パターン再利用

### KPI
- 図鑑登録数：ユーザー平均 8体以上
- カメラ使用率：DAU の 15%+
- 季節限定いきもの：「セミは夏だけ」で月1-2回の再訪問

---

## 共通実装ポイント

### 費用概算
| 機能 | API | 月額 |
|-----|-----|------|
| ③おうちラボ | Firebase Functions | ¥100 |
| ④今夜の空 | OpenWeatherMap | 無料 |
| ⑤いきものカメラ | Claude Vision | ¥200-500 |

### 共通セキュリティ
- 画像アップロード：JPEG/PNG のみ、5MB以下
- API キー：Firebase Remote Config で配布
- ユーザーデータ：Firestore で暗号化保存

### 共通分析
```dart
analytics.logEvent(
  name: 'feature_engagement',
  parameters: {
    'feature': 'home_lab' | 'sky_event' | 'creature_camera',
    'action': 'opened' | 'completed' | 'shared',
  },
);
```

### テスト戦略
- **α版**: 社内テスター 2名（1週間）
- **β版**: CBT テスター 20名（1週間）
- **最終**: Google Play Closed Testing 1000名（2週間）

---

## チェックリスト

### ③おうちラボ
- [ ] 52週分のミッション文案作成
- [ ] homeLab_mission_data.dart
- [ ] HomeLab Report UI 実装
- [ ] Cloud Function 金曜配信スクリプト
- [ ] +30コイン付与ロジック

### ④今夜の空
- [ ] OpenWeatherMap API キー設定
- [ ] 天文計算ライブラリ選定（flutter_astro_lib等）
- [ ] 位置情報パーミッション実装
- [ ] SkyEvent Provider
- [ ] ホーム画面への「今夜の空」セクション追加

### ⑤いきものカメラ
- [ ] camera プラグイン設定
- [ ] Claude Vision API テスト
- [ ] creatureCatalog 400体データ整備
- [ ] いきものカメラ UI 実装
- [ ] 図鑑メイン画面

---

**作成日**: 2026-06-10  
**版**: 1.0（簡潔版）  
**詳細設計書**: 実装開始時に各機能ごと展開
