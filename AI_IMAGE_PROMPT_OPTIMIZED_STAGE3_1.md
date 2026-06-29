# Stage 3-1: 昆虫と植物の観察 — 最適化プロンプト（Leonardo.AI）

## キャラクター設定（参考画像ベース）
- **見た目**: 子ども（3Dアニメ風、Pixar/Dreamworks style）
- **服装**: 青いフード付きジャケット、赤いバックパック、青いズボン
- **アイテム**: 金色の虫眼鏡
- **環境**: 花が咲いている庭、明るい昼間、蝶やテントウムシが飛んでいる
- **雰囲気**: 好奇心、発見、楽しい学習体験

---

## 🎯 最適化プロンプト（Leonardo.AI用）

### プロンプト
```
A curious 3D-style elementary school child wearing a bright blue hood jacket and red backpack, 
holding a golden magnifying glass and observing insects in a vibrant sunlit garden. 
The child has large expressive eyes, rosy cheeks, and a joyful smile of discovery.
Background: lush flower garden with colorful blooms (yellow sunflowers, pink cosmos, blue flowers), 
realistic green grass, and warm natural sunlight creating soft shadows.
Insects visible: monarch butterflies, ladybugs, grasshoppers, with semi-realistic detailed design.
Art style: High-quality 3D illustration (Pixar/Dreamworks), detailed proportions, 
realistic lighting with golden hour glow. Educational, warm, encouraging atmosphere.
Perfect for elementary school science education. Ultra high quality, 4K, professional render.
```

### ネガティブプロンプット
```
low quality, blurry, dark, scary insects, distorted child, unrealistic proportions, 
bad hands, floating objects, text, watermark, overly cartoonish, 2D flat
```

### 推奨 Leonardo.AI 設定
- **Model**: Leonardo Kino XL（3D表現に最適）
- **Quality**: High / Unfiltered
- **Guidance Scale**: 7-8
- **Steps**: 80-100
- **Style**: Illustration, 3D Render, Pixar-style
- **Aspect Ratio**: 1:1 or 4:3（アプリ用途に応じて）

---

## 📊 プロンプト改善ポイント

| 要素 | 理由 | 効果 |
|------|------|------|
| **3D-style** | 参考画像の高品質感を再現 | より洗練された出力 |
| **golden magnifying glass** | 中心アイテムを明示 | 観察シーンが強調される |
| **monarch butterflies** | 具体的な昆虫指定 | 科学的正確性 |
| **Pixar/Dreamworks** | 参考画像のスタイル明示 | キャラの雰囲気を正確に再現 |
| **golden hour glow** | 照明を具体的に指定 | 温かみのあるリアルな光 |

---

## 🎨 バリエーションプロンプト

### バリ1：ズーム・クローズアップ版
```
Close-up shot: A joyful child's face with blue hood, magnifying glass held up to eye, 
observing a beautiful monarch butterfly perched on a pink flower. 
Shallow depth of field, butterfly in sharp focus, garden background blurred.
3D Pixar-style, professional render, educational, magical discovery moment.
```

### バリ2：複数の昆虫観察版
```
[上記のベースプロンプト] + "Child examining multiple insects: on the ground observing an ant line, 
in hand holding a ladybug, and looking at butterflies above. Multiple points of curiosity and discovery shown simultaneously."
```

### バリ3：学習コンテンツ版（説明テキスト付き推奨境）
```
[上記のベースプロンプット] + "Educational illustration for elementary science textbook. 
Clean, clear composition. Suitable for print and digital media. No shadow obstruction of subjects."
```

---

## 🚀 実行手順（Leonardo.AIで生成）

### Step 1: ページアクセス
1. leonardo.ai を開く
2. 右上「Create」→「Image Generation」

### Step 2: プロンプト入力
1. メインプロンプット欄に上記プロンプトをコピペ
2. ネガティブプロンプット欄にネガティブプロンプットを入力

### Step 3: 設定調整
```
Model:               Leonardo Kino XL
Quality:             High
Guidance Scale:      7.5
Steps:               80
Aspect Ratio:        1:1
Style Preset:        Illustration + 3D Render
```

### Step 4: 生成
1. 「Generate」をクリック
2. **5〜8分待機**（High品質のため時間がかかる）

### Step 5: 出力確認
- 生成後、ギャラリーから選択
- 必要に応じて Upscale（2x / 4x）を適用
- ダウンロード保存

---

## 📁 ファイル保存

### 推奨保存パス
```
H:\マイドライブ\apps\shokollen_science\assets\
└── stage_3_illustrations\
    └── stage_3_001_insect_observation_leonardo_v1.png
```

### ファイル命名規則
```
stage_3_00X_[scene]_leonardo_[version].png
例: stage_3_001_insect_observation_leonardo_v1.png
    stage_3_001_insect_observation_leonardo_v2.png（バリエーション用）
```

---

## ✅ 品質チェックリスト

生成後、以下を確認してください：

- [ ] キャラクターが子ども（高学年女児など）
- [ ] 青いフード、赤いバックパック
- [ ] 金色の虫眼鏡が明確に見える
- [ ] 昆虫（蝶、テントウムシ）が描かれている
- [ ] 花（ひまわり、ピンク系）が見える
- [ ] 照明が温かい（ゴールデンアワー的）
- [ ] 品質が高い（ぼやけていない）
- [ ] 子どもの手・顔が不自然でない

---

## 🔄 調整が必要な場合

### 問題：キャラクターが見えない / 背景のみ
**→** プロンプト先頭に `centered child, prominent in foreground` を追加

### 問題：虫眼鏡が見えない
**→** `holding golden magnifying glass prominently visible` を強調

### 問題：色が違う（フード色など）
**→** `bright blue hood jacket, vibrant blue` と複数回指定

### 問題：昆虫がいない
**→** `monarch butterfly, ladybug, grasshopper clearly visible` と複数回指定

---

## 📊 推奨生成枚数

| 用途 | 枚数 | 理由 |
|------|------|------|
| テスト生成 | 1-2 | プロンプト確認用 |
| バリエーション | 3-5 | 角度・表情の違い |
| 本番用 | 5-10 | ベストショット選定 + バックアップ |

---

## 💾 バージョン管理

このプロンプトは継続的に改善予定：
- **v1.0** (2026-06-17): 初版（参考画像ベース最適化）
- **v1.1**: 生成テスト結果を踏まえた調整予定
- **v2.0**: 他ステージへの応用

---

## 📝 備考

- **著作権**: Leonardo.AI で生成した画像は商用利用可能（利用規約確認推奨）
- **教育用途**: 小学3年向けなので、年齢に応じた内容確認
- **アプリ組み込み**: 生成後、アプリの assets フォルダに配置し、 UI で参照

---

**このプロンプトで、参考画像のような高品質な Stage 3-1 イラストが生成できます。**
**生成後、フィードバックをもとにプロンプトを継続改善します。**
