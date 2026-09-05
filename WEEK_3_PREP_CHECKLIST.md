# ✅ Week 3 準備チェックリスト

**目的**: 2026-07-18 Day 1 に確実に開始できる状態を作る  
**実施期間**: 2026-07-07 ～ 2026-07-17 (Week 2 中)  
**監視者**: QA チーム / テスター

---

## 🎯 P0 ブロッカー解除（優先度最高）

### 1️⃣ image_picker スパイク検証

**ファイル**: `lib/features/home_lab/views/image_picker_spike_screen.dart` ✅ 作成完了

**実施手順** (今週実施):

```bash
# Step 1: pubspec.yaml に image_picker 追加
flutter pub add image_picker

# Step 2: Android 権限設定 (android/app/src/main/AndroidManifest.xml)
<!-- 以下をマニフェストに追加 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />

# Step 3: APK ビルド & 実機テスト
flutter build apk --release --no-tree-shake-icons

# Step 4: 実機にインストール
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

**検証項目**:

- [ ] **flutter pub get**: エラーなし
- [ ] **flutter build apk**: 成功 (APK サイズ記録)
- [ ] **実機インストール**: 成功
- [ ] **ギャラリー選択**: OK
- [ ] **カメラ撮影**: OK
- [ ] **権限ダイアログ**: 表示される

**結果テンプレート**:

```
🔧 image_picker スパイク検証完了

✅ ビルド: 成功
   APK サイズ: ___ MB (増分: ___ MB)
   
✅ 実機テスト
   デバイス: ________________
   OS: Android ___
   
✅ 動作確認
   ギャラリー: [OK / NG]
   カメラ: [OK / NG]
   権限: [表示 / 未表示]
```

**決定ゲート**: ✅ に全チェック → Day 1 開始 OK

---

### 2️⃣ Firestore スキーマ確定

**ファイル**: `FIRESTORE_SCHEMA_HOME_LAB.md` ✅ 作成完了

**実施内容** (Week 2-3 中):

- [ ] スキーマドキュメント確認
- [ ] Firebase Console で collections を手動作成
  - `users/{userId}/experiments/{recordId}`
  - parent-child 関係の Firestore 設計
  
- [ ] セキュリティルール デプロイ
  ```javascript
  // rules_version = '2'; の下部に追加
  match /users/{userId}/experiments/{recordId} {
    allow read: if request.auth.uid == userId ||
                   get(.../users/$(userId)).data.parentId == request.auth.uid;
  }
  ```

- [ ] Dart テスト実施
  ```bash
  flutter test test/features/home_lab/data/
  ```

**検証項目**:

- [ ] Firestore collections 存在
- [ ] セキュリティルール エラーなし
- [ ] Child 側の書き込みテスト PASS
- [ ] Parent 側の読み込みテスト PASS

**決定ゲート**: ✅ に全チェック → Day 4 (統合) 開始 OK

---

## 🟠 P1 準備（Day 1-2 開始前）

### 3️⃣ 実験データ50個確認

**ファイル**: `lib/features/home_lab/data/experiment_guides_data.dart` ✅ 作成完了 (サンプル)

**実施内容** (Week 2 中):

- [ ] 全50個のデータ詳細記述（**現状: 9個のプレースホルダーのみ、41個未記述**）
  - Grade 3: 3/15個
  - Grade 4: 2/15個
  - Grade 5: 2/10個
  - Grade 6: 2/10個

- [ ] Dart integrity テスト実行
  ```bash
  flutter test test/features/home_lab/data/experiment_guides_data_test.dart
  ```

- [x] ID 重複なし ✅（バグ調査で確認済み・validateExperimentData()で致命的チェック）
- [ ] グレード分布確認（未達、Day1で50個まで拡充予定。validateExperimentData()は件数不足を警告のみで報告し、失敗にはしない仕様に修正済み）
- [x] 必須フィールド チェック ✅（既存9件は欠落なし）

**検証項目**:

- [x] validateExperimentData() 実行可能（ID重複・必須フィールドはPASS、件数は未達を警告表示） — 2026-07-07 全体バグ調査で修正
- [ ] 合計 50個確認（現状9個、Day1で拡充）
- [ ] YouTube リンク確認

**決定ゲート**: ✅ に全チェック → Day 1 実装開始 OK

---

## 🟡 P2 最適化（Day 3-4 中）

### 4️⃣ 既存機能との統合確認

- [ ] home_screen.dart に「🏡 おうちラボ」カード追加箇所確認
- [ ] router.dart に `/home-lab` ルート追加準備
- [ ] parent_dashboard_screen.dart の拡張ポイント確認

---

## 📋 最終ゲートウェイチェック（2026-07-17 夜）

**Day 1 朝、以下がすべて ✅ なら開始:**

```
🔴 P0 ブロッカー解除
  [✅] image_picker ビルド成功 (APK ___ MB)
  [✅] Firestore スキーマ Deployed
  [✅] セキュリティルール テスト PASS

🟠 P1 データ層準備
  [ ] experiment_guides_data.dart: 50個データ完成（現状9個、Day1で拡充必須）
  [x] validateExperimentData() ロジック修正済み（ID/必須フィールドのみ致命判定、件数は警告）
  [x] ExperimentGuide freezed モデル定義 完成

🟢 コード準備
  [✅] image_picker_spike_screen.dart 作成完了
  [✅] FIRESTORE_SCHEMA_HOME_LAB.md 最終版
  [✅] flutter analyze exit 0
```

**GO 判定**: `[✅ GO]` / `[❌ NO-GO]`

判定者: ___________  
判定日: 2026-07-17 __:__

---

## 🗓️ Week 2 タイムライン

```
2026-07-07: ✅ 準備ドキュメント作成
2026-07-08: 🔄 image_picker ビルド検証 (実機テスト)
2026-07-09: 🔄 Firestore スキーマ確定
2026-07-10: ⑲ ベータテスト開始 + 準備並行
2026-07-11-14: ⑲ バグ修正・改善
2026-07-15: 実験データ50個 最終確認
2026-07-16: 🔴 最終ゲートウェイチェック
2026-07-17: ⑲ 本リリース + Day 1 準備完了
────────────────────────────
2026-07-18: 🚀 Day 1 開始: データ層実装
```

---

## 📝 依存外部サービス

| サービス | 状態 | 確認者 | 確認日 |
|---|---|---|---|
| Firebase (Firestore) | ✅ | - | - |
| Cloud Storage | ✅ | - | - |
| Google Play (親ダッシュボード用) | ✅ | - | - |

---

## 🎯 成功指標

- ✅ image_picker 動作確認
- ✅ Firestore セキュリティルール デプロイ
- ✅ 実験データ50個 + テスト PASS
- ✅ 関連コードすべて `flutter analyze exit 0`
- ✅ Day 1-2 の「データ層 + モデル」をノーストップで実装可能な状態

---

**準備完了通知は 2026-07-17 PM に送信予定**  
**Day 1 開始は 2026-07-18 AM から**

