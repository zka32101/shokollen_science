import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../features/progress/models/user_progress_model.dart';
import 'firebase_service.dart';

/// Firestoreへの進捗データ同期
/// users/{uid}/data/progress ドキュメントに保存
class FirestoreProgressService {
  static final _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseService.userId;

  /// Firestoreへアップロード（ローカル進捗をクラウドに保存）
  static Future<void> upload(UserProgress progress) async {
    if (!FirebaseService.isAvailable || _uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('data')
          .doc('progress')
          .set(progress.toJson(), SetOptions(merge: false));
      debugPrint('[Firestore] 進捗アップロード完了');
    } catch (e) {
      debugPrint('[Firestore] アップロード失敗: $e');
    }
  }

  /// Firestoreからダウンロード（クラウドの進捗を取得）
  static Future<UserProgress?> download() async {
    if (!FirebaseService.isAvailable || _uid == null) return null;
    try {
      final doc = await _db
          .collection('users')
          .doc(_uid)
          .collection('data')
          .doc('progress')
          .get();
      if (doc.exists && doc.data() != null) {
        return UserProgress.fromJson(doc.data()!);
      }
    } catch (e) {
      debugPrint('[Firestore] ダウンロード失敗: $e');
    }
    return null;
  }

  /// ローカルとクラウドをマージ（スコアの高い方・バッジは和集合）
  static UserProgress merge(UserProgress local, UserProgress remote) {
    final mergedStages = Map<String, int>.from(local.clearedStages);
    for (final entry in remote.clearedStages.entries) {
      final localScore = mergedStages[entry.key] ?? 0;
      if (entry.value > localScore) mergedStages[entry.key] = entry.value;
    }
    return local.copyWith(
      totalPoints: local.totalPoints > remote.totalPoints
          ? local.totalPoints
          : remote.totalPoints,
      coins: local.coins > remote.coins ? local.coins : remote.coins,
      streakDays: local.streakDays > remote.streakDays
          ? local.streakDays
          : remote.streakDays,
      clearedStages: mergedStages,
      earnedBadgeIds: {
        ...local.earnedBadgeIds,
        ...remote.earnedBadgeIds,
      }.toList(),
      purchasedItemIds: {
        ...local.purchasedItemIds,
        ...remote.purchasedItemIds,
      }.toList(),
    );
  }
}
