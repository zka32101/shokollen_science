import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/seeds/stages.dart';
import '../data/seeds/sample_questions.dart';
import '../data/seeds/creatures.dart';
import '../data/seeds/detailed_explanations.dart';

/// Firestore へのデータシーディングサービス
/// 開発時のみ使用（本番環境ではコメントアウト）
class FirestoreSeeding {
  static final _firestore = FirebaseFirestore.instance;

  /// すべてのコンテンツデータをシーディング
  static Future<void> seedAllContent() async {
    try {
      // 既存データを確認
      final stagesSnapshot = await _firestore.collection('stages').limit(1).get();
      if (stagesSnapshot.docs.isNotEmpty) {
        print('⚠️  既にデータが存在します。スキップします。');
        return;
      }

      print('🌱 Firestore シーディング開始...');

      // ステージデータをシーディング
      await _seedStages();
      print('✅ ステージデータをシーディング完了');

      // 問題データをシーディング
      await _seedQuestions();
      print('✅ 問題データをシーディング完了');

      // 詳細解説データをシーディング
      await _seedDetailedExplanations();
      print('✅ 詳細解説をシーディング完了');

      // 生き物データをシーディング
      await _seedCreatures();
      print('✅ 生き物図鑑をシーディング完了');

      print('🎉 すべてのシーディングが完了しました！');
    } catch (e) {
      print('❌ シーディングエラー: $e');
      rethrow;
    }
  }

  /// ステージデータをシーディング
  static Future<void> _seedStages() async {
    final batch = _firestore.batch();

    for (final stageData in stagesData) {
      final docRef =
          _firestore.collection('stages').doc(stageData['id'] as String);
      batch.set(docRef, stageData);
    }

    await batch.commit();
  }

  /// 問題データをシーディング
  static Future<void> _seedQuestions() async {
    final batch = _firestore.batch();
    int questionId = 1;

    for (final questionData in sampleQuestionsData) {
      final stageId = questionData['stageId'] as String;
      final docRef = _firestore
          .collection('stages')
          .doc(stageId)
          .collection('questions')
          .doc('q_$questionId');

      batch.set(docRef, questionData);
      questionId++;
    }

    await batch.commit();
  }

  /// 詳細解説をシーディング（新モデル対応：keyPoints・videos・comparisonTable）
  static Future<void> _seedDetailedExplanations() async {
    // Firestore は List<Map> をそのまま保存できるので変換不要
    // ただし 500件/バッチ制限のため複数バッチに分割
    const batchSize = 200;
    for (var i = 0; i < detailedExplanationsData.length; i += batchSize) {
      final batch = _firestore.batch();
      final slice = detailedExplanationsData.skip(i).take(batchSize);
      for (final data in slice) {
        final questionId = data['questionId'] as String;
        final docRef = _firestore.collection('explanations').doc(questionId);
        batch.set(docRef, data);
      }
      await batch.commit();
    }
  }

  /// 生き物図鑑をシーディング
  static Future<void> _seedCreatures() async {
    final batch = _firestore.batch();

    for (final creatureData in creaturesData) {
      final docRef = _firestore
          .collection('creatures')
          .doc(creatureData['id'] as String);
      batch.set(docRef, creatureData);
    }

    await batch.commit();
  }

  /// 特定のステージをシーディング（単独で実行したい場合）
  static Future<void> seedStageContent(String stageId) async {
    try {
      final stageData =
          stagesData.firstWhere((s) => s['id'] == stageId, orElse: () => {});

      if (stageData.isEmpty) {
        print('⚠️  ステージID「$stageId」が見つかりません');
        return;
      }

      // ステージデータをシーディング
      await _firestore.collection('stages').doc(stageId).set(stageData);

      // 関連する問題をシーディング
      final relatedQuestions = sampleQuestionsData
          .where((q) => q['stageId'] == stageId)
          .toList();

      final batch = _firestore.batch();
      for (var i = 0; i < relatedQuestions.length; i++) {
        final docRef = _firestore
            .collection('stages')
            .doc(stageId)
            .collection('questions')
            .doc('q_${i + 1}');
        batch.set(docRef, relatedQuestions[i]);
      }
      await batch.commit();

      print('✅ ステージ「$stageId」とその問題をシーディング完了');
    } catch (e) {
      print('❌ エラー: $e');
      rethrow;
    }
  }

  /// ステージ一覧を取得
  static Future<List<Map<String, dynamic>>> getStages() async {
    try {
      final snapshot = await _firestore
          .collection('stages')
          .orderBy('stageNumber')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ エラー: $e');
      return [];
    }
  }

  /// 学年別のステージを取得
  static Future<List<Map<String, dynamic>>> getStagesByGrade(
      int gradeLevel) async {
    try {
      final snapshot = await _firestore
          .collection('stages')
          .where('gradeLevel', isEqualTo: gradeLevel)
          .orderBy('stageNumber')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ エラー: $e');
      return [];
    }
  }

  /// 特定のステージの問題を取得
  static Future<List<Map<String, dynamic>>> getQuestions(String stageId) async {
    try {
      final snapshot = await _firestore
          .collection('stages')
          .doc(stageId)
          .collection('questions')
          .orderBy('questionNumber')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ エラー: $e');
      return [];
    }
  }

  /// 生き物図鑑を取得
  static Future<List<Map<String, dynamic>>> getCreatures() async {
    try {
      final snapshot = await _firestore.collection('creatures').get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ エラー: $e');
      return [];
    }
  }

  /// カテゴリ別の生き物を取得
  static Future<List<Map<String, dynamic>>> getCreaturesByCategory(
      String category) async {
    try {
      final snapshot = await _firestore
          .collection('creatures')
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ エラー: $e');
      return [];
    }
  }
}
