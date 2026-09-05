import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/incorrect_monster.dart';

/// IncorrectMonster のリポジトリインターフェース
abstract class IncorrectMonsterRepository {
  /// すべてのモンスターを取得
  Future<List<IncorrectMonster>> getAll();

  /// 特定のモンスターを ID で取得
  Future<IncorrectMonster?> getById(String id);

  /// questionId で既存モンスターを確認
  Future<IncorrectMonster?> getByQuestionId(String questionId);

  /// 新規モンスターを保存
  Future<void> save(IncorrectMonster monster);

  /// モンスターを更新
  Future<void> update(IncorrectMonster monster);

  /// モンスターを削除
  Future<void> delete(String id);

  /// 全モンスターを削除（デバッグ用）
  Future<void> deleteAll();

  /// モンスター総数を取得
  Future<int> getCount();
}

/// SharedPreferences を使った実装
class IncorrectMonsterRepositoryImpl implements IncorrectMonsterRepository {
  final SharedPreferences _prefs;
  static const String _storageKey = 'incorrect_monsters';

  IncorrectMonsterRepositoryImpl(this._prefs);

  @override
  Future<List<IncorrectMonster>> getAll() async {
    try {
      final jsonList = _prefs.getStringList(_storageKey) ?? [];
      return jsonList
          .map((json) => IncorrectMonster.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading monsters: $e');
      return [];
    }
  }

  @override
  Future<IncorrectMonster?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<IncorrectMonster?> getByQuestionId(String questionId) async {
    final all = await getAll();
    try {
      return all.firstWhere((m) => m.questionId == questionId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(IncorrectMonster monster) async {
    try {
      final all = await getAll();
      final updated = [...all, monster];
      await _prefs.setStringList(
        _storageKey,
        updated.map((m) => jsonEncode(m.toJson())).toList(),
      );
    } catch (e) {
      print('Error saving monster: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(IncorrectMonster monster) async {
    try {
      final all = await getAll();
      final updated = all.map((m) => m.id == monster.id ? monster : m).toList();
      await _prefs.setStringList(
        _storageKey,
        updated.map((m) => jsonEncode(m.toJson())).toList(),
      );
    } catch (e) {
      print('Error updating monster: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final all = await getAll();
      final updated = all.where((m) => m.id != id).toList();
      await _prefs.setStringList(
        _storageKey,
        updated.map((m) => jsonEncode(m.toJson())).toList(),
      );
    } catch (e) {
      print('Error deleting monster: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing monsters: $e');
      rethrow;
    }
  }

  @override
  Future<int> getCount() async {
    final all = await getAll();
    return all.length;
  }
}
