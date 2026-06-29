# ① 「よそうラボ」— 仮説→実験→検証モード

**実装期間**: 2026-06-15 〜 2026-06-20（5営業日）  
**優先度**: 🥇 Tier S  
**インパクト**: 科学的思考の核心を体験化 × 新しい成長軸（予想力）  
**開発コスト**: 低（2-3日）

---

## 📖 概要

クイズの前に「どうなると思う？」を必ず予想させ、**予想と結果のギャップで学ぶ**。

### コンセプト図
```
従来：実験 → 「磁石はくぎにくっつく」 → 正解・不正解
      └ 受動的、記憶ゲーム化

新規：実験 → 「くぎは磁石につく？」
      ↓
      🧠 予想：「つく」を選択
      ↓
      実験結果を確認 → 「あたり！🎯」
      ↓
      記憶定着 + 自信 + 科学的思考能力向上
```

---

## 🎮 UX フロー

```
[実験選択画面]
"磁石と鉄"をタップ
  ↓
[実験詳細画面]
- 実験の説明：「磁石とくぎを使った実験」
- ボタン：「クイズモードを選ぶ」
  ↓
[クイズモード選択]
- 逆実験、失敗ラボ、クイズ、タイマークイズ
- 予想ラボ（新規）← ← ← ★新しいボタン
  ↓
[予想ラボ画面] ★ Step 0（新規追加）
┌────────────────────────────────┐
│  やってみよう！🔬              │
│                                │
│  くぎは磁石につくかな？        │
│                                │
│  ┌──────────────────────────┐ │
│  │  つく      つかない    │ │
│  │  わからない             │ │
│  └──────────────────────────┘ │
│                                │
│  ※ どちらが正しいと思う？     │
└────────────────────────────────┘
（ボタンを選択）
  ↓
[クイズ実施] ← Step 1-4（既存）
┌────────────────────────────────┐
│ Step 1: 正しい理由は？         │
│ A. 磁石は鉄をひきつける力がある  │
│ B. ...                         │
└────────────────────────────────┘
（全4ステップ実施）
  ↓
[結果画面] ★拡張
┌────────────────────────────────┐
│  すごい！クリア！🎉            │
│                                │
│  きみの予想：「つく」           │
│  実際の結果：「つく」           │
│  → あたり！🎯 +10ボーナスコイン│
│                                │
│  予想的中率: 73%               │
│  目標: よそう名人（90%以上）   │
│  あと +17% がんばろう！        │
│                                │
│  [ほめカードをつくる]          │
│  [つぎの実験へ]               │
└────────────────────────────────┘
```

---

## 📊 データモデル

### ExperimentPredictionResult (新規)
```dart
class ExperimentPredictionResult {
  final String experimentId;
  final DateTime timestamp;
  final String? userPrediction;  // "つく" / "つかない" / "わからない" / null
  final String? actualAnswer;     // 正解
  final bool isPredictionCorrect; // 予想が正解と一致したか
  final int stepCount;            // ステップ数（固定: 4）
  final bool quizPassed;          // クイズ本体の成功
}

class PredictionStatistics {
  final String experimentId;
  final int totalAttempts;        // よそうラボを実行した回数
  final int correctPredictions;   // 的中した回数
  double get predictionRate => 
    totalAttempts == 0 ? 0 : (correctPredictions / totalAttempts) * 100;
}
```

### Experiment (拡張)
```dart
class Experiment {
  // ... 既存フィールド ...
  
  final String? predictionQuestion;     // 予想の問い文
  final List<String> predictionChoices; // 選択肢
  final String predictionAnswer;        // 正解
}
```

---

## 💾 データベース設計

### SharedPreferences (ローカル)
```
Key Format:
prediction_stats_{experimentId}:totalAttempts
prediction_stats_{experimentId}:correctPredictions
prediction_history_{experimentId}_{timestamp}:result

Example:
prediction_stats_exp_001:totalAttempts = 5
prediction_stats_exp_001:correctPredictions = 3
prediction_history_exp_001_1718540000:result = "correct"
```

### Firestore (クラウド、Phase 4 以降)
```
/users/{userId}/predictions/{experimentId}
  {
    totalAttempts: 5,
    correctPredictions: 3,
    lastPredicted: 2026-06-18T14:30:00Z,
    predictionHistory: [
      { timestamp, choice, isCorrect }
    ]
  }
```

---

## 🏗️ 実装仕様

### 1. experiment_data.dart に predictionQuestion, predictionChoices, predictionAnswer を追加

```dart
const experiments = [
  Experiment(
    id: "exp_001",
    title: "磁石と鉄",
    description: "磁石はどんなものに力をはたらかせるかを調べます。",
    gradeLevel: GradeLevel.grade3,
    // ... 既存フィールド ...
    predictionQuestion: "くぎは磁石につくかな？",
    predictionChoices: ["つく", "つかない", "わからない"],
    predictionAnswer: "つく",
  ),
  // ... 他の実験 ...
];
```

### 2. experiment_provider.dart に PredictionStatisticsNotifier を追加

```dart
class PredictionStatisticsNotifier 
    extends StateNotifier<Map<String, PredictionStatistics>> {
  
  PredictionStatisticsNotifier(this._profileService) : super({});
  
  final ProfileService _profileService;
  
  Future<void> recordPrediction({
    required String experimentId,
    required String userPrediction,
    required String actualAnswer,
    required bool quizPassed,
  }) async {
    final isCorrect = userPrediction == actualAnswer;
    
    // SharedPrefs に保存
    final key = 'prediction_stats_$experimentId';
    final total = _profileService.getInt('$key:totalAttempts') ?? 0;
    final correct = _profileService.getInt('$key:correctPredictions') ?? 0;
    
    await _profileService.setInt('$key:totalAttempts', total + 1);
    if (isCorrect) {
      await _profileService.setInt('$key:correctPredictions', correct + 1);
    }
    
    // 履歴記録
    await _profileService.setString(
      'prediction_history_${experimentId}_${DateTime.now().millisecondsSinceEpoch}',
      jsonEncode({
        'choice': userPrediction,
        'isCorrect': isCorrect,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
    
    // Riverpod 更新
    state = {
      ...state,
      experimentId: PredictionStatistics(
        experimentId: experimentId,
        totalAttempts: total + 1,
        correctPredictions: correct + (isCorrect ? 1 : 0),
      ),
    };
    
    // バッジ判定
    if ((correct + (isCorrect ? 1 : 0)) / (total + 1) >= 0.9) {
      await _awardBadge('prediction_master'); // よそう名人
    }
  }
  
  double getPredictionRate(String experimentId) {
    final stats = state[experimentId];
    return stats?.predictionRate ?? 0;
  }
}

final predictionStatisticsProvider = StateNotifierProvider<
    PredictionStatisticsNotifier,
    Map<String, PredictionStatistics>>(
  (ref) => PredictionStatisticsNotifier(
    ref.watch(profileServiceProvider),
  ),
);
```

### 3. experiment_play_screen.dart に予想ステップを追加

```dart
class ExperimentPlayScreen extends ConsumerStatefulWidget {
  // ... 既存コード ...
  
  @override
  ConsumerState<ExperimentPlayScreen> createState() => 
    _ExperimentPlayScreenState();
}

class _ExperimentPlayScreenState 
    extends ConsumerState<ExperimentPlayScreen> {
  
  int currentStep = 0;
  String? userPrediction;
  List<String> answers = [];
  
  @override
  void initState() {
    super.initState();
    // Step 0（予想）から開始
    // currentStep = 0 → 予想画面を表示
  }
  
  void _selectPrediction(String choice) {
    setState(() {
      userPrediction = choice;
      currentStep = 1; // Step 1 へ進む
    });
  }
  
  void _selectAnswer(int choiceIndex) {
    setState(() {
      answers.add(experiment.steps[currentStep].choices[choiceIndex]);
      if (currentStep < 4) {
        currentStep++;
      } else {
        _showResult();
      }
    });
  }
  
  void _showResult() {
    final isCorrect = userPrediction == experiment.predictionAnswer;
    
    // 統計を記録
    ref.read(predictionStatisticsProvider.notifier).recordPrediction(
      experimentId: experiment.id,
      userPrediction: userPrediction ?? '',
      actualAnswer: experiment.predictionAnswer,
      quizPassed: true, // TODO: クイズ本体の正解判定と連携
    );
    
    // 親ほめダイアログ & 結果表示（既存）
    _showParentPraiseDialog();
  }
  
  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(predictionStatisticsProvider);
    final experimentStats = stats[widget.experimentId];
    
    // Step 0: 予想画面
    if (currentStep == 0) {
      return PredictionStepWidget(
        experiment: experiment,
        onPredictionSelected: _selectPrediction,
      );
    }
    
    // Step 1-4: 通常クイズ（既存）
    return ChoiceWidget(
      step: experiment.steps[currentStep - 1], // -1 because Step 0 is prediction
      onAnswerSelected: _selectAnswer,
    );
  }
}
```

### 4. PredictionStepWidget (新規)

```dart
class PredictionStepWidget extends StatelessWidget {
  final Experiment experiment;
  final ValueChanged<String> onPredictionSelected;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Step 0: よそう')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'やってみよう！🔬',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 40),
          Text(
            experiment.predictionQuestion,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 60),
          ...experiment.predictionChoices.map((choice) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ElevatedButton(
                onPressed: () => onPredictionSelected(choice),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  choice,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 40),
          Text(
            '※ どちらが正しいと思う？',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
```

### 5. experiment_result_screen.dart 拡張

```dart
class ResultWidget extends ConsumerWidget {
  final ExperimentResult result;
  final String? userPrediction; // 追加
  final String predictionAnswer; // 追加
  
  bool get isPredictionCorrect => 
    userPrediction == predictionAnswer; // 追加
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(predictionStatisticsProvider);
    final experimentStats = stats[result.experimentId];
    
    return Column(
      children: [
        // 既存：成功メッセージ
        Text('すごい！クリア！🎉'),
        SizedBox(height: 20),
        
        // 新規：予想の当たり・外れ表示
        if (userPrediction != null) ...[
          Text('きみの予想：「$userPrediction」'),
          Text('実際の結果：「$predictionAnswer」'),
          Text(
            isPredictionCorrect ? 'あたり！🎯' : 'はずれ！もう一度',
            style: TextStyle(
              fontSize: 20,
              color: isPredictionCorrect ? Colors.green : Colors.orange,
            ),
          ),
          SizedBox(height: 20),
          
          // ボーナスコイン
          if (isPredictionCorrect)
            Text('+10 ボーナスコイン（予想的中！）'),
          
          SizedBox(height: 20),
        ],
        
        // 新規：予想的中率の表示
        if (experimentStats != null) ...[
          Text('予想的中率: ${experimentStats.predictionRate.toStringAsFixed(0)}%'),
          Text('目標: よそう名人（90%以上）'),
          if (experimentStats.predictionRate < 90)
            Text('あと +${(90 - experimentStats.predictionRate).toStringAsFixed(0)}% がんばろう！'),
          SizedBox(height: 30),
        ],
        
        // 既存：ほめカードボタン等
        // ...
      ],
    );
  }
}
```

---

## 🎯 バッジシステム連動

### 新規バッジ："よそう名人"
```dart
BadgeDefinition(
  id: 'prediction_master',
  name: 'よそう名人',
  description: '予想的中率が90%以上！',
  icon: 'assets/badges/prediction_master.png',
  unlockCondition: 'prediction_rate >= 90',
  category: BadgeCategory.skill,
  tier: 2, // シルバー
)
```

### 既存バッジ拡張
- よそう名人（新規）
- 既存の「習熟度バッジ」をよそう的中率でも判定

---

## 📈 分析指標

### Firebase Analytics イベント
```dart
analytics.logEvent(
  name: 'prediction_made',
  parameters: {
    'experiment_id': experimentId,
    'prediction': userPrediction,
    'is_correct': isPredictionCorrect,
  },
);

analytics.logEvent(
  name: 'prediction_rate_milestone',
  parameters: {
    'experiment_id': experimentId,
    'prediction_rate': experimentStats.predictionRate,
  },
);
```

---

## 🧪 テストケース

| ケース | 入力 | 期待結果 |
|--------|------|---------|
| 正解予想 | 「つく」選択→4ステップ正解 | +10コイン、的中率更新 |
| 誤り予想 | 「つかない」選択→4ステップ正解 | コインなし、記録のみ |
| わからない | 「わからない」選択→正解判定 | 記録、統計表示 |
| 90%達成 | 同実験 10回中 9回的中 | 「よそう名人」バッジ獲得 |
| 履歴表示 | 過去の予想をタップ | 月別統計グラフ表示 |

---

## ⚠️ 注意点

1. **予想と実験結果の連携**
   - `userPrediction` は result_screen で参照できる状態にする
   - state の持ち方に注意

2. **SharedPrefs キー衝突**
   - `prediction_stats_` prefix で既存キーと区別

3. **UI/UX**
   - Step 0 が追加されても「クイズは4ステップ」という認識を変えない
   - 結果画面で「的中率」がスクロール可能な位置か確認

4. **パフォーマンス**
   - 100実験分の統計は SharedPrefs で十分（数MB以下）
   - Firestore 移行時は transactions で consistency を保つ

---

## 📝 実装チェックリスト

- [ ] experiment_data.dart に 20実験全て predictionQuestion 追加
- [ ] PredictionStatisticsNotifier 実装
- [ ] experiment_play_screen に Step 0 追加
- [ ] PredictionStepWidget 実装
- [ ] experiment_result_screen に的中率表示
- [ ] よそう名人バッジ追加
- [ ] Firebase Analytics イベント定義
- [ ] Widget テスト (PredictionStepWidget)
- [ ] Integration テスト（予想→結果）
- [ ] CBT ユーザー 5名でテスト

---

**作成日**: 2026-06-10  
**設計版**: 1.0  
**次: 詳細コード設計書作成（実装開始時）**
