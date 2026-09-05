import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/review_schedule.dart';

/// 復習タイムカプセル Repository インターフェース
abstract class ReviewTimeCapsuleRepository {
  /// すべてのタイムカプセルを取得
  Future<List<TimeCapsule>> getAll();

  /// 特定のタイムカプセルを ID で取得
  Future<TimeCapsule?> getById(String id);

  /// 特定のステージのタイムカプセルを取得
  Future<List<TimeCapsule>> getByStageId(String stageId);

  /// 今日の復習一覧を取得
  Future<List<TimeCapsule>> getTodayReviews();

  /// 新規タイムカプセルを作成
  Future<void> createFromQuestion({
    required String questionId,
    required String stageId,
    required int questionNumber,
    required String questionTitle,
  });

  /// 復習を完了
  Future<void> completeReview(String capsuleId, ReviewInterval interval);

  /// タイムカプセルを更新
  Future<void> update(TimeCapsule capsule);

  /// タイムカプセルを削除
  Future<void> delete(String capsuleId);

  /// すべてのタイムカプセルを削除（デバッグ用）
  Future<void> deleteAll();

  /// タイムカプセル総数を取得
  Future<int> getCount();
}

/// SharedPreferences を使った実装
class ReviewTimeCapsuleRepositoryImpl implements ReviewTimeCapsuleRepository {
  final SharedPreferences _prefs;
  static const String _storageKey = 'review_time_capsules';

  ReviewTimeCapsuleRepositoryImpl(this._prefs);

  @override
  Future<List<TimeCapsule>> getAll() async {
    try {
      final jsonList = _prefs.getStringList(_storageKey) ?? [];
      return jsonList
          .map((json) =>
              TimeCapsule.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading time capsules: $e');
      return [];
    }
  }

  @override
  Future<TimeCapsule?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TimeCapsule>> getByStageId(String stageId) async {
    final all = await getAll();
    return all.where((c) => c.stageId == stageId).toList();
  }

  @override
  Future<List<TimeCapsule>> getTodayReviews() async {
    final all = await getAll();
    return all.where((c) {
      final next = c.getNextReview();
      return next != null && next.isReviewDueToday();
    }).toList();
  }

  @override
  Future<void> createFromQuestion({
    required String questionId,
    required String stageId,
    required int questionNumber,
    required String questionTitle,
  }) async {
    try {
      // 既存のタイムカプセルがないか確認
      final existing = await getAll();
      if (existing.any((c) => c.questionId == questionId)) {
        // 既に存在する
        return;
      }

      // 新規作成
      final capsule = createNewTimeCapsule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        questionId: questionId,
        stageId: stageId,
        questionNumber: questionNumber,
        questionTitle: questionTitle,
      );

      await update(capsule);
    } catch (e) {
      print('Error creating time capsule: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeReview(String capsuleId, ReviewInterval interval) async {
    try {
      final capsule = await getById(capsuleId);
      if (capsule == null) return;

      // 復習スケジュールを更新
      final updatedSchedules = capsule.schedules.map((s) {
        if (s.interval == interval && s.status == ReviewStatus.pending) {
          return s.copyWith(
            status: ReviewStatus.completed,
            completedAt: DateTime.now(),
          );
        }
        return s;
      }).toList();

      // 完了カウントを更新
      final completedCount =
          updatedSchedules.where((s) => s.status == ReviewStatus.completed).length;

      final updated = capsule.copyWith(
        schedules: updatedSchedules,
        completedCount: completedCount,
        isFullyCompleted: completedCount == 4,
      );

      await update(updated);
    } catch (e) {
      print('Error completing review: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(TimeCapsule capsule) async {
    try {
      final all = await getAll();
      final exists = all.any((c) => c.id == capsule.id);
      final updated = exists
          ? all.map((c) => c.id == capsule.id ? capsule : c).toList()
          : [...all, capsule];
      await _prefs.setStringList(
        _storageKey,
        updated.map((c) => jsonEncode(c.toJson())).toList(),
      );
    } catch (e) {
      print('Error updating time capsule: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String capsuleId) async {
    try {
      final all = await getAll();
      final updated = all.where((c) => c.id != capsuleId).toList();
      await _prefs.setStringList(
        _storageKey,
        updated.map((c) => jsonEncode(c.toJson())).toList(),
      );
    } catch (e) {
      print('Error deleting time capsule: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing time capsules: $e');
      rethrow;
    }
  }

  @override
  Future<int> getCount() async {
    final all = await getAll();
    return all.length;
  }
}
