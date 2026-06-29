# 小学コレ！理科 (shokollen_science) — プロジェクト概要

## 🎯 プロジェクト コンセプト

**対象**: 小学3〜6年生（8〜12歳）の理科学習  
**目的**: ゲーミフィケーションで自宅学習を楽しく、習熟度を高める  
**価格**: 月¥100 / 買い切り¥1,000  
**リリース目標**: 2026年9月

---

## 📱 主要機能

### 1. **ステージ別クイズシステム**
- **3年生**: 大地、天気、植物、生き物（5実験）
- **4年生**: 物質、電気、音、力（5実験）  
- **5年生**: 化学変化、天体、エネルギー、遺伝（5実験）
- **6年生**: 地球環境、進化、生態系、人体（5実験）
- **合計 20実験**、各5ステージ（難度: 簡単→むずかしい）

### 2. **4つのクイズモード**
- **逆実験**: 結果から現象を推測
- **失敗ラボ**: 誤った結果を選ぶ（ネガティブ学習）
- **クイズ**: 標準的な選択問題
- **タイマークイズ**: 制限時間内で解く

### 3. **進捗・達成システム**
- **デイリーボーナス**: ログインで1回/日、10コイン獲得
- **ウィークリーチャレンジ**: 動的ミッション生成、完全クリアで50コイン
- **17個のバッジ**: 6カテゴリ（習熟度、スピード、連続クリアなど）
- **学年末まとめテスト**: 20問、合格で証明書発行

### 4. **キャラクターコレクション**
- **16体のキャラクター**: 理科テーマ（磁石、電球、化学反応など）
- **解放条件**: 特定ステージをクリア
- **コインショップ**: 集めたコインで買い物

### 5. **成長タイムライン**
- **月次レポート**: 棒グラフで週別進捗を表示
- **親向け機能**: クリア時に親へのほめメッセージ表示

### 6. **ソーシャル機能**
- **ほめカード生成**: SNS共有用のビジュアルカード
- **友達招待**: 招待コード生成で「ともコレ報酬」獲得

---

## 🎮 ゲーム体験フロー

```
ログイン
  ↓
[デイリーボーナス] → コイン +10
  ↓
ホーム画面
  ├─ [実験を選ぶ] → クイズモード選択 → 4ステップ × 最大4モード
  ├─ [親子バトル] → 5ラウンド対戦 → 親がほめる
  ├─ [ウィークリー] → 動的ミッション → コイン +50 (完全クリア時)
  ├─ [バッジ] → 17個の進捗表示
  ├─ [キャラ] → 16体コレクション → コインショップ
  ├─ [成長] → 月次レポート（棒グラフ）
  └─ [タイムトラベル] → 4つのスペシャルミッション

クイズクリア
  ↓
[親ほめダイアログ] → スコア保存 → Riverpod更新
  ↓
[ほめカード] → SNS共有
```

---

## 🏗️ 技術スタック

| 技術 | 用途 |
|------|------|
| **Flutter 3.44** | iOS/Android/Web |
| **Riverpod 2.6** | 状態管理 |
| **Go Router 13.2** | ルーティング |
| **Firebase Core 3.15** | バックエンド（未実装） |
| **Firestore 5.6** | クロスデバイス同期（未実装） |
| **RevenueCat** | 課金管理（未実装） |
| **Claude Haiku API** | AI対話（モック実装） |
| **shared_core 0.1** | ローカルパッケージ（バッジ、キャラクター共有） |

---

## 📂 プロジェクト構成

```
lib/
├── app/
│   ├── router.dart           # Go Router設定、スプラッシュ→オンボーディング→ホーム
│   └── theme.dart            # ダークテーマ（デフォルト）
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── app_router.dart
├── data/
│   ├── models/
│   │   ├── experiment.dart      # Experiment, ExperimentStep, ExperimentResult
│   │   ├── child_profile.dart   # ChildProfile, ProfileAvatar(6種)
│   │   └── badge_definition.dart # BadgeDefinition, BadgeRegistry(17個)
│   ├── services/
│   │   ├── profile_service.dart  # SharedPrefs保存、ログイン記録
│   │   └── claude_service.dart   # Claude Haiku API（モック）
│   └── rika_characters.dart      # 16キャラクター定義
├── features/
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │       ├── grade_section_widget.dart
│   │       └── menu_button_widget.dart
│   ├── experiments/
│   │   ├── data/
│   │   │   └── experiments_data.dart (20実験定義)
│   │   ├── providers/
│   │   │   └── experiment_provider.dart
│   │   ├── screens/
│   │   │   ├── experiment_detail_screen.dart
│   │   │   └── experiment_play_screen.dart
│   │   └── widgets/
│   │       ├── step_indicator_widget.dart
│   │       ├── choice_widget.dart
│   │       ├── result_widget.dart
│   │       └── ai_chat_widget.dart
│   ├── profile/
│   │   ├── providers/
│   │   │   └── profile_provider.dart
│   │   ├── screens/
│   │   │   ├── profile_select_screen.dart
│   │   │   └── add_profile_screen.dart
│   ├── onboarding/
│   │   └── screens/
│   │       └── onboarding_screen.dart
│   ├── battle/
│   │   └── screens/
│   │       └── battle_screen.dart (親子バトル 5ラウンド)
│   ├── time_travel/
│   │   └── screens/
│   │       └── time_travel_screen.dart (4ミッション)
│   ├── quests/
│   │   └── screens/
│   │       └── quests_screen.dart (デイリー/ウィークリー)
│   ├── weekly/
│   │   ├── models/
│   │   │   └── weekly_challenge.dart
│   │   ├── providers/
│   │   │   └── weekly_provider.dart
│   │   └── screens/
│   │       └── weekly_challenge_screen.dart
│   ├── badges/
│   │   └── screens/
│   │       └── badges_screen.dart (17バッジ、6カテゴリ)
│   ├── daily/
│   │   └── widgets/
│   │       └── daily_bonus_dialog.dart
│   ├── parent/
│   │   └── screens/
│   │       └── parent_praise_dialog.dart
│   ├── praise/
│   │   └── screens/
│   │       └── praise_card_screen.dart
│   ├── growth/
│   │   └── screens/
│   │       └── growth_capsule_screen.dart
│   └── invite/
│       └── screens/
│           └── invite_screen.dart
├── providers/
│   └── character_provider.dart
└── main.dart
```

---

## 🎯 実装フェーズ

| フェーズ | 期間 | 状態 | 内容 |
|---------|------|------|------|
| **Phase 1** | Week 1-2 | ✅ 完了 | 実験UI、4モード、プロフィール |
| **Phase 2** | Week 3-4 | ✅ 完了 | ホーム、20実験、バトル、クエスト |
| **Phase 3** | Week 5-6 | ✅ 完了 | デイリー、ウィークリー、タイムトラベル、バッジ |
| **Phase 4** | Week 7-8 | 🔲 未着手 | **Firebase実装**、AR初期化、実験エディター |
| **Phase 5** | フェーズ2 | 🔲 未着手 | AR本格実装、学校ダッシュボード |

---

## 🚀 次のステップ（Priority順）

1. **Firebase設定** (Phase 4)
   - Firebase Console でプロジェクト作成
   - Google認証の実装
   - Firestore スキーマ設計
   - クロスデバイス同期

2. **RevenueCat 連携** (課金)
   - サブスクリプション設定（月¥100）
   - 買い切り設定（¥1,000）
   - PaymentWall / Stripe 連携

3. **Google Play申請**
   - スクリーンショット撮影（4枚）
   - プライバシーポリシー作成
   - アプリ説明文翻訳
   - テスター招待

4. **音声・アニメーション強化** (UX改善)
   - flutter_tts の本実装
   - ほめメッセージの声読み上げ
   - Lottie アニメーション追加

---

## 🔧 開発環境

- **Flutter**: 3.44.0 (stable)
- **Dart**: 3.12.0
- **Android SDK**: API 36
- **NDK**: flutter.ndkVersion
- **Java**: 17 (JDK 21.0.11)

### ビルド手順

```bash
# APK (リリース)
cd "H:\マイドライブ\apps\shokollen_science"
flutter pub get
flutter build apk --release

# Web (確認用)
flutter build web

# AAB (Google Play用) ※環境セットアップが必要
flutter build appbundle --release
```

---

## 📌 重要な設定

### pubspec.yaml
- `shared_core`: ローカルパッケージ（`H:\マイドライブ\apps\shared_core`）
- バッジ、キャラクターシステム、コインショップが shared_core から提供

### android/gradle.properties
```
android.overridePathCheck=true
android.debugSymbolFormat=dwarf
android.bundleConfig.enableSplit=false
```

### android/app/build.gradle.kts
- Kotlin Gradle Plugin 非推奨警告（Future migration needed）
- `packagingOptions` でネイティブライブラリ競合を回避

---

## 👥 ユーザーペルソナ

- **子ども**: 小学3〜6年生、ゲーム好き、親との関わりを求める
- **親**: 子どもの学習を見守りたい、ほめたい、進捗を知りたい
- **学校**: 補助教材として利用、クラス全体の統計を確認

---

## 🎨 UI/UX 特徴

- **ダークテーマ優先**: 目に優しい、夜間学習対応
- **キャラクターキュートさ**: 理科要素を可愛らしく表現
- **親向けUI**: 親子バトル、ほめダイアログで関わりを深める
- **進捗の可視化**: バッジ、棒グラフ、ストリーク表示で達成感

---

## 📊 プロジェクト統計

- **ファイル数**: 38（models, screens, widgets, providers）
- **実験数**: 20（3〜6年生各5個）
- **キャラクター数**: 16（理科テーマベース）
- **バッジ数**: 17（6カテゴリ）
- **API連携**: Firebase(未), Claude Haiku(モック), RevenueCat(未)

---

## ⚙️ ビルド状態

| ターゲット | 状態 | サイズ | 備考 |
|-----------|------|--------|------|
| APK (release) | ✅ 成功 | 57.36 MB | H:\マイドライブ\apk\shokollen_science-app-release.apk |
| AAB (release) | ❌ 失敗 | — | NDK debug symbol strip エラー |
| Web | ✅ 可能 | — | 動作確認用 |

---

**Last Updated**: 2026-06-10  
**Version**: v0.9.0 (Phase 3 完了)  
**Next Release Target**: 2026-09-01
