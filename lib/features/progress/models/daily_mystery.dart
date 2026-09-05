import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_mystery.freezed.dart';
part 'daily_mystery.g.dart';

@freezed
class DailyMystery with _$DailyMystery {
  const factory DailyMystery({
    required int id,
    required String question,
    required String answer,
    required String category,
    required int grade,
    required DateTime createdAt,
  }) = _DailyMystery;

  factory DailyMystery.fromJson(Map<String, dynamic> json) =>
      _$DailyMysteryFromJson(json);
}

@freezed
class DailyMysteryRecord with _$DailyMysteryRecord {
  const factory DailyMysteryRecord({
    required String userId,
    required int mysteryId,
    required DateTime revealedAt,
    required DateTime? answeredAt,
    required bool isCorrect,
  }) = _DailyMysteryRecord;

  factory DailyMysteryRecord.fromJson(Map<String, dynamic> json) =>
      _$DailyMysteryRecordFromJson(json);
}
