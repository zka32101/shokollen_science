import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../features/progress/models/user_progress_model.dart';
import 'firebase_service.dart';

/// Firestoreへの進捗データ同期
///
/// users/{uid}/data/progress ドキュメントの `profiles.<profileId>` に
/// プロフィールごとの進捗を保存する（ルールは progress 1ドキュメントのみ許可
/// のため、プロフィールごとにドキュメントを分けず1つにまとめている）。
class FirestoreProgressService {
  static String? get _uid => FirebaseService.userId;

  static DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = _uid;
    if (!FirebaseService.isAvailable || uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('data')
        .doc('progress');
  }

  /// Firestoreへアップロード（ローカル進捗をクラウドに保存）
  static Future<void> upload(String profileId, UserProgress progress) async {
    final doc = _doc;
    if (doc == null) return;
    try {
      // 該当プロフィールの項目だけを丸ごと置き換える（リセットも反映するため
      // deep merge の set は使わない）。ドキュメント未作成なら set で作る。
      try {
        await doc.update({
          FieldPath(['profiles', profileId]): progress.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (e) {
        if (e.code != 'not-found') rethrow;
        await doc.set({
          'profiles': {profileId: progress.toJson()},
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      debugPrint('[Firestore] 進捗アップロード完了 ($profileId)');
    } catch (e) {
      debugPrint('[Firestore] アップロード失敗: $e');
    }
  }

  /// Firestoreからダウンロード（クラウドの進捗を取得）
  ///
  /// クラウドに無ければ null。通信エラーなどは例外のまま投げる（呼び出し側が
  /// 「未保存」と「取得失敗」を区別し、失敗時に空のクラウドを上書きしないため）。
  static Future<UserProgress?> download(String profileId) async {
    final doc = _doc;
    if (doc == null) return null;
    final snap = await doc.get();
    final profiles = snap.data()?['profiles'];
    if (profiles is Map && profiles[profileId] is Map) {
      return UserProgress.fromJson(
        Map<String, dynamic>.from(profiles[profileId] as Map),
      );
    }
    return null;
  }

  /// 同期が使えるか（Firebase 初期化済みで匿名ログイン済み）
  static bool get isAvailable => _doc != null;

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
