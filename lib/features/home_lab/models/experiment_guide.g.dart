// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_guide.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExperimentGuideImpl _$$ExperimentGuideImplFromJson(
  Map<String, dynamic> json,
) => _$ExperimentGuideImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  grade: (json['grade'] as num).toInt(),
  materials: (json['materials'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
  warningText: json['warningText'] as String,
  estimatedTime: (json['estimatedTime'] as num).toInt(),
  youtubeLink: json['youtubeLink'] as String?,
);

Map<String, dynamic> _$$ExperimentGuideImplToJson(
  _$ExperimentGuideImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'grade': instance.grade,
  'materials': instance.materials,
  'steps': instance.steps,
  'warningText': instance.warningText,
  'estimatedTime': instance.estimatedTime,
  'youtubeLink': instance.youtubeLink,
};
