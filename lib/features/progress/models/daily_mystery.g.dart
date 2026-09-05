// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_mystery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyMysteryImpl _$$DailyMysteryImplFromJson(Map<String, dynamic> json) =>
    _$DailyMysteryImpl(
      id: (json['id'] as num).toInt(),
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String,
      grade: (json['grade'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DailyMysteryImplToJson(_$DailyMysteryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'category': instance.category,
      'grade': instance.grade,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$DailyMysteryRecordImpl _$$DailyMysteryRecordImplFromJson(
  Map<String, dynamic> json,
) => _$DailyMysteryRecordImpl(
  userId: json['userId'] as String,
  mysteryId: (json['mysteryId'] as num).toInt(),
  revealedAt: DateTime.parse(json['revealedAt'] as String),
  answeredAt: json['answeredAt'] == null
      ? null
      : DateTime.parse(json['answeredAt'] as String),
  isCorrect: json['isCorrect'] as bool,
);

Map<String, dynamic> _$$DailyMysteryRecordImplToJson(
  _$DailyMysteryRecordImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'mysteryId': instance.mysteryId,
  'revealedAt': instance.revealedAt.toIso8601String(),
  'answeredAt': instance.answeredAt?.toIso8601String(),
  'isCorrect': instance.isCorrect,
};
