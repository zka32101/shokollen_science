// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incorrect_monster.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IncorrectMonsterImpl _$$IncorrectMonsterImplFromJson(
  Map<String, dynamic> json,
) => _$IncorrectMonsterImpl(
  id: json['id'] as String,
  questionId: json['questionId'] as String,
  stageId: json['stageId'] as String,
  questionNumber: (json['questionNumber'] as num).toInt(),
  monsterName: json['monsterName'] as String,
  firstIncorrectDate: DateTime.parse(json['firstIncorrectDate'] as String),
  correctionsCount: (json['correctionsCount'] as num?)?.toInt() ?? 0,
  evolutionState:
      $enumDecodeNullable(_$EvolutionStateEnumMap, json['evolutionState']) ??
      EvolutionState.baby,
  correctionDates:
      (json['correctionDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$IncorrectMonsterImplToJson(
  _$IncorrectMonsterImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'questionId': instance.questionId,
  'stageId': instance.stageId,
  'questionNumber': instance.questionNumber,
  'monsterName': instance.monsterName,
  'firstIncorrectDate': instance.firstIncorrectDate.toIso8601String(),
  'correctionsCount': instance.correctionsCount,
  'evolutionState': _$EvolutionStateEnumMap[instance.evolutionState]!,
  'correctionDates': instance.correctionDates
      .map((e) => e.toIso8601String())
      .toList(),
};

const _$EvolutionStateEnumMap = {
  EvolutionState.baby: 'baby',
  EvolutionState.juvenile: 'juvenile',
  EvolutionState.adult: 'adult',
  EvolutionState.sage: 'sage',
};
