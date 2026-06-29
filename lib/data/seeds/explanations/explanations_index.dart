/// 小学コレ！理科 - 問題解説統合インデックス
/// このファイルで全ステージの解説をインポート＆統合

// Stage 3 (3年生)
import 'explanations_stage_3_001.dart';
import 'explanations_stage_3_002.dart';
import 'explanations_stage_3_003.dart';
import 'explanations_stage_3_004.dart';
import 'explanations_stage_3_005.dart';
import 'explanations_stage_3_006.dart';
import 'explanations_stage_3_007.dart';
import 'explanations_stage_3_008.dart';
import 'explanations_stage_3_009.dart';
import 'explanations_stage_3_010.dart';
import 'explanations_stage_3_011.dart';
import 'explanations_stage_3_012.dart';

// Stage 4 (4年生)
import 'explanations_stage_4_001.dart';
import 'explanations_stage_4_002.dart';
import 'explanations_stage_4_003.dart';
import 'explanations_stage_4_004.dart';
import 'explanations_stage_4_005.dart';
import 'explanations_stage_4_006.dart';
import 'explanations_stage_4_007.dart';
import 'explanations_stage_4_008.dart';
import 'explanations_stage_4_009.dart';
import 'explanations_stage_4_010.dart';
import 'explanations_stage_4_011.dart';

// Stage 5 (5年生)
import 'explanations_stage_5_001.dart';
import 'explanations_stage_5_002.dart';
import 'explanations_stage_5_003.dart';
import 'explanations_stage_5_004.dart';
import 'explanations_stage_5_005.dart';
import 'explanations_stage_5_006.dart';
import 'explanations_stage_5_007.dart';
import 'explanations_stage_5_008.dart';
import 'explanations_stage_5_009.dart';
import 'explanations_stage_5_010.dart';
import 'explanations_stage_5_011.dart';
import 'explanations_stage_5_012.dart';

// Stage 6 (6年生)
import 'explanations_stage_6_001.dart';
import 'explanations_stage_6_002.dart';
import 'explanations_stage_6_003.dart';
import 'explanations_stage_6_004.dart';
import 'explanations_stage_6_005.dart';
import 'explanations_stage_6_006.dart';
import 'explanations_stage_6_007.dart';
import 'explanations_stage_6_008.dart';
import 'explanations_stage_6_009.dart';
import 'explanations_stage_6_010.dart';
import 'explanations_stage_6_011.dart';
import 'explanations_stage_6_012.dart';

/// 全ステージの解説マップ
/// 使用方法:
/// ```dart
/// final explanation = allExplanations['stage_3_001']?[questionNumber];
/// if (explanation != null) {
///   print(explanation['correctReason']);
///   print(explanation['commonMistakes']);
///   print(explanation['advancedLearning']);
/// }
/// ```

final Map<String, Map<int, Map<String, String>>> allExplanations = {
  // Stage 3
  'stage_3_001': explanations_stage_3_001,
  'stage_3_002': explanations_stage_3_002,
  'stage_3_003': explanations_stage_3_003,
  'stage_3_004': explanations_stage_3_004,
  'stage_3_005': explanations_stage_3_005,
  'stage_3_006': explanations_stage_3_006,
  'stage_3_007': explanations_stage_3_007,
  'stage_3_008': explanations_stage_3_008,
  'stage_3_009': explanations_stage_3_009,
  'stage_3_010': explanations_stage_3_010,
  'stage_3_011': explanations_stage_3_011,
  'stage_3_012': explanations_stage_3_012,
  // Stage 4
  'stage_4_001': explanations_stage_4_001,
  'stage_4_002': explanations_stage_4_002,
  'stage_4_003': explanations_stage_4_003,
  'stage_4_004': explanations_stage_4_004,
  'stage_4_005': explanations_stage_4_005,
  'stage_4_006': explanations_stage_4_006,
  'stage_4_007': explanations_stage_4_007,
  'stage_4_008': explanations_stage_4_008,
  'stage_4_009': explanations_stage_4_009,
  'stage_4_010': explanations_stage_4_010,
  'stage_4_011': explanations_stage_4_011,
  // Stage 5
  'stage_5_001': explanations_stage_5_001,
  'stage_5_002': explanations_stage_5_002,
  'stage_5_003': explanations_stage_5_003,
  'stage_5_004': explanations_stage_5_004,
  'stage_5_005': explanations_stage_5_005,
  'stage_5_006': explanations_stage_5_006,
  'stage_5_007': explanations_stage_5_007,
  'stage_5_008': explanations_stage_5_008,
  'stage_5_009': explanations_stage_5_009,
  'stage_5_010': explanations_stage_5_010,
  'stage_5_011': explanations_stage_5_011,
  'stage_5_012': explanations_stage_5_012,
  // Stage 6
  'stage_6_001': explanations_stage_6_001,
  'stage_6_002': explanations_stage_6_002,
  'stage_6_003': explanations_stage_6_003,
  'stage_6_004': explanations_stage_6_004,
  'stage_6_005': explanations_stage_6_005,
  'stage_6_006': explanations_stage_6_006,
  'stage_6_007': explanations_stage_6_007,
  'stage_6_008': explanations_stage_6_008,
  'stage_6_009': explanations_stage_6_009,
  'stage_6_010': explanations_stage_6_010,
  'stage_6_011': explanations_stage_6_011,
  'stage_6_012': explanations_stage_6_012,
};

/// ステージIDから解説を取得するヘルパー関数
/// ```dart
/// final explanation = getExplanation('stage_3_001', 1);
/// ```
Map<String, String>? getExplanation(String stageId, int questionNumber) {
  return allExplanations[stageId]?[questionNumber];
}

/// 正解理由だけを取得するヘルパー関数
String? getCorrectReason(String stageId, int questionNumber) {
  return allExplanations[stageId]?[questionNumber]?['correctReason'];
}

/// よくある間違いだけを取得するヘルパー関数
String? getCommonMistakes(String stageId, int questionNumber) {
  return allExplanations[stageId]?[questionNumber]?['commonMistakes'];
}

/// 発展学習だけを取得するヘルパー関数
String? getAdvancedLearning(String stageId, int questionNumber) {
  return allExplanations[stageId]?[questionNumber]?['advancedLearning'];
}
