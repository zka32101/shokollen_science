import 'package:cloud_firestore/cloud_firestore.dart';

/// ステージ（単元）モデル
class StageModel {
  final String id;
  final String stageName;
  final String description;
  final int stageNumber;
  final int gradeLevel; // 学年: 3-6
  final String category; // biology, chemistry, physics, earth
  final String difficultyLevel; // easy, normal, hard
  final int totalQuestions;
  final String? imageUrl;
  final String learningGuide; // 学習ガイド

  StageModel({
    required this.id,
    required this.stageName,
    required this.description,
    required this.stageNumber,
    required this.gradeLevel,
    required this.category,
    required this.difficultyLevel,
    required this.totalQuestions,
    this.imageUrl,
    required this.learningGuide,
  });

  /// Firestore から復元
  factory StageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return StageModel(
      id: doc.id,
      stageName: data['stageName'] ?? '',
      description: data['description'] ?? '',
      stageNumber: data['stageNumber'] ?? 0,
      gradeLevel: data['gradeLevel'] ?? 3,
      category: data['category'] ?? 'biology',
      difficultyLevel: data['difficultyLevel'] ?? 'normal',
      totalQuestions: data['totalQuestions'] ?? 10,
      imageUrl: data['imageUrl'],
      learningGuide: data['learningGuide'] ?? '',
    );
  }

  /// Firestore へ保存
  Map<String, dynamic> toFirestore() {
    return {
      'stageName': stageName,
      'description': description,
      'stageNumber': stageNumber,
      'gradeLevel': gradeLevel,
      'category': category,
      'difficultyLevel': difficultyLevel,
      'totalQuestions': totalQuestions,
      'imageUrl': imageUrl,
      'learningGuide': learningGuide,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
