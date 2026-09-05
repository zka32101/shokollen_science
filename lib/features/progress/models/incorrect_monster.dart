import 'package:freezed_annotation/freezed_annotation.dart';

part 'incorrect_monster.freezed.dart';
part 'incorrect_monster.g.dart';

enum EvolutionState {
  baby,      // 😢 泣いている
  juvenile,  // 😕 困っている
  adult,     // 😐 普通
  sage,      // 😊 嬉しい
}

extension EvolutionStateExt on EvolutionState {
  String get emoji => {
    EvolutionState.baby: '😢',
    EvolutionState.juvenile: '😕',
    EvolutionState.adult: '😐',
    EvolutionState.sage: '😊',
  }[this]!;

  String get label => {
    EvolutionState.baby: 'たまご',
    EvolutionState.juvenile: '幼生',
    EvolutionState.adult: '成体',
    EvolutionState.sage: '博士',
  }[this]!;

  int get progressPercent => {
    EvolutionState.baby: 0,
    EvolutionState.juvenile: 33,
    EvolutionState.adult: 66,
    EvolutionState.sage: 100,
  }[this]!;
}

@freezed
class IncorrectMonster with _$IncorrectMonster {
  const factory IncorrectMonster({
    required String id,                    // UUID
    required String questionId,            // "stage_3_001_q1" など
    required String stageId,               // "stage_3_001"
    required int questionNumber,           // 1-10
    required String monsterName,           // 自動生成: 問題タイトルから
    required DateTime firstIncorrectDate,  // 初回間違い日時
    @Default(0) int correctionsCount,     // 正解した回数（進化段階）
    @Default(EvolutionState.baby)
    EvolutionState evolutionState,         // baby/juvenile/adult/sage
    @Default([]) List<DateTime> correctionDates, // 各正解日時（履歴）
  }) = _IncorrectMonster;

  const IncorrectMonster._();

  /// 学年（stageId "stage_3_001" の "3" 部分から判定、パース不可時は3年扱い）
  int get grade {
    final parts = stageId.split('_');
    if (parts.length < 2) return 3;
    return int.tryParse(parts[1]) ?? 3;
  }

  /// モンスター画像のアセットパス（学年 × 進化段階、16種）
  String get imageAssetPath =>
      'assets/images/monsters/grade${grade}_${evolutionState.name}.png';

  /// 進化段階を計算
  EvolutionState getEvolutionState() {
    return switch (correctionsCount) {
      0 => EvolutionState.baby,        // 初期状態（泣き顔）
      1 => EvolutionState.juvenile,    // 1回正解（困り顔）
      2 => EvolutionState.adult,       // 2回正解（普通顔）
      3 => EvolutionState.sage,        // 3回正解（嬉しい顔）
      _ => EvolutionState.sage,
    };
  }

  /// さらに進化できるか判定
  bool canEvolve() => correctionsCount < 3;

  /// 次の進化段階を取得
  EvolutionState? getNextEvolutionState() {
    if (!canEvolve()) return null;
    return switch (correctionsCount) {
      0 => EvolutionState.juvenile,
      1 => EvolutionState.adult,
      2 => EvolutionState.sage,
      _ => null,
    };
  }

  /// 次の進化までの正解数
  int correctionsNeededForNextEvolve() => 3 - correctionsCount;

  factory IncorrectMonster.fromJson(Map<String, dynamic> json) =>
      _$IncorrectMonsterFromJson(json);
}
