import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/review_time_capsule_repository.dart';
import '../models/review_schedule.dart';

/// Repository プロバイダ
final reviewTimeCapsuleRepositoryProvider =
    Provider<ReviewTimeCapsuleRepository>((ref) {
  throw UnimplementedError(
    'Provide ReviewTimeCapsuleRepository in main.dart',
  );
});

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

/// 今日の復習数
final todayReviewCountProvider = FutureProvider<int>((ref) async {
  final reviews = await ref.watch(todayReviewsProvider.future);
  return reviews.length;
});

/// 特定のタイムカプセル
final specificTimeCapsuleProvider =
    FutureProvider.family<TimeCapsule?, String>((ref, capsuleId) async {
  final repository = ref.watch(reviewTimeCapsuleRepositoryProvider);
  return repository.getById(capsuleId);
});

/// 特定ステージのタイムカプセル
final timeCapsulesByStageProvider =
    FutureProvider.family<List<TimeCapsule>, String>((ref, stageId) async {
  final repository = ref.watch(reviewTimeCapsuleRepositoryProvider);
  return repository.getByStageId(stageId);
});

/// 完了済みタイムカプセル数
final completedCapsuleCountProvider = Provider<int>((ref) {
  final capsules = ref.watch(timeCapsuleProvider);
  return capsules.where((c) => c.isFullyCompleted).length;
});

/// 復習進行中のタイムカプセル
final inProgressCapsuleProvider =
    FutureProvider.family<TimeCapsule?, String>((ref, capsuleId) async {
  final repository = ref.watch(reviewTimeCapsuleRepositoryProvider);
  return repository.getById(capsuleId);
});

/// StateNotifier 実装
class ReviewTimeCapsuleNotifier extends StateNotifier<List<TimeCapsule>> {
  final ReviewTimeCapsuleRepository _repository;
  bool _isInitialized = false;

  ReviewTimeCapsuleNotifier(this._repository) : super([]) {
    _init();
  }

  /// 初期化
  Future<void> _init() async {
    if (_isInitialized) return;

    try {
      final capsules = await _repository.getAll();
      state = capsules;
      _isInitialized = true;
    } catch (e) {
      print('Error initializing time capsules: $e');
      state = [];
      _isInitialized = true;
    }
  }

  /// 新規タイムカプセルを作成
  Future<void> createFromQuestion({
    required String questionId,
    required String stageId,
    required int questionNumber,
    required String questionTitle,
  }) async {
    try {
      await _repository.createFromQuestion(
        questionId: questionId,
        stageId: stageId,
        questionNumber: questionNumber,
        questionTitle: questionTitle,
      );

      // リロード
      final updated = await _repository.getAll();
      state = updated;
    } catch (e) {
      print('Error creating time capsule: $e');
      rethrow;
    }
  }

  /// 復習を完了
  Future<void> completeReview(
    String capsuleId,
    ReviewInterval interval,
  ) async {
    try {
      await _repository.completeReview(capsuleId, interval);

      // リロード
      final updated = await _repository.getAll();
      state = updated;
    } catch (e) {
      print('Error completing review: $e');
      rethrow;
    }
  }

  /// タイムカプセルを削除
  Future<void> deleteTimeCapsule(String capsuleId) async {
    try {
      await _repository.delete(capsuleId);
      state = state.where((c) => c.id != capsuleId).toList();
    } catch (e) {
      print('Error deleting time capsule: $e');
      rethrow;
    }
  }

  /// すべてのタイムカプセルを削除（デバッグ用）
  Future<void> deleteAll() async {
    try {
      await _repository.deleteAll();
      state = [];
    } catch (e) {
      print('Error clearing time capsules: $e');
      rethrow;
    }
  }

  /// 今日の復習一覧を取得
  Future<List<TimeCapsule>> getTodayReviews() async {
    try {
      return await _repository.getTodayReviews();
    } catch (e) {
      print('Error getting today reviews: $e');
      rethrow;
    }
  }

  /// 特定のステージのタイムカプセルを取得
  List<TimeCapsule> getByStageId(String stageId) {
    return state.where((c) => c.stageId == stageId).toList();
  }

  /// タイムカプセルが存在するか
  Future<bool> hasTimeCapsule(String questionId) async {
    final existing = state.where((c) => c.questionId == questionId);
    return existing.isNotEmpty;
  }
}
