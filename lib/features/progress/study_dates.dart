import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/streak_calendar.dart';
import '../profile/providers/profile_provider.dart';
import 'providers/user_progress_provider.dart';

const int kStudyDatesKeepDays = 180;

String studyDatesKey(String profileId) => 'study_dates_v1_$profileId';

String fmtStudyDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? parseStudyDate(String s) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
  if (m == null) return null;
  return DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
}

/// 現在の連続日数と最終学習日から、最終日までのN日分を復元する。
List<String> backfillStudyDates(int streakDays, String? lastPlayedDate) {
  final last = lastPlayedDate == null ? null : parseStudyDate(lastPlayedDate);
  if (last == null || streakDays <= 0) return [];
  final n = streakDays > kStudyDatesKeepDays ? kStudyDatesKeepDays : streakDays;
  return [
    for (var i = n - 1; i >= 0; i--)
      fmtStudyDate(DateTime(last.year, last.month, last.day - i)),
  ];
}

/// today を追記（重複なし・昇順・直近180日）。純関数。
List<String> addStudyDate(List<String> dates, String today) {
  final set = {...dates, today}.toList()..sort();
  final t = parseStudyDate(today);
  if (t == null) return set;
  final cutoff = fmtStudyDate(
    DateTime(t.year, t.month, t.day - (kStudyDatesKeepDays - 1)),
  );
  return set.where((d) => d.compareTo(cutoff) >= 0).toList();
}

/// 保存済みの日付（未保存なら連続情報からバックフィル）。
Future<List<String>> loadStudyDates(
  String profileId,
  int streakDays,
  String? lastPlayedDate,
) async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getStringList(studyDatesKey(profileId));
  if (saved != null) return saved;
  return backfillStudyDates(streakDays, lastPlayedDate);
}

/// 学習完了時に呼ぶ。prev は更新前の連続情報（初回のバックフィル用）。
Future<void> recordStudyDate(
  String profileId,
  String today,
  int prevStreakDays,
  String? prevLastPlayedDate,
) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final base = prefs.getStringList(studyDatesKey(profileId)) ??
        backfillStudyDates(prevStreakDays, prevLastPlayedDate);
    await prefs.setStringList(
      studyDatesKey(profileId),
      addStudyDate(base, today),
    );
  } catch (_) {}
}

/// 連続学習チップ等のタップで呼ぶ。
Future<void> openStreakCalendar(BuildContext context, WidgetRef ref) async {
  final p = ref.read(userProgressProvider).value;
  final profileId =
      ref.read(profileProvider).value?.activeProfileId ?? 'default';
  final list = await loadStudyDates(
    profileId,
    p?.streakDays ?? 0,
    p?.lastPlayedDate,
  );
  final days = <DateTime>{
    for (final s in list)
      if (parseStudyDate(s) != null) parseStudyDate(s)!,
  };
  if (!context.mounted) return;
  await showStreakCalendar(context, days);
}
