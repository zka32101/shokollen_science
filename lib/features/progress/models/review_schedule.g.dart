// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewScheduleImpl _$$ReviewScheduleImplFromJson(Map<String, dynamic> json) =>
    _$ReviewScheduleImpl(
      interval: $enumDecode(_$ReviewIntervalEnumMap, json['interval']),
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
      status:
          $enumDecodeNullable(_$ReviewStatusEnumMap, json['status']) ??
          ReviewStatus.pending,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$ReviewScheduleImplToJson(
  _$ReviewScheduleImpl instance,
) => <String, dynamic>{
  'interval': _$ReviewIntervalEnumMap[instance.interval]!,
  'nextReviewDate': instance.nextReviewDate.toIso8601String(),
  'status': _$ReviewStatusEnumMap[instance.status]!,
  'completedAt': instance.completedAt?.toIso8601String(),
};

const _$ReviewIntervalEnumMap = {
  ReviewInterval.day1: 'day1',
  ReviewInterval.day3: 'day3',
  ReviewInterval.week1: 'week1',
  ReviewInterval.month1: 'month1',
};

const _$ReviewStatusEnumMap = {
  ReviewStatus.pending: 'pending',
  ReviewStatus.completed: 'completed',
  ReviewStatus.skipped: 'skipped',
};

_$TimeCapsuleImpl _$$TimeCapsuleImplFromJson(Map<String, dynamic> json) =>
    _$TimeCapsuleImpl(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      stageId: json['stageId'] as String,
      questionNumber: (json['questionNumber'] as num).toInt(),
      questionTitle: json['questionTitle'] as String,
      firstCorrectDate: DateTime.parse(json['firstCorrectDate'] as String),
      schedules:
          (json['schedules'] as List<dynamic>?)
              ?.map((e) => ReviewSchedule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      isFullyCompleted: json['isFullyCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$TimeCapsuleImplToJson(_$TimeCapsuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'questionId': instance.questionId,
      'stageId': instance.stageId,
      'questionNumber': instance.questionNumber,
      'questionTitle': instance.questionTitle,
      'firstCorrectDate': instance.firstCorrectDate.toIso8601String(),
      'schedules': instance.schedules,
      'completedCount': instance.completedCount,
      'isFullyCompleted': instance.isFullyCompleted,
    };
