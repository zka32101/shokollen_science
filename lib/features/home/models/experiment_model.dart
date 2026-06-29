import 'package:cloud_firestore/cloud_firestore.dart';

/// 実験・観察コンテンツモデル
class ExperimentModel {
  final String id;
  final String title;
  final String description;
  final String relatedStageId; // 関連する学習単元
  final String videoUrl; // YouTube または Firebase Storage URL
  final String materialsList; // 材料リスト
  final String procedure; // 実験手順（マークダウン形式）
  final String safetyWarning; // 安全上の注意
  final String expectedResult; // 予想される結果
  final String explanation; // 科学的な説明
  final int estimatedTime; // 分単位

  ExperimentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.relatedStageId,
    required this.videoUrl,
    required this.materialsList,
    required this.procedure,
    required this.safetyWarning,
    required this.expectedResult,
    required this.explanation,
    required this.estimatedTime,
  });

  /// Firestore から復元
  factory ExperimentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ExperimentModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      relatedStageId: data['relatedStageId'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      materialsList: data['materialsList'] ?? '',
      procedure: data['procedure'] ?? '',
      safetyWarning: data['safetyWarning'] ?? '',
      expectedResult: data['expectedResult'] ?? '',
      explanation: data['explanation'] ?? '',
      estimatedTime: data['estimatedTime'] ?? 15,
    );
  }

  /// Firestore へ保存
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'relatedStageId': relatedStageId,
      'videoUrl': videoUrl,
      'materialsList': materialsList,
      'procedure': procedure,
      'safetyWarning': safetyWarning,
      'expectedResult': expectedResult,
      'explanation': explanation,
      'estimatedTime': estimatedTime,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
