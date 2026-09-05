import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../daily_mysteries_data.dart';
import '../../models/daily_mystery.dart';

abstract class DailyMysteryRepository {
  Future<DailyMystery?> getTodayMystery();
  Future<DailyMysteryRecord?> getTodayRecord();
  Future<void> recordRevealed(int mysteryId);
  Future<void> recordAnswered(int mysteryId, bool isCorrect);
  Future<List<DailyMysteryRecord>> getAll();
  Future<void> clear();
}

class DailyMysteryRepositoryImpl implements DailyMysteryRepository {
  final SharedPreferences prefs;

  DailyMysteryRepositoryImpl(this.prefs);

  static const _keyPrefix = 'daily_mystery_';
  static const _keyTodayRecord = 'daily_mystery_today_record';

  String _getDateKey() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<DailyMystery?> getTodayMystery() async {
    if (dailyMysteriesData.isEmpty) return null;
    return pickTodayMystery();
  }

  @override
  Future<DailyMysteryRecord?> getTodayRecord() async {
    final dateKey = _getDateKey();
    final json = prefs.getString(_keyPrefix + dateKey);
    if (json == null) return null;

    try {
      return DailyMysteryRecord.fromJson(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> recordRevealed(int mysteryId) async {
    final dateKey = _getDateKey();
    final record = DailyMysteryRecord(
      userId: 'local',
      mysteryId: mysteryId,
      revealedAt: DateTime.now(),
      answeredAt: null,
      isCorrect: false,
    );

    await prefs.setString(
      _keyPrefix + dateKey,
      jsonEncode(record.toJson()),
    );
  }

  @override
  Future<void> recordAnswered(int mysteryId, bool isCorrect) async {
    final dateKey = _getDateKey();
    final existing = await getTodayRecord();

    if (existing != null) {
      final updated = existing.copyWith(
        answeredAt: DateTime.now(),
        isCorrect: isCorrect,
      );
      await prefs.setString(
        _keyPrefix + dateKey,
        jsonEncode(updated.toJson()),
      );
    }
  }

  @override
  Future<List<DailyMysteryRecord>> getAll() async {
    final result = <DailyMysteryRecord>[];
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();

    for (final key in keys) {
      try {
        final json = prefs.getString(key);
        if (json != null) {
          result.add(DailyMysteryRecord.fromJson(jsonDecode(json)));
        }
      } catch (e) {
        continue;
      }
    }

    return result;
  }

  @override
  Future<void> clear() async {
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
