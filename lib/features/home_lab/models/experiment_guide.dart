import 'package:freezed_annotation/freezed_annotation.dart';

part 'experiment_guide.freezed.dart';
part 'experiment_guide.g.dart';

@freezed
class ExperimentGuide with _$ExperimentGuide {
  const factory ExperimentGuide({
    required String id,
    required String title,
    required String description,
    required String category,
    required int grade,
    required List<String> materials,
    required List<String> steps,
    required String warningText,
    required int estimatedTime,
    String? youtubeLink,
  }) = _ExperimentGuide;

  factory ExperimentGuide.fromJson(Map<String, dynamic> json) =>
      _$ExperimentGuideFromJson(json);
}
