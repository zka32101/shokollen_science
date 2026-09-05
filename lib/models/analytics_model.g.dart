// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyStatsImpl _$$DailyStatsImplFromJson(Map<String, dynamic> json) =>
    _$DailyStatsImpl(
      date: json['date'] as String,
      questsCompleted: (json['questsCompleted'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      totalAnswers: (json['totalAnswers'] as num).toInt(),
      coinsEarned: (json['coinsEarned'] as num).toInt(),
      studyMinutes: (json['studyMinutes'] as num).toInt(),
      categoryStats: json['categoryStats'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$DailyStatsImplToJson(_$DailyStatsImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'questsCompleted': instance.questsCompleted,
      'correctAnswers': instance.correctAnswers,
      'totalAnswers': instance.totalAnswers,
      'coinsEarned': instance.coinsEarned,
      'studyMinutes': instance.studyMinutes,
      'categoryStats': instance.categoryStats,
    };

_$MonthlyStatsImpl _$$MonthlyStatsImplFromJson(Map<String, dynamic> json) =>
    _$MonthlyStatsImpl(
      month: json['month'] as String,
      totalQuestsCompleted: (json['totalQuestsCompleted'] as num).toInt(),
      totalCorrectAnswers: (json['totalCorrectAnswers'] as num).toInt(),
      totalAnswers: (json['totalAnswers'] as num).toInt(),
      accuracyRate: (json['accuracyRate'] as num).toDouble(),
      totalStudyMinutes: (json['totalStudyMinutes'] as num).toInt(),
      totalCoinsEarned: (json['totalCoinsEarned'] as num).toInt(),
      studyDaysCount: (json['studyDaysCount'] as num).toInt(),
      categoryStats: json['categoryStats'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$MonthlyStatsImplToJson(_$MonthlyStatsImpl instance) =>
    <String, dynamic>{
      'month': instance.month,
      'totalQuestsCompleted': instance.totalQuestsCompleted,
      'totalCorrectAnswers': instance.totalCorrectAnswers,
      'totalAnswers': instance.totalAnswers,
      'accuracyRate': instance.accuracyRate,
      'totalStudyMinutes': instance.totalStudyMinutes,
      'totalCoinsEarned': instance.totalCoinsEarned,
      'studyDaysCount': instance.studyDaysCount,
      'categoryStats': instance.categoryStats,
    };
