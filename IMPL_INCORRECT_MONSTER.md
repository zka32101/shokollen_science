# 実装ガイド: ⑬ まちがい図鑑（Incorrect Monster）

**開始日**: 2026-07-02 | **推定工期**: 2-3 週間 | **優先度**: 🥇最優先

---

## 📋 概要

**機能名**: Incorrect Monster / まちがい図鑑  
**説明**: クイズで間違えた問題が「モンスター」として自動登録され、再挑戦で正解すると進化する図鑑  
**心理学的効果**: 誤答=恥ずかしい → 誤答=集めたいもの に転換  
**学習効果**: 間違いへの向き合い方が肯定的に、再学習促進

---

## 🎯 実装範囲

### 内蔵内容（MVP）
- ✅ 間違った問題の自動モンスター化
- ✅ まちがい図鑑スクリーン（一覧表示）
- ✅ モンスター詳細画面（問題+解説+進化状況）
- ✅ 正解で進化アニメーション
- ✅ 進化段階の管理（baby → juvenile → adult → sage）

### 含まない（Phase 2）
- ❌ モンスターのトレード機能
- ❌ バトル機能
- ❌ キャラスロット化（キャラコレと統合）

---

## 📊 データモデル

### 1. IncorrectMonster テーブル

```dart
// lib/features/progress/models/incorrect_monster.dart

class IncorrectMonster {
  final String id;                    // UUID
  final String questionId;            // "stage_3_001_q1" など
  final String stageId;               // "stage_3_001"
  final int questionNumber;           // 1-10
  final String monsterName;           // 自動生成: 問題タイトルから
  final DateTime firstIncorrectDate;  // 初回間違い日時
  final int correctionsCount;         // 正解した回数（進化段階）
  final EvolutionState evolutionState;// baby/juvenile/adult/sage
  final List<DateTime> correctionDates; // 各正解日時（履歴）
  
  IncorrectMonster({
    required this.id,
    required this.questionId,
    required this.stageId,
    required this.questionNumber,
    required this.monsterName,
    required this.firstIncorrectDate,
    this.correctionsCount = 0,
    this.evolutionState = EvolutionState.baby,
    this.correctionDates = const [],
  });
  
  // 進化判定
  EvolutionState getEvolutionState() {
    return switch (correctionsCount) {
      0 => EvolutionState.baby,        // 初期状態（泣き顔）
      1 => EvolutionState.juvenile,    // 1回正解（困り顔）
      2 => EvolutionState.adult,       // 2回正解（普通顔）
      3 => EvolutionState.sage,        // 3回正解（嬉しい顔）
      _ => EvolutionState.sage,
    };
  }
  
  bool canEvolve() => correctionsCount < 3;
  
  factory IncorrectMonster.fromJson(Map<String, dynamic> json) => _$IncorrectMonsterFromJson(json);
  Map<String, dynamic> toJson() => _$IncorrectMonsterToJson(this);
}

enum EvolutionState {
  baby,      // 😢 泣いている
  juvenile,  // 😕 困っている
  adult,     // 😐 普通
  sage,      // 😊 嬉しい
}

extension EvolutionStateExt on EvolutionState {
  String get emoji => {
    EvolutionState.baby: '😢',
    EvolutionState.juvenile: '😕',
    EvolutionState.adult: '😐',
    EvolutionState.sage: '😊',
  }[this]!;
  
  String get label => {
    EvolutionState.baby: 'たまご',
    EvolutionState.juvenile: '幼生',
    EvolutionState.adult: '成体',
    EvolutionState.sage: '博士',
  }[this]!;
}
```

### 2. Riverpod Provider

```dart
// lib/features/progress/providers/incorrect_monster_provider.dart

final incorrectMonstersProvider = StateNotifierProvider<IncorrectMonsterNotifier, List<IncorrectMonster>>((ref) {
  return IncorrectMonsterNotifier(ref.watch(progressRepositoryProvider));
});

class IncorrectMonsterNotifier extends StateNotifier<List<IncorrectMonster>> {
  final ProgressRepository _repository;
  
  IncorrectMonsterNotifier(this._repository) : super([]) {
    _init();
  }
  
  Future<void> _init() async {
    state = await _repository.getIncorrectMonsters();
  }
  
  // 間違いを記録
  Future<void> recordIncorrect(String questionId, String stageId, int questionNumber, String questionTitle) async {
    final existing = state.firstWhereOrNull((m) => m.questionId == questionId);
    
    if (existing != null) {
      // 既存のモンスターなら何もしない
      return;
    }
    
    final monster = IncorrectMonster(
      id: const Uuid().v4(),
      questionId: questionId,
      stageId: stageId,
      questionNumber: questionNumber,
      monsterName: _generateMonsterName(questionTitle),
      firstIncorrectDate: DateTime.now(),
    );
    
    await _repository.saveIncorrectMonster(monster);
    state = [...state, monster];
  }
  
  // 正解して進化
  Future<void> evolveMonster(String monsterIdString) async {
    final monster = state.firstWhere((m) => m.id == monsterIdString);
    final updated = monster.copyWith(
      correctionsCount: monster.correctionsCount + 1,
      evolutionState: monster.getEvolutionState(),
      correctionDates: [...monster.correctionDates, DateTime.now()],
    );
    
    await _repository.updateIncorrectMonster(updated);
    state = state.map((m) => m.id == monsterIdString ? updated : m).toList();
  }
  
  String _generateMonsterName(String questionTitle) {
    // 問題タイトルから自動生成
    // 例: "昆虫のからだのつくり" → "コムシくん" みたいな親しみやすい名前
    final words = questionTitle.split('・');
    final mainWord = words.first;
    
    // 簡単版: タイトルの最初の3文字 + ちゃん
    return '${mainWord.substring(0, min(3, mainWord.length))}ちゃん';
  }
}

// 特定モンスター取得
final specificMonsterProvider = Provider.family<IncorrectMonster?, String>((ref, monsterId) {
  return ref.watch(incorrectMonstersProvider).firstWhereOrNull((m) => m.id == monsterId);
});
```

### 3. Repository

```dart
// lib/features/progress/data/repositories/progress_repository.dart

abstract class ProgressRepository {
  Future<List<IncorrectMonster>> getIncorrectMonsters();
  Future<void> saveIncorrectMonster(IncorrectMonster monster);
  Future<void> updateIncorrectMonster(IncorrectMonster monster);
  Future<void> deleteIncorrectMonster(String monsterId);
}

class ProgressRepositoryImpl implements ProgressRepository {
  final SharedPreferencesAsync _prefs;
  static const String _key = 'incorrect_monsters';
  
  ProgressRepositoryImpl(this._prefs);
  
  @override
  Future<List<IncorrectMonster>> getIncorrectMonsters() async {
    final json = await _prefs.getStringList(_key) ?? [];
    return json.map((j) => IncorrectMonster.fromJson(jsonDecode(j))).toList();
  }
  
  @override
  Future<void> saveIncorrectMonster(IncorrectMonster monster) async {
    final current = await getIncorrectMonsters();
    final updated = [...current, monster];
    await _prefs.setStringList(_key, updated.map((m) => jsonEncode(m)).toList());
  }
  
  @override
  Future<void> updateIncorrectMonster(IncorrectMonster monster) async {
    final current = await getIncorrectMonsters();
    final updated = current.map((m) => m.id == monster.id ? monster : m).toList();
    await _prefs.setStringList(_key, updated.map((m) => jsonEncode(m)).toList());
  }
  
  @override
  Future<void> deleteIncorrectMonster(String monsterId) async {
    final current = await getIncorrectMonsters();
    final updated = current.where((m) => m.id != monsterId).toList();
    await _prefs.setStringList(_key, updated.map((m) => jsonEncode(m)).toList());
  }
}
```

---

## 🎨 UI/UX 実装

### 1. クイズ結果画面の変更

```dart
// lib/features/quiz/views/quiz_result_screen.dart

void _handleQuizComplete(BuildContext context, bool isCorrect, String stageId, int questionNumber) {
  if (isCorrect) {
    // 正解した場合、モンスター進化確認
    final monsterRef = ref.read(incorrectMonstersProvider.notifier);
    final questionId = '${stageId}_q$questionNumber';
    
    // このモンスターが既存か確認して進化
    final existingMonster = ref.watch(incorrectMonstersProvider)
        .firstWhereOrNull((m) => m.questionId == questionId);
    
    if (existingMonster != null && existingMonster.canEvolve()) {
      _showEvolutionDialog(context, existingMonster);
    }
  } else {
    // 間違えた場合、モンスター化
    final monster Notifier = ref.read(incorrectMonstersProvider.notifier);
    monsterNotifier.recordIncorrect(
      questionId: '${stageId}_q$questionNumber',
      stageId: stageId,
      questionNumber: questionNumber,
      questionTitle: currentQuestion['title'] as String,
    );
    
    // モンスター獲得ダイアログ表示
    _showMonsterGetDialog(context);
  }
}

void _showMonsterGetDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.pink[50],
      title: Center(child: Text('このモンスターをあなたのともだちにしよう！', style: TextStyle(fontSize: 16))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('😢\n${monsterName}', textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
          SizedBox(height: 12),
          Text('「正解できるまで、ずっとともだちだよ！」', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('まちがい図鑑をみる', style: TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}

void _showEvolutionDialog(BuildContext context, IncorrectMonster monster) {
  showDialog(
    context: context,
    builder: (context) => AnimatedBuilder(
      animation: _evolutionAnimation,
      builder: (context, child) => AlertDialog(
        backgroundColor: Colors.amber[50],
        title: Center(
          child: Text('${monster.monsterName}が進化した！', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_getEmojiForCount(monster.correctionsCount - 1)} → ${_getEmojiForCount(monster.correctionsCount)}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32),
            ),
            SizedBox(height: 12),
            Text(
              '${_getLabel(monster.correctionsCount - 1)} → ${_getLabel(monster.correctionsCount)}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(incorrectMonstersProvider.notifier).evolveMonster(monster.id);
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    ),
  );
}
```

### 2. まちがい図鑑スクリーン

```dart
// lib/features/progress/views/incorrect_monster_screen.dart

class IncorrectMonsterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monsters = ref.watch(incorrectMonstersProvider);
    
    if (monsters.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('まちがい図鑑')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sentiment_very_satisfied, size: 64, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text('まちがい図鑑はまだからです！', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              SizedBox(height: 8),
              Text('クイズで間違えたらモンスターが登場するよ', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('まちがい図鑑（${monsters.length}体）'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: monsters.length,
        itemBuilder: (context, index) {
          final monster = monsters[index];
          return _MonsterCard(monster: monster);
        },
      ),
    );
  }
}

class _MonsterCard extends ConsumerWidget {
  final IncorrectMonster monster;
  
  const _MonsterCard({required this.monster});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showMonsterDetail(context, ref),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: _getGradientColors(monster.evolutionState),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(monster.evolutionState.emoji, style: TextStyle(fontSize: 32)),
              SizedBox(height: 8),
              Text(monster.monsterName, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(monster.evolutionState.label, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: Colors.grey[600])),
              SizedBox(height: 8),
              // 進化ゲージ
              SizedBox(
                width: 50,
                height: 4,
                child: LinearProgressIndicator(
                  value: monster.correctionsCount / 3.0,
                  color: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showMonsterDetail(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonsterDetailScreen(monsterId: monster.id),
      ),
    );
  }
  
  List<Color> _getGradientColors(EvolutionState state) {
    return switch (state) {
      EvolutionState.baby => [Colors.blue[100]!, Colors.blue[300]!],
      EvolutionState.juvenile => [Colors.purple[100]!, Colors.purple[300]!],
      EvolutionState.adult => [Colors.green[100]!, Colors.green[300]!],
      EvolutionState.sage => [Colors.yellow[100]!, Colors.yellow[300]!],
    };
  }
}
```

### 3. モンスター詳細画面

```dart
// lib/features/progress/views/monster_detail_screen.dart

class MonsterDetailScreen extends ConsumerWidget {
  final String monsterId;
  
  const MonsterDetailScreen({required this.monsterId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monster = ref.watch(specificMonsterProvider(monsterId));
    
    if (monster == null) {
      return Scaffold(
        appBar: AppBar(title: Text('モンスター詳細')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: Text(monster.monsterName)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 進化状況
            Center(
              child: Column(
                children: [
                  Text(monster.evolutionState.emoji, style: TextStyle(fontSize: 72)),
                  SizedBox(height: 12),
                  Text('${monster.evolutionState.label}段階', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: monster.correctionsCount / 3.0,
                    minHeight: 8,
                  ),
                  SizedBox(height: 4),
                  Text('${monster.correctionsCount}/3 正解でさらに進化', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            SizedBox(height: 24),
            
            // 問題情報
            Text('もんだいじょうほう', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ステージ: ${monster.stageId}', style: TextStyle(fontSize: 12)),
                    Text('もんだい: ${monster.questionNumber}', style: TextStyle(fontSize: 12)),
                    Text('初回間違い: ${DateFormat('yyyy-MM-dd HH:mm').format(monster.firstIncorrectDate)}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // 再挑戦ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // クイズ画面へ遷移
                  Navigator.pop(context);
                },
                icon: Icon(Icons.refresh),
                label: Text('このもんだいに再ちょうせん'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔧 実装タスク分解

### Week 1: データモデル + ロジック基盤

- [ ] `IncorrectMonster` モデル定義（freezed）
- [ ] `ProgressRepository` 実装（SharedPreferences 連携）
- [ ] `IncorrectMonsterNotifier` 実装（Riverpod）
- [ ] Migration: SharedPreferences スキーマ更新
- [ ] ユニットテスト（モデル、Notifier）

### Week 2: UI 実装

- [ ] `IncorrectMonsterScreen` 実装（図鑑一覧）
- [ ] `MonsterDetailScreen` 実装（詳細表示）
- [ ] `MonsterGetDialog` 実装（間違い時）
- [ ] `EvolutionDialog` 実装（進化時）
- [ ] `QuizResultScreen` 修正（間違い記録、進化判定）
- [ ] アニメーション実装（進化エフェクト）

### Week 3: テスト + 統合

- [ ] UI テスト（ダイアログ、ナビゲーション）
- [ ] 統合テスト（クイズ→間違い→図鑑→再挑戦→進化）
- [ ] ベータテスター向けリリース
- [ ] フィードバック収集 + 調整
- [ ] 本リリース

---

## 📱 UI スケッチ

```
╔════════════════════════════════════╗
║     まちがい図鑑（12体）          ║  ← IncorrectMonsterScreen
╠════════════════════════════════════╣
║  ┌──────┬──────┬──────┐           ║
║  │ 😢   │ 😕   │ 😐   │           ║  ← GridView
║  │ コム │ ハナ │ デン │           ║     _MonsterCard
║  │ 昆虫 │ 植物 │ 電気 │           ║
║  └──────┴──────┴──────┘           ║
║  ┌──────┬──────┬──────┐           ║
║  │ 😊   │ ░░░░ │ ░░░░ │           ║
║  │ トケ │ ....  │ ....  │           ║
║  │化学  │      │      │           ║
║  └──────┴──────┴──────┘           ║
║                                    ║
║   [タップで詳細表示]               ║
╚════════════════════════════════════╝

╔════════════════════════════════════╗
║   コムシちゃん の詳細              ║  ← MonsterDetailScreen
╠════════════════════════════════════╣
║                                    ║
║           😢 → 😕 → 😐 → 😊      ║
║                                    ║
║           幼生段階                 ║
║                                    ║
║        ████░░░░░░░░░░░░░░        ║  進化ゲージ
║        1/3 正解でさらに進化        ║
║                                    ║
║  ┌────────────────────────┐        ║
║  │ もんだいじょうほう     │        ║
║  │ ステージ: stage_3_001 │        ║
║  │ もんだい: 1           │        ║
║  │ 初回間違い: 2026-07-02│        ║
║  └────────────────────────┘        ║
║                                    ║
║  ┌────────────────────────┐        ║
║  │  このもんだいに再ちょうせん    ║
║  └────────────────────────┘        ║
╚════════════════════════════════════╝

╔════════════════════════════════════╗
║  このモンスターをあなたのともだち ║  ← MonsterGetDialog
║           にしよう！               ║
╠════════════════════════════════════╣
║                                    ║
║              😢                    ║
║        コムシちゃん                ║
║                                    ║
║  「正解できるまで、              ║
║   ずっとともだちだよ！」          ║
║                                    ║
║          [まちがい図鑑をみる]     ║
║                                    ║
╚════════════════════════════════════╝
```

---

## ✅ テストケース

### ユニットテスト

```dart
void main() {
  group('IncorrectMonster Model Tests', () {
    test('初期状態は baby', () {
      final monster = IncorrectMonster(
        id: '1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テスト',
        firstIncorrectDate: DateTime.now(),
      );
      expect(monster.evolutionState, EvolutionState.baby);
    });
    
    test('正解1回で juvenile に進化', () {
      final monster = IncorrectMonster(
        id: '1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テスト',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 1,
      );
      expect(monster.getEvolutionState(), EvolutionState.juvenile);
    });
    
    test('正解3回で sage に進化', () {
      final monster = IncorrectMonster(
        id: '1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テスト',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 3,
      );
      expect(monster.getEvolutionState(), EvolutionState.sage);
    });
    
    test('sage 状態では canEvolve = false', () {
      final monster = IncorrectMonster(
        id: '1',
        questionId: 'q1',
        stageId: 'stage_3_001',
        questionNumber: 1,
        monsterName: 'テスト',
        firstIncorrectDate: DateTime.now(),
        correctionsCount: 3,
      );
      expect(monster.canEvolve(), false);
    });
  });
  
  group('IncorrectMonsterNotifier Tests', () {
    test('間違い記録で新モンスター追加', () async {
      // Provider setup + assertion
    });
    
    test('既存モンスターの重複記録はしない', () async {
      // Provider setup + assertion
    });
    
    test('正解で進化', () async {
      // Provider setup + assertion
    });
  });
}
```

### UI/統合テスト

```dart
void main() {
  group('IncorrectMonster UI Tests', () {
    testWidgets('モンスター獲得ダイアログが表示される', (WidgetTester tester) async {
      // Build test app + trigger incorrect answer
      // Verify dialog is shown
    });
    
    testWidgets('まちがい図鑑スクリーンにモンスターが表示される', (WidgetTester tester) async {
      // Setup monsters + build screen
      // Verify grid view shows all monsters
    });
    
    testWidgets('進化ダイアログが表示されて進化する', (WidgetTester tester) async {
      // Setup monster + retake quiz correctly
      // Verify evolution dialog + monster state updated
    });
  });
}
```

---

## 📦 ファイル一覧

```
lib/features/progress/
├── models/
│   └── incorrect_monster.dart        ← NEW
├── data/
│   └── repositories/
│       └── progress_repository.dart  ← UPDATE
├── providers/
│   └── incorrect_monster_provider.dart ← NEW
└── views/
    ├── incorrect_monster_screen.dart  ← NEW
    ├── monster_detail_screen.dart     ← NEW
    └── monster_dialogs.dart           ← NEW

lib/features/quiz/views/
└── quiz_result_screen.dart            ← UPDATE (間違い記録処理)
```

---

## 🚀 リリースチェックリスト

- [ ] 全テスト合格
- [ ] パフォーマンス計測（500モンスター以上でも快適か）
- [ ] 日本語テキスト確認（ふりがな）
- [ ] ベータテスター10名 + フィードバック
- [ ] App Store/Google Play 申請前確認
- [ ] Crashlytics ダッシュボード設定

---

## 📝 実装メモ

- **freezed 使用**: `IncorrectMonster.copyWith()` 簡潔化
- **SharedPreferences**: 初期実装はシンプルに。将来 SQLite への移行検討
- **アニメーション**: Lottie アニメーション追加で UX 向上（Phase 2）
- **バッジ連動**: 「モンスター 5体集める」などのバッジ追加（Phase 2）

