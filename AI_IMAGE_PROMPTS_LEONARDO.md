# 小学コレ！理科 3年生 AI画像生成プロンプト（Leonardo.AI用）

## 概要
- **ツール**: Leonardo.AI
- **スタイル**: リアルかつかわいい（realistic-cute hybrid）
- **対象**: 小学3年生（8〜9歳向け）
- **用途**: 実験・観察シーン、学習コンテンツの挿絵

---

## Stage 3-1: 昆虫と植物の観察

### プロンプト
```
A curious 3rd grade girl with warm brown eyes observing insects in a sunny garden, 
holding a magnifying glass over colorful butterflies and flowers. 
Detailed yet adorable illustration style, anime-influenced cute proportions with 
realistic natural colors and lighting. Girl wears school uniform. 
Garden has vibrant green grass, blooming flowers (sunflowers, daisies), 
and realistic insects (butterfly, ladybug, grasshopper) with semi-cute character design. 
Golden sunlight streaming through, soft shadows. Educational and friendly atmosphere. 
High quality, 4K, whimsical realism.
```

### ネガティブプロンプト
```
blurry, low quality, dark, scary insects, overly cartoonish, unrealistic colors, 
ugly proportions, distorted hands, text, watermark
```

### 推奨設定
- **Model**: Leonardo Kino XL or Leonardo Diffusion
- **Quality**: High
- **Guidance Scale**: 7-8
- **Style**: Anime, Illustration, Realistic

---

## Stage 3-4: 物と重さ（天秤実験）

### プロンプト
```
Two elementary school children conducting a balance scale experiment in a bright classroom. 
One child places colorful weighted blocks on each side of a seesaw balance scale (teeter-totter balance). 
Realistic classroom setting with natural window light, soft shadows. 
Children have cute proportions with expressive faces showing curiosity and concentration. 
The balance scale is clearly visible with objects: one side has small red, blue, yellow blocks; 
other side has a single larger green block. Educational, encouraging mood. 
Realistic proportions mixed with cute character design (anime-influenced). 
Clear, detailed, high quality, 4K, professional illustration.
```

### ネガティブプロンプト
```
blurry, low quality, messy, chaotic, scary expressions, unrealistic proportions, 
distorted hands, broken scale, floating objects, text, watermark
```

### 推奨設定
- **Model**: Leonardo Kino XL
- **Quality**: High
- **Guidance Scale**: 7-8
- **Style**: Realistic, Illustration, Educational

---

## Stage 3-7: 磁石の性質（N極・S極）

### プロンプト
```
An elementary school student's hand holding a colorful realistic magnet (red on one end, blue on the other), 
with metal objects attracted to it: iron nails, paperclips, and coins floating in mid-air around the magnet. 
Magnetic force lines visible as subtle glowing effects around the magnet. 
Clean white or light background with soft shadows showing the 3D effect. 
The magnet is realistic but with cute proportions fitting the character's small hand. 
Warm, encouraging classroom lighting. Detailed yet adorable anime-influenced illustration. 
Educational, clear, magical but scientific atmosphere. High quality, 4K, whimsical realism.
```

### ネガティブプロンプト
```
blurry, low quality, dark, scary, overly abstract, unrealistic colors, 
distorted hands, floating randomly, poor magnetism depiction, text, watermark
```

### 推奨設定
- **Model**: Leonardo Diffusion or Leonardo Kino XL
- **Quality**: High
- **Guidance Scale**: 7-8
- **Style**: Anime, Magical, Scientific Illustration

---

## Stage 3-10: 光と影、種の発芽

### プロンプト
```
Educational split-scene illustration: 
LEFT SIDE: A cute child outdoors observing their shadow changing throughout the day 
(morning small shadow pointing west, noon small shadow directly under feet, 
evening long shadow pointing east). Sunny day with clear sky, warm golden light. 
RIGHT SIDE: Detailed close-up of sprouting bean seeds in brown soil with water droplets, 
showing root growth downward and green sprout emerging upward toward bright yellow sunlight rays. 
Realistic botanical detail with cute decorative elements. 
Both scenes use warm, educational lighting and colors. 
Anime-influenced cute proportions for the child character with realistic natural details. 
High quality, 4K, professional educational illustration, whimsical yet scientific.
```

### ネガティブプロンプト
```
blurry, low quality, dark, scary shadows, unrealistic plant growth, 
distorted proportions, text, watermark, chaotic, messy composition
```

### 推奨設定
- **Model**: Leonardo Kino XL
- **Quality**: High
- **Guidance Scale**: 7-9
- **Style**: Anime, Illustration, Educational, Detailed

---

## 生成のコツ（Leonardo.AI）

### 高品質設定
1. **Model**: Leonardo Kino XL が最高品質（リアルかつ詳細）
2. **Quality**: High or Unfiltered
3. **Guidance Scale**: 7-8（プロンプト忠実度）
4. **Steps**: 50-100（品質向上）
5. **Style Preset**: Anime + Illustration + Realistic

### 実行手順
1. Leonardo.AI（leonardo.ai）にアクセス
2. 「Create」→「Image Generation」を選択
3. 上記のプロンプトをコピー＆ペースト
4. Model を「Leonardo Kino XL」に設定
5. ネガティブプロンプットも入力
6. 「Generate」をクリック
7. 4-5分待機（品質オプション選択時は長め）

### 調整のコツ
- 生成後「Edit」で微調整可能
- 「Expand」で画像拡大
- 「Upscale」で解像度向上（2-4倍）
- 「Regenerate」で同プロンプトで複数生成

---

## 商用利用について
Leonardo.AI は商用利用可能ですが、以下を確認：
- 利用規約を確認
- 教育アプリ用途は明記
- 必要に応じてライセンスを取得

---

## 保存先
- **画像**: `H:\マイドライブ\apps\shokollen_science\assets\stage_3_illustrations\`
- **命名規則**: `stage_3_00X_realistic-cute_[scene].png`
  例：`stage_3_001_realistic-cute_insect-observation.png`

---

## 次のステップ
1. 各プロンプトで画像を生成
2. アプリ内に配置（学習コンテンツ、ステージ背景など）
3. 4年生以降のステージも同様に拡張

---

**最終更新**: 2026-06-17
**用途**: 小学コレ！理科 学習コンテンツ挿絵
