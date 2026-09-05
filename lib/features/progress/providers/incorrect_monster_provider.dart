import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/repositories/incorrect_monster_repository.dart';
import '../models/incorrect_monster.dart';

/// Repository プロバイダ
final incorrectMonsterRepositoryProvider = Provider<IncorrectMonsterRepository>((ref) {
  // SharedPreferences の初期化は main.dart で実施済みと仮定
  // 実際には依存関係注入で IncorrectMonsterRepositoryImpl を渡す
  throw UnimplementedError('Provide IncorrectMonsterRepository in main.dart');
});

/// モンスター一覧プロバイダ
final incorrectMonstersProvider = StateNotifierProvider<IncorrectMonsterNotifier, List<IncorrectMonster>>((ref) {
  final repository = ref.watch(incorrectMonsterRepositoryProvider);
  return IncorrectMonsterNotifier(repository);
});

/// 特定のモンスターを ID で取得
final specificMonsterProvider = FutureProvider.family<IncorrectMonster?, String>((ref, monsterId) async {
  final monsters = ref.watch(incorrectMonstersProvider);
  try {
    return monsters.firstWhere((m) => m.id == monsterId);
  } catch (e) {
    return null;
  }
});

/// モンスター総数プロバイダ
final monsterCountProvider = Provider<int>((ref) {
  return ref.watch(incorrectMonstersProvider).length;
});

/// 進化段階別のモンスター数
final monstersByEvolutionProvider = Provider<Map<EvolutionState, int>>((ref) {
  final monsters = ref.watch(incorrectMonstersProvider);
  final result = <EvolutionState, int>{};

  for (final state in EvolutionState.values) {
    result[state] = monsters.where((m) => m.evolutionState == state).length;
  }

  return result;
});

/// StateNotifier 実装
class IncorrectMonsterNotifier extends StateNotifier<List<IncorrectMonster>> {
  final IncorrectMonsterRepository _repository;
  bool _isInitialized = false;

  IncorrectMonsterNotifier(this._repository) : super([]) {
    _init();
  }

  /// 初期化: SharedPreferences からモンスターを読み込む
  Future<void> _init() async {
    if (_isInitialized) return;

    try {
      final monsters = await _repository.getAll();
      state = monsters;
      _isInitialized = true;
    } catch (e) {
      print('Error initializing monsters: $e');
      state = [];
      _isInitialized = true;
    }
  }

  /// 間違いを記録（モンスターを作成）
  Future<void> recordIncorrect({
    required String questionId,
    required String stageId,
    required int questionNumber,
    required String questionTitle,
  }) async {
    try {
      // 既存のモンスターがないか確認
      final existing = await _repository.getByQuestionId(questionId);
      if (existing != null) {
        // すでに間違い記録されている
        return;
      }

      // 新規モンスターを作成
      final monster = IncorrectMonster(
        id: const Uuid().v4(),
        questionId: questionId,
        stageId: stageId,
        questionNumber: questionNumber,
        monsterName: _generateMonsterName(questionTitle),
        firstIncorrectDate: DateTime.now(),
        evolutionState: EvolutionState.baby,
      );

      // 保存
      await _repository.save(monster);
      state = [...state, monster];
    } catch (e) {
      print('Error recording incorrect: $e');
      rethrow;
    }
  }

  /// モンスターを進化させる
  Future<void> evolveMonster(String monsterId) async {
    try {
      final monster = state.firstWhere((m) => m.id == monsterId);

      if (!monster.canEvolve()) {
        return; // これ以上進化できない
      }

      final updated = monster.copyWith(
        correctionsCount: monster.correctionsCount + 1,
        evolutionState: monster.getNextEvolutionState() ?? monster.evolutionState,
        correctionDates: [...monster.correctionDates, DateTime.now()],
      );

      await _repository.update(updated);
      state = state.map((m) => m.id == monsterId ? updated : m).toList();
    } catch (e) {
      print('Error evolving monster: $e');
      rethrow;
    }
  }

  /// モンスターを削除
  Future<void> deleteMonster(String monsterId) async {
    try {
      await _repository.delete(monsterId);
      state = state.where((m) => m.id != monsterId).toList();
    } catch (e) {
      print('Error deleting monster: $e');
      rethrow;
    }
  }

  /// すべてのモンスターを削除（デバッグ用）
  Future<void> deleteAll() async {
    try {
      await _repository.deleteAll();
      state = [];
    } catch (e) {
      print('Error clearing all monsters: $e');
      rethrow;
    }
  }

  /// モンスター名を自動生成
  /// 問題タイトルから親しみやすい名前を作成
  String _generateMonsterName(String questionTitle) {
    // 例: "昆虫のからだのつくり" → "コムシちゃん"
    // 例: "水の状態変化" → "ミズちゃん"

    // 最初の1-2文字を取得
    final words = questionTitle.split('・');
    final mainWord = words.first;

    // 最初の2文字 + ちゃん
    final baseName = mainWord.length >= 2
        ? mainWord.substring(0, 2)
        : mainWord;

    return '${baseName}ちゃん';
  }

  /// クイズから呼ばれる前処理: questionId の存在確認
  Future<bool> hasIncorrectMonster(String questionId) async {
    final existing = await _repository.getByQuestionId(questionId);
    return existing != null;
  }

  /// 特定ステージのモンスターを取得
  List<IncorrectMonster> getMonstersForStage(String stageId) {
    return state.where((m) => m.stageId == stageId).toList();
  }
}
