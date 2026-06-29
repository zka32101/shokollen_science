import 'package:cloud_firestore/cloud_firestore.dart';

/// クイズ問題モデル
class QuestionModel {
  final String id;
  final String stageId;
  final int questionNumber;
  final String question;
  final String? questionImageUrl;
  final List<String> answers;
  final int correctAnswerIndex;
  final String explanation;
  final String? explanationImageUrl;
  final int timeLimit; // 秒単位
  final int difficultyLevel; // 1-5

  QuestionModel({
    required this.id,
    required this.stageId,
    required this.questionNumber,
    required this.question,
    this.questionImageUrl,
    required this.answers,
    required this.correctAnswerIndex,
    required this.explanation,
    this.explanationImageUrl,
    required this.timeLimit,
    required this.difficultyLevel,
  });

  /// Firestore から復元
  factory QuestionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return QuestionModel(
      id: doc.id,
      stageId: data['stageId'] ?? '',
      questionNumber: data['questionNumber'] ?? 0,
      question: data['question'] ?? '',
      questionImageUrl: data['questionImageUrl'],
      answers: List<String>.from(data['answers'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
      explanation: data['explanation'] ?? '',
      explanationImageUrl: data['explanationImageUrl'],
      timeLimit: data['timeLimit'] ?? 30,
      difficultyLevel: data['difficultyLevel'] ?? 1,
    );
  }

  /// Firestore へ保存
  Map<String, dynamic> toFirestore() {
    return {
      'stageId': stageId,
      'questionNumber': questionNumber,
      'question': question,
      'questionImageUrl': questionImageUrl,
      'answers': answers,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'explanationImageUrl': explanationImageUrl,
      'timeLimit': timeLimit,
      'difficultyLevel': difficultyLevel,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
