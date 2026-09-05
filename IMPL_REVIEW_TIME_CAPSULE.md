# 実装ガイド: ⑦ 復習タイムカプセル（Review Time Capsule）

**開始日**: 2026-07-02 | **推定工期**: 1-2 週間 | **優先度**: 🥈次優先

---

## 📋 概要

**機能名**: Review Time Capsule / 復習タイムカプセル  
**説明**: 正解した問題を忘却曲線（Ebbinghaus）に基づいて自動再出題する機能  
**心理学的根拠**: Ebbinghaus の忘却曲線理論に基づく段階的復習  
**学習効果**: 学習定着率を +30-50% 向上させる

---

## 🎯 実装範囲

### 内蔵内容（MVP）
- ✅ 正解した問題を自動キャプチャ
- ✅ 4段階の復習スケジュール（1日→3日→1週間→1ヶ月）
- ✅ 「今日の復習」画面
- ✅ 復習の進行状況を可視化
- ✅ 復習完了時のバッジ付与

### 含まない（Phase 2）
- ❌ カスタマイズ可能なスケジュール
- ❌ スマート復習（AI による難易度調整）

---

## 📊 データモデル

### 1. TimeCapsule テーブル

```dart
// lib/features/progress/models/review_schedule.dart

enum ReviewInterval {
  day1,    // 1日後
  day3,    // 3日後
  week1,   // 1週間後
  month1,  // 1ヶ月後
}

extension ReviewIntervalExt on ReviewInterval {
  String get label => {
    ReviewInterval.day1: '1日後',
    ReviewInterval.day3: '3日後',
    ReviewInterval.week1: '1週間後',
    ReviewInterval.month1: '1ヶ月後',
  }[this]!;

  Duration get duration => {
    ReviewInterval.day1: Duration(days: 1),
    ReviewInterval.day3: Duration(days: 3),
    ReviewInterval.week1: Duration(days: 7),
    ReviewInterval.month1: Duration(days: 30),
  }[this]!;

  int get order => {
    ReviewInterval.day1: 1,
    ReviewInterval.day3: 2,
    ReviewInterval.week1: 3,
    ReviewInterval.month1: 4,
  }[this]!;
}

enum ReviewStatus {
  pending,    // 復習待機中
  completed,  // 復習完了
  skipped,    // スキップ
}

@freezed
class ReviewSchedule with _$ReviewSchedule {
  const factory ReviewSchedule({
    required ReviewInterval interval,
    required DateTime nextReviewDate,
    required ReviewStatus status,
    DateTime? completedAt,
  }) = _ReviewSchedule;
}

@freezed
class TimeCapsule with _$TimeCapsule {
  const factory TimeCapsule({
    required String id,                    // UUID
    required String questionId,            // "stage_3_001_q1"
    required String stageId,               // "stage_3_001"
    required int questionNumber,           // 1-10
    required String questionTitle,         // 問題タイトル
    required DateTime firstCorrectDate,    // 初回正解日時
    @Default([]) List<ReviewSchedule> schedules, // 復習スケジュール
    @Default(0) int completedCount,       // 完了した復習数（0-4）
    @Default(false) bool isFullyCompleted, // すべての復習を完了したか
  }) = _TimeCapsule;

  const TimeCapsule._();

  /// 次の復習を取得
  ReviewSchedule? getNextReview() {
    try {
      return schedules.firstWhere(
        (s) => s.status == ReviewStatus.pending,
      );
    } catch (e) {
      return null;
    }
  }

  /// 今日の復習に含まれるか
  bool isReviewDueToday() {
    final next = getNextReview();
    if (next == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      next.nextReviewDate.year,
      next.nextReviewDate.month,
      next.nextReviewDate.day,
    );

    return dueDate.isBefore(today) || dueDate.isAtSameMomentAs(today);
  }

  /// 進行状況（0.0-1.0）
  double get progressPercent => completedCount / 4.0;

  factory TimeCapsule.fromJson(Map<String, dynamic> json) =>
      _$TimeCapsuleFromJson(json);
}
```

### 2. Repository インターフェース

```dart
// lib/features/progress/data/repositories/review_time_capsule_repository.dart

abstract class ReviewTimeCapsuleRepository {
  /// すべてのタイムカプセルを取得
  Future<List<TimeCapsule>> getAll();

  /// 新規タイムカプセルを作成
  Future<void> createFromQuestion(
    String questionId,
    String stageId,
    int questionNumber,
    String questionTitle,
  );

  /// 復習を完了
  Future<void> completeReview(String capsuleId, ReviewInterval interval);

  /// 今日の復習一覧を取得
  Future<List<TimeCapsule>> getTodayReviews();

  /// タイムカプセルを削除
  Future<void> delete(String capsuleId);
}
```

---

## 🎨 UI 実装

### 1. 今日の復習スクリーン

```
╔════════════════════════════════╗
║   復習タイムカプセル           ║
╠════════════════════════════════╣
║                                ║
║  ⏰ 今日の復習: 3個待機中      ║
║                                ║
║  ┌────────────────────────────┐║
║  │ 問1. 昆虫のからだのつくり  ││  ← 1日復習待ち
║  │ ・1日後 ✓ [復習する]       ││
║  └────────────────────────────┘║
║                                ║
║  ┌────────────────────────────┐║
║  │ 問2. 水の状態変化          ││  ← 3日復習待ち
║  │ ・3日後 [復習する]         ││
║  └────────────────────────────┘║
║                                ║
║  ┌────────────────────────────┐║
║  │ 問3. 植物の成長             ││  ← 1週間復習待ち
║  │ ・1週間後 [復習する]       ││
║  └────────────────────────────┘║
║                                ║
╚════════════════════════════════╝
```

### 2. ホーム画面バッジ

```
┌──────────────────────────┐
│ 復習タイムカプセル 3個   │  ← タップでスクリーンへ
│ ⏰ 今日の復習             │
└──────────────────────────┘
```

### 3. 復習クイズ結果

```
クイズ完了後:

[復習を記録]
↓
TimeCapsule に復習完了を記録
↓
ProgressBar 更新
↓
すべて完了 → バッジ獲得 → 「復習マスター」
```

---

## 🧮 忘却曲線スケジュール

| 復習 | タイミング | 条件 | 説明 |
|---|---|---|---|
| 1 | 初回正解の 1 日後 | 初回正解日：7/2 → 復習：7/3 | 記憶の定着（短期） |
| 2 | 初回正解の 3 日後 | 初回正解日：7/2 → 復習：7/5 | 記憶の強化 |
| 3 | 初回正解の 1 週間後 | 初回正解日：7/2 → 復習：7/9 | 長期記憶化 |
| 4 | 初回正解の 1 ヶ月後 | 初回正解日：7/2 → 復習：8/1 | 完全習熟 |

**Ebbinghaus 曲線**:
- 5 分後の復習 → 記憶率 100%
- 1 日後の復習 → 記憶率 ~67%（定着）
- 3 日後の復習 → 記憶率 ~45%（強化）
- 1 週間後の復習 → 記憶率 ~30%（長期化）
- 1 ヶ月後の復習 → 記憶率 ~15%（確実化）

---

## 🔧 実装手順

### Week 1: データ層

- [ ] `ReviewSchedule` & `TimeCapsule` モデル定義（freezed）
- [ ] `ReviewTimeCapsuleRepository` 実装
- [ ] Riverpod Provider 実装（timeCapsuleProvider）
- [ ] ユニットテスト（45個程度）

### Week 2: UI + 統合

- [ ] 「今日の復習」スクリーン実装
- [ ] ホーム画面バッジ追加
- [ ] クイズ結果画面統合
- [ ] UI テスト + 統合テスト
- [ ] ベータテスト

---

## 📝 Riverpod Provider 設計

```dart
// lib/features/progress/providers/review_time_capsule_provider.dart

/// すべてのタイムカプセル
final timeCapsuleProvider = StateNotifierProvider<
    ReviewTimeCapsuleNotifier,
    List<TimeCapsule>>((ref) {
  final repository = ref.watch(reviewTimeCapsuleRepositoryProvider);
  return ReviewTimeCapsuleNotifier(repository);
});

/// 今日の復習一覧
final todayReviewsProvider = FutureProvider<List<TimeCapsule>>((ref) async {
  final repository = ref.watch(reviewTimeCapsuleRepositoryProvider);
  return repository.getTodayReviews();
});

/// 復習待機中の数
final pendingReviewCountProvider = Provider<int>((ref) {
  final capsules = ref.watch(timeCapsuleProvider);
  return capsules.where((c) => c.getNextReview() != null).length;
});

/// 進行中のタイムカプセル（復習中）
final inProgressCapsule Provider.family<TimeCapsule?, String>((ref, capsuleId) {
  final capsules = ref.watch(timeCapsuleProvider);
  try {
    return capsules.firstWhere((c) => c.id == capsuleId);
  } catch (e) {
    return null;
  }
});
```

---

## 🎯 統合ポイント

### QuizResultScreen での統合

```dart
// 正解した問題をタイムカプセルに登録
if (isCorrect) {
  await ref.read(timeCapsuleProvider.notifier).createFromQuestion(
    questionId: questionId,
    stageId: stageId,
    questionNumber: questionNumber,
    questionTitle: questionTitle,
  );
}
```

### ホーム画面での統合

```dart
// バッジ表示
final pendingCount = ref.watch(pendingReviewCountProvider);
if (pendingCount > 0) {
  _buildReviewTimeCapsuleBadge(pendingCount);
}
```

---

## ✨ 期待効果

| 指標 | 目標値 |
|---|---|
| 学習定着率向上 | +30-50% |
| DAU（復習タップ） | +15-20% |
| 継続率 7 日 | +10% |
| セッション時間 | +5分/日 |

---

## 📝 実装チェックリスト

### Week 1（データ層）
- [ ] `review_schedule.dart` （モデル定義）
- [ ] `review_time_capsule_repository.dart` （Repository）
- [ ] `review_time_capsule_provider.dart` （Riverpod）
- [ ] `review_schedule_test.dart` （テスト）
- [ ] `review_time_capsule_repository_test.dart` （テスト）
- [ ] `review_time_capsule_provider_test.dart` （テスト）

### Week 2（UI + 統合）
- [ ] `today_reviews_screen.dart` （今日の復習スクリーン）
- [ ] `home_screen.dart` 修正（バッジ追加）
- [ ] `quiz_result_screen.dart` 修正（タイムカプセル登録）
- [ ] UI テスト
- [ ] 統合テスト

---

## 🚀 最初のステップ

**Week 1 データ層実装から開始します。**

```
Phase 2-1: データモデル + Repository
Phase 2-2: Riverpod Provider
Phase 2-3: テスト実装
```

準備できていますか？

