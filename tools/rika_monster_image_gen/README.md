# ⑬まちがい図鑑モンスター画像 生成ツール

`card_crown/tools/seed_card_image_gen/` の構成を移植。学年(3-6) × 進化段階(baby/juvenile/adult/sage) の
固定16種を生成し、`assets/images/monsters/` に直接保存する。

## 実行前の準備

1. Leonardo.ai または Replicate の APIキーを取得（後述）
2. PowerShellで環境変数に設定（**このターミナルセッション限り**）
   ```powershell
   $env:LEONARDO_API_KEY="xxxx"
   # または
   $env:REPLICATE_API_TOKEN="r8_xxxx"
   ```
3. Node.js が使えること（`node --version` で確認）

## 実行手順

```bash
cd "H:\マイドライブ\apps\shokollen_science\tools\rika_monster_image_gen"

# Step 1: サンプル2枚だけ生成して品質確認
node generate_leonardo.js --count 2

# Step 2: 生成された assets/images/monsters/grade3_baby.png などを確認
#         気に入らなければプロンプトを prompt_builder.js で調整して --force で再生成

# Step 3: 問題なければ残り全部を一括生成
node generate_leonardo.js --all
```

Replicateを使う場合は `generate.js` を同様に実行（`generate_leonardo.js` → `generate.js`）。

## 生成される16ファイル

`assets/images/monsters/grade{3,4,5,6}_{baby,juvenile,adult,sage}.png`

| | baby (たまご) | juvenile (幼生) | adult (成体) | sage (博士) |
|---|---|---|---|---|
| Grade 3 (昆虫・植物テーマ) | grade3_baby.png | grade3_juvenile.png | grade3_adult.png | grade3_sage.png |
| Grade 4 (天気・水テーマ) | grade4_baby.png | grade4_juvenile.png | grade4_adult.png | grade4_sage.png |
| Grade 5 (結晶・化学テーマ) | grade5_baby.png | grade5_juvenile.png | grade5_adult.png | grade5_sage.png |
| Grade 6 (山・宇宙テーマ) | grade6_baby.png | grade6_juvenile.png | grade6_adult.png | grade6_sage.png |

Flutter側は `lib/features/progress/views/widgets/monster_image.dart` の `MonsterImage` ウィジェットが
このパス規則で `Image.asset()` を呼ぶ。ファイルが存在しない間は自動的に絵文字（😢😕😐😊）表示にフォールバックするため、
生成前でもアプリは正常動作する。

## コスト目安

- Leonardo Phoenix 1.0 / alchemy:off / 512×512: 16枚で数クレジット程度（Card Crown実績ベース）
- 既存ファイルは自動スキップされるため、`--all` を何度実行しても未生成分のみ課金される

## APIキー取得手順

- **Leonardo**: cloud.leonardo.ai にログイン → Platform > API Access
- **Replicate**: replicate.com にサインアップ → replicate.com/account/api-tokens

## 生成後の確認

```bash
cd "H:\マイドライブ\apps\shokollen_science"
flutter pub get
```

その後 build-flutter-apk スキルでAPKビルド→実機確認、または `flutter run` でホットリロード確認。
