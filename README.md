# 小学コレ！理科

小学生が4択クイズ・バッジ・ランキングで理科を楽しく続けられるスマホアプリ

## 📋 プロジェクト情報

```
アプリ名：     小学コレ！理科
対象OS:       iOS / Android 両対応
言語:         Dart（Flutter）
アーキテクチャ: MVVM（Riverpod）
対象ユーザー:  小学1〜6年生
マネタイズ:   フリーミアム（2週間無料 + ¥300/月 or セット ¥1,200/月）
```

## 🚀 セットアップ

### 前提条件
- Flutter 3.x
- Dart 3.x

### インストール

```bash
# 依存関係をインストール
flutter pub get

# コード生成を実行（Riverpod）
dart run build_runner build

# アプリを実行
flutter run
```

## 📐 技術スタック

| カテゴリ | 技術 | バージョン |
|---------|------|-----------|
| UI       | Flutter | 最新安定版 |
| 言語     | Dart | 3.x |
| 状態管理 | Riverpod | 2.x |
| DB       | Firebase Firestore | - |
| 認証     | Firebase Auth | - |
| 課金     | RevenueCat | - |
| ルーティング | GoRouter | - |

## 📂 プロジェクト構成

```
lib/
├── main.dart                    # エントリーポイント
├── app/
│   ├── router.dart             # GoRouter定義
│   └── theme.dart              # テーマ設定
├── features/                   # 機能別モジュール
├── shared/
│   ├── widgets/                # 共有ウィジェット
│   └── constants/              # 定数
└── services/                   # 外部サービス統合
```

## 🎯 実装フェーズ

### Phase 0: プロジェクト初期化 ✅
- [x] Flutter プロジェクト作成
- [x] pubspec.yaml 設定
- [x] ディレクトリ構成
- [ ] Firebase 設定

### Phase 1: 基本機能（開発中）
- [ ] 認証機能
- [ ] ホーム画面
- [ ] クイズ画面
- [ ] 学習履歴記録

### Phase 2: ゲーミフィケーション
- [ ] バッジシステム
- [ ] ランキング

### Phase 3: 親向け機能
- [ ] スターマスター

### Phase 4: スマートメニュー
- [ ] AI 難易度選択
- [ ] 学習タイマー

### Phase 5: テスト・最適化
- [ ] ユニットテスト
- [ ] パフォーマンス最適化
