# 小学コレ！理科 3年生 AI画像生成プロンプト（キャラクター版・Leonardo.AI用）

## 概要
- **ツール**: Leonardo.AI
- **キャラクター**: 科学アシスタント（青いフード、丸い体、大きな目）
- **スタイル**: リアルかつかわいい（realistic-cute hybrid）
- **対象**: 小学3年生（8〜9歳向け）
- **用途**: 実験・観察シーン、学習コンテンツの挿絵

---

## キャラクター仕様
- **見た目**: 青いフード/ニット帽、丸くてぽっちゃりした体、大きな青い目
- **性格**: 好奇心旺盛、やさしい、科学好き
- **役割**: 子どもたちの実験・観察をサポートする学習アシスタント
- **スタイル**: かわいいけどやや立体的・リアル寄り（Pixar/Nintendo style）

---

## Stage 3-1: 昆虫と植物の観察

### プロンプト
```
A cute scientific character with a blue hood and round puffy body (large sparkly eyes, 
cheerful smile) holding a magnifying glass in a sunny garden. 
The character is observing colorful butterflies, ladybugs, and grasshoppers on vibrant flowers. 
Detailed realistic garden setting with natural sunlight and soft shadows. 
Character design: Pixar-inspired, semi-realistic with cute proportions. 
Garden background: lush green grass, blooming flowers (sunflowers, daisies, tulips), 
realistic insects with semi-cute design. Golden hour lighting, educational and joyful atmosphere. 
High quality, 4K, whimsical realism, perfect for children's education.
```

### ネガティブプロンプト
```
blurry, low quality, dark, scary insects, overly cartoonish, realistic bugs (too scary), 
distorted character, text, watermark, unrealistic colors
```

### 推奨設定
- **Model**: Leonardo Kino XL
- **Quality**: High
- **Guidance Scale**: 8
- **Style**: Anime, Illustration, Pixar-style

---

## Stage 3-4: 物と重さ（天秤実験）

### プロンプト
```
The cute blue-hooded scientific character (round puffy body, large sparkling eyes) 
is conducting a balance scale experiment in a bright, sunny classroom. 
The character is carefully placing colorful weighted blocks on a seesaw balance scale 
(teeter-totter balance), observing which side goes down. 
Realistic classroom with natural window light, clean floor, educational posters. 
The balance scale is clearly visible with: left side - small red, blue, yellow blocks; 
right side - larger single green block. 
Character shows concentration and curiosity expression. Pixar-inspired cute design 
mixed with realistic proportions. Warm, encouraging, educational mood. 
High quality, 4K, whimsical realism, perfect illustration for science education.
```

### ネガティブプロンプット
```
blurry, low quality, messy classroom, chaotic, angry expression, distorted character, 
broken scale, floating objects, text, watermark, overly dark
```

### 推奨設定
- **Model**: Leonardo Kino XL
- **Quality**: High
- **Guidance Scale**: 8
- **Style**: Pixar-style, Illustration, Realistic

---

## Stage 3-7: 磁石の性質（N極・S極）

### プロンプト
```
The cute scientific character with blue hood and round body (large bright eyes, 
excited expression) is holding a colorful realistic magnet (red on one end, blue on the other). 
Metal objects (iron nails, paperclips, coins, screws) are floating and attracted around the magnet 
in a magical yet scientific way. Subtle glowing magnetic force lines shimmer around the magnet. 
Clean white or soft gradient background with soft shadows for 3D effect. 
Character design: Pixar-inspired, cute but detailed proportions. 
Realistic magnet and metal objects with semi-cute design. 
Warm classroom lighting, magical yet educational, sparkling atmosphere. 
High quality, 4K, whimsical realism, perfect for STEM education illustration.
```

### ネガティブプロンプト
```
blurry, low quality, dark, scary, overly abstract, distorted character, 
floating randomly (not attracted), poor magnetism depiction, text, watermark
```

### 推奨設定
- **Model**: Leonardo Kino XL
- **Quality**: High
- **Guidance Scale**: 8
- **Style**: Magical, Illustration, Pixar-style

---

## Stage 3-10: 光と影、種の発芽

### プロンプト
```
Split educational scene with the cute blue-hooded scientific character (round puffy body, 
large sparkling eyes, curious expression):

LEFT SIDE: The character is outdoors observing its own shadow throughout the day. 
Morning: long shadow pointing west. Noon: small shadow directly beneath. 
Evening: long shadow pointing east. Sunny day with clear blue sky, warm golden light rays.

RIGHT SIDE: Close-up detailed view of sprouting bean seeds in brown soil with water droplets. 
Roots growing downward, green sprout emerging upward. Bright yellow sunlight rays 
illuminating the sprout. The character points at the growing seeds with wonder.

Realistic botanical detail with educational elements. Pixar-inspired character design. 
Warm, encouraging colors and lighting. Semi-realistic with cute proportions throughout. 
High quality, 4K, whimsical realism, perfect science education illustration.
```

### ネガティブプロンプット
```
blurry, low quality, dark, scary shadows, unrealistic plant growth, distorted character, 
chaotic composition, text, watermark, overly simplified
```

### 推奨設定
- **Model**: Leonardo Kino XL
- **Quality**: High
- **Guidance Scale**: 8-9
- **Style**: Illustration, Educational, Pixar-style

---

## 生成のコツ（Leonardo.AI）

### 高品質設定推奨
1. **Model**: Leonardo Kino XL（キャラクター表現に最適）
2. **Quality**: High or Unfiltered
3. **Guidance Scale**: 8（キャラクター忠実度優先）
4. **Steps**: 60-100
5. **Style Preset**: Pixar-style + Illustration + Cute

### 実行手順
1. leonardo.ai にアクセス
2. 「Create」→「Image Generation」を選択
3. 上記のプロンプトをコピペ
4. Model: Leonardo Kino XL
5. ネガティブプロンプットも入力
6. 「Generate」をクリック
7. 5-7分待機

### キャラクター調整のコツ
- 「目の大きさ」を強調したい場合：プロンプトに「big sparkly eyes」を複数回
- 「フードの色」を濃くしたい：「deep blue hood」に変更
- 「丸い体」を強調：「round puffy body, chubby proportions」を追加

### 微調整オプション
- 生成後「Edit」で色調調整
- 「Expand」で背景拡張
- 「Upscale」で最大4倍解像度向上

---

## ファイル保存・管理

### 保存先構造
```
H:\マイドライブ\apps\shokollen_science\assets\stage_3_illustrations\
├── character_based_realistic_cute\
│   ├── stage_3_001_insect_observation.png
│   ├── stage_3_004_balance_scale_experiment.png
│   ├── stage_3_007_magnet_properties.png
│   └── stage_3_010_shadow_and_germination.png
```

### 命名規則
```
stage_3_00X_[scene_name]_character-based.png
```

---

## 4年生以降への拡張

### テーマ例
- **4年 Stage 4-001**: 天気観測（キャラが温度計・雨量計を持つ）
- **4年 Stage 4-007**: 月や星の観察（夜空でキャラが星を数える）
- **5年 Stage 5-001**: 植物の成長観察（キャラが育てた花を観察）
- **6年 Stage 6-001**: 人体実験（キャラが心臓の鼓動を測定）

---

## 商用利用について
Leonardo.AI は商用利用可能。教育用途は明記推奨。

---

## バージョン情報
- **作成日**: 2026-06-17
- **バージョン**: 1.0 Character-based
- **用途**: 小学コレ！理科 学習コンテンツ
- **対象年齢**: 8～9歳（小学3年生）

---

**キャラクター版プロンプトで、より親しみやすく、学習効果が高い挿絵を生成できます。**
