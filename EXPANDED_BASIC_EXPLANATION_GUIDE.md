# 小学校学習指導要領準拠の拡張基本説明ガイド

小学校学習指導要領に完全に準拠した基本説明により、各問題が**教育的な背景と学習目標を明確に示す**構造になりました。

---

## 📚 拡張基本説明の構成要素

### 1️⃣ **学習指導要領の該当項目** 

学習指導要領の正式な記述を掲載し、この問題がどの学習領域に該当するかを明確にします。

**例：** 
```
小学3年 理科 A（生命）「身近な動物」
小学4年 理科 B（物質）「電気の性質」
小学5年 理科 B（物質）「振り子の運動」
```

### 2️⃣ **学習指導要領の内容（該当箇所）**

学習指導要領の「内容」セクションから、この単元の該当部分を引用します。

**構成：**
- **該当項目**（A, B, C など）
- **ア・イ・ウ**（細目）
- **具体的な学習内容**

### 3️⃣ **学習指導要領の学年別目標**

この学年での学習の目的を、学習指導要領に基づいて記述します。

### 4️⃣ **知識・技能の習得目標**

「何を知るか」「何ができるようになるか」を明確にします。

**構成：**
- **知識：** ✓ で示される知識項目（5～10個）
- **技能：** ✓ で示される実行可能な技能（3～5個）

### 5️⃣ **思考・判断・表現の能力**

「なぜ」「どのように」を考える力を定義します。

**構成：**
- ✓ 分析能力
- ✓ 比較判断能力
- ✓ 推論能力
- ✓ 表現能力

### 6️⃣ **具体的な学習活動例**

実際の授業で実施される活動を 5～6 個列挙します。

**構成：**
```
1. 導入活動（観察・実験の準備）
2. 基本的な活動（理解を深める）
3. 発展活動（条件変更・比較）
4. 記録・整理（データ化）
5. 応用活動（日常生活との関連）
6. 協働活動（友達との交流）
```

### 7️⃣ **評価の観点**

学習指導要領の評価観点に基づいた評価基準を示します。

**3つの観点：**
- **知識・技能**
- **思考・判断・表現**
- **主体的に学習に取り組む態度**

---

## 🎯 拡張基本説明の学習指導要領準拠性

### 学習指導要領との対応

| 要素 | 学習指導要領での位置づけ | 拡張説明での実装 |
|------|------------------------|-----------------|
| 目標 | 学年別目標 | ✅ 明記 |
| 内容 | A(1), B(2)など | ✅ 該当項目・細目を引用 |
| 知識・技能 | 「～を知る」「～できる」 | ✅ ✓ で箇条書き |
| 思考・判断・表現 | 「～を考える」「～を見つける」 | ✅ ✓ で能力を列挙 |
| 学習活動例 | 学指導要領に記載 | ✅ 6つの活動を詳細化 |
| 評価観点 | 3つの観点 | ✅ 3観点別に基準を示す |

---

## 📊 拡張データ統計

### 実装済み

| 学年 | 科目 | 単元 | 問題数 | 拡張説明数 |
|------|------|------|--------|----------|
| 3年 | A（生命） | 昆虫と植物 | 2問 | 2個 |
| 3年 | B（物質） | 物と重さ | 1問 | 1個 |
| 3年 | B（物質） | 磁石のはたらき | 1問 | 1個 |
| 4年 | B（物質） | 電気のはたらき | 1問 | 1個 |
| 5年 | B（物質） | 振り子の運動 | 1問 | 1個 |
| **合計** | | | **6問** | **6個** |

### 各拡張説明の構成

| 要素 | 内容 | 文量 |
|------|------|------|
| **学習指導要領参照** | 学年・分野・単元 | 1行 |
| **学習目標** | 指導要領の内容抜粋 | 10～15行 |
| **知識・技能** | 習得すべき内容と技能 | 8～10行 |
| **思考・判断・表現** | 育成すべき能力 | 5～7行 |
| **学習活動例** | 6つの具体的活動 | 20～30行 |
| **評価基準** | 3観点の評価方法 | 12～15行 |
| **基本説明** | シンプルな説明文 | 3～4行 |
| **合計** | | 約 70～90行/問 |

---

## 🔄 Firestore への統合方法

### 新しい Firestore コレクション構造

```
/expanded_explanations
  /{questionId}
    - questionId: String
    - curriculumReference: String    # 学習指導要領参照
    - learningObjective: String      # 学習目標
    - knowledgeAndSkills: String     # 知識・技能
    - thinkingAndJudgment: String    # 思考・判断・表現
    - learningActivities: String     # 学習活動例
    - evaluationCriteria: String     # 評価基準
    - basicExplanation: String       # 基本説明
    - createdAt: Timestamp
```

### シーディング実装

```dart
// lib/services/firestore_seeding.dart に追加

static Future<void> _seedExpandedBasicExplanations() async {
  final batch = _firestore.batch();

  for (final expData in expandedBasicExplanationsData) {
    final questionId = expData['questionId'] as String;
    final docRef = _firestore
        .collection('expanded_explanations')
        .doc(questionId);
    batch.set(docRef, expData);
  }

  await batch.commit();
}
```

### 画面での使用例

```dart
// 基本説明画面を拡張表示
Widget _buildBasicExplanationTab() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 学習指導要領参照
        _buildSectionCard(
          title: '📜 学習指導要領',
          content: explanation.curriculumReference,
          color: Colors.blue.shade50,
        ),
        
        // 2. 学習目標
        _buildSectionCard(
          title: '🎯 学習目標',
          content: explanation.learningObjective,
          color: Colors.green.shade50,
        ),
        
        // 3. 知識・技能
        _buildSectionCard(
          title: '💡 知識・技能',
          content: explanation.knowledgeAndSkills,
          color: Colors.yellow.shade50,
        ),
        
        // 4. 思考・判断・表現
        _buildSectionCard(
          title: '🧠 思考・判断・表現',
          content: explanation.thinkingAndJudgment,
          color: Colors.orange.shade50,
        ),
        
        // 5. 学習活動例
        _buildSectionCard(
          title: '📚 学習活動例',
          content: explanation.learningActivities,
          color: Colors.purple.shade50,
        ),
        
        // 6. 評価基準
        _buildSectionCard(
          title: '📊 評価基準',
          content: explanation.evaluationCriteria,
          color: Colors.pink.shade50,
        ),
        
        // 7. 基本説明
        _buildSectionCard(
          title: '✨ 基本説明',
          content: explanation.basicExplanation,
          color: AppColors.scienceLight,
        ),
      ],
    ),
  );
}
```

---

## 🎓 教育的価値

### 学生の視点

```
【認識の変化】
「なぜこの問題を勉強するのか」を理解
  ↓
「学習指導要領でこう定められている」という根拠を知る
  ↓
「自分たちの学年での学習目標がこれ」と理解
  ↓
「身につけるべき知識・技能・能力が明確」に見える
```

### 保護者の視点

```
【信頼の構築】
「なぜこの内容なのか」を説明できる
  ↓
「学習指導要領に基づいている」と説明可能
  ↓
「評価観点はこの3つ」と透明性を保証
  ↓
「子どもの学習を家庭でサポート可能」
```

### 教員の視点

```
【指導の質向上】
「この問題は指導要領のこの部分をカバー」と確認
  ↓
「学習活動例から授業設計を参考」
  ↓
「評価基準が明確」で成績評価が一貫性を持つ
  ↓
「カリキュラム全体での位置づけが見える」
```

---

## 📝 拡張説明の作成ガイドライン

### 各セクションの推奨文量

| セクション | 推奨行数 | 特徴 |
|-----------|---------|------|
| 学習指導要領参照 | 1～2行 | 簡潔、正式記述 |
| 学習目標 | 10～15行 | 包括的、細分化 |
| 知識・技能 | 8～10行 | ✓ で箇条書き |
| 思考・判断・表現 | 5～7行 | ✓ で能力を列挙 |
| 学習活動例 | 20～30行 | 具体的、6項目 |
| 評価基準 | 12～15行 | 3観点別 |
| 基本説明 | 3～4行 | 簡潔、要点 |

### チェックリスト

- [ ] 学習指導要領の原文に基づいているか
- [ ] 学年別の目標が正確か
- [ ] 知識と技能が明確に区別されているか
- [ ] 思考・判断・表現が具体的か
- [ ] 学習活動が実装可能か
- [ ] 評価基準が3観点を網羅しているか
- [ ] 基本説明がシンプルか

---

## 🔗 関連ファイル

- `lib/data/seeds/expanded_basic_explanations.dart` — 拡張基本説明データ
- `lib/features/quiz/views/explanation_screen.dart` — 解説画面ウィジェット
- `lib/services/firestore_seeding.dart` — Firestore シーディング
- `EXPLANATION_GUIDE.md` — 解説画面全体の設計
- `CONTENT_OVERVIEW.md` — コンテンツ全体の概要

---

## ✅ Phase 1 実装チェックリスト

- [ ] expandedBasicExplanationsData が Firestore に正しく格納
- [ ] _buildBasicExplanationTab() が 7 セクションを順序よく表示
- [ ] 各セクションが異なる背景色で視覚的に区別
- [ ] テキストが読みやすいサイズとフォント
- [ ] スクロール時にセクション見出しが見える
- [ ] モバイル画面で レスポンシブに表示
- [ ] タップで各セクションを展開・折畳み可能（オプション）

---

**最終更新日**: 2026-05-29  
**バージョン**: v1.0 — 学習指導要領準拠システム
