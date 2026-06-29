import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/home_lab_data.dart';

class HomeLabReport {
  final String missionId;
  final DateTime submittedAt;
  final String result;

  const HomeLabReport({
    required this.missionId,
    required this.submittedAt,
    required this.result,
  });
}

class HomeLabState {
  final List<HomeLabReport> reports;

  const HomeLabState({this.reports = const []});

  bool hasReportedThisWeek(String missionId) =>
      reports.any((r) => r.missionId == missionId);
}

class HomeLabNotifier extends StateNotifier<HomeLabState> {
  HomeLabNotifier() : super(const HomeLabState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('home_lab_report_'));
    final reports = keys.map((k) {
      final parts = (prefs.getString(k) ?? '').split('|');
      if (parts.length < 2) return null;
      return HomeLabReport(
        missionId: k.replaceFirst('home_lab_report_', ''),
        submittedAt: DateTime.tryParse(parts[0]) ?? DateTime.now(),
        result: parts.skip(1).join('|'),
      );
    }).whereType<HomeLabReport>().toList();
    state = HomeLabState(reports: reports);
  }

  Future<void> submitReport({
    required String missionId,
    required String result,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString(
      'home_lab_report_$missionId',
      '${now.toIso8601String()}|$result',
    );
    final updated = [
      ...state.reports.where((r) => r.missionId != missionId),
      HomeLabReport(missionId: missionId, submittedAt: now, result: result),
    ];
    state = HomeLabState(reports: updated);
  }
}

final homeLabProvider =
    StateNotifierProvider<HomeLabNotifier, HomeLabState>(
  (ref) => HomeLabNotifier(),
);

final currentMissionProvider = Provider<HomeLabMission>((ref) {
  return getTodaysMission();
});
