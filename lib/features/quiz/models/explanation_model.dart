import 'package:cloud_firestore/cloud_firestore.dart';

/// 動画リソース
class VideoResource {
  final String youtubeId;   // YouTube 動画ID（例: "dQw4w9WgXcQ"）
  final String title;        // 動画タイトル
  final String source;       // 提供元（例: "NHK for School"）
  final int durationSeconds; // 秒単位の動画長さ

  const VideoResource({
    required this.youtubeId,
    required this.title,
    required this.source,
    required this.durationSeconds,
  });

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m分${s.toString().padLeft(2, '0')}秒';
  }

  factory VideoResource.fromMap(Map<String, dynamic> m) => VideoResource(
        youtubeId: m['youtubeId'] ?? '',
        title: m['title'] ?? '',
        source: m['source'] ?? '',
        durationSeconds: m['durationSeconds'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'youtubeId': youtubeId,
        'title': title,
        'source': source,
        'durationSeconds': durationSeconds,
      };
}

/// キーポイント（アイコン付き）
class KeyPoint {
  final String text;
  final String emoji; // 絵文字アイコン（例: "🦋"）

  const KeyPoint({required this.text, required this.emoji});

  factory KeyPoint.fromMap(Map<String, dynamic> m) => KeyPoint(
        text: m['text'] ?? '',
        emoji: m['emoji'] ?? '✅',
      );

  Map<String, dynamic> toMap() => {'text': text, 'emoji': emoji};
}

/// 比較表の行
class ComparisonRow {
  final String label;
  final String valueA;
  final String valueB;

  const ComparisonRow({
    required this.label,
    required this.valueA,
    required this.valueB,
  });

  factory ComparisonRow.fromMap(Map<String, dynamic> m) => ComparisonRow(
        label: m['label'] ?? '',
        valueA: m['valueA'] ?? '',
        valueB: m['valueB'] ?? '',
      );

  Map<String, dynamic> toMap() =>
      {'label': label, 'valueA': valueA, 'valueB': valueB};
}

/// 比較表（例：直列 vs 並列）
class ComparisonTable {
  final String headerA;
  final String headerB;
  final List<ComparisonRow> rows;

  const ComparisonTable({
    required this.headerA,
    required this.headerB,
    required this.rows,
  });

  factory ComparisonTable.fromMap(Map<String, dynamic> m) => ComparisonTable(
        headerA: m['headerA'] ?? '',
        headerB: m['headerB'] ?? '',
        rows: (m['rows'] as List? ?? [])
            .map((r) => ComparisonRow.fromMap(r as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'headerA': headerA,
        'headerB': headerB,
        'rows': rows.map((r) => r.toMap()).toList(),
      };
}

/// 解説モデル（拡張版）
class ExplanationModel {
  final String id;
  final String questionId;

  // ── 解説テキスト ──────────────────────
  final String basicExplanation;       // ワンポイント解説（1〜2文）
  final String detailedExplanation;    // マークダウン形式の詳細説明
  final String? explanationImageUrl;   // 解説図解画像URL

  // ── キーポイント ──────────────────────
  final List<KeyPoint> keyPoints;      // 絵文字付きキーポイント

  // ── 動画 ─────────────────────────────
  final List<VideoResource> videos;    // 複数 YouTube 動画

  // ── 応用・豆知識 ──────────────────────
  final String? realWorldExample;      // 実生活での応用例
  final String? funFact;               // 豆知識
  final String? commonMistake;         // よくある間違い

  // ── 比較表（オプション）────────────────
  final ComparisonTable? comparisonTable;

  // ── 学習ガイド ────────────────────────
  final String learningTip;            // 学習のコツ
  final String nextLearning;           // 次のステップ

  // ── ナビゲーション ────────────────────
  final List<String> relatedStageIds;  // 関連単元ID

  ExplanationModel({
    required this.id,
    required this.questionId,
    required this.basicExplanation,
    required this.detailedExplanation,
    this.explanationImageUrl,
    required this.keyPoints,
    this.videos = const [],
    this.realWorldExample,
    this.funFact,
    this.commonMistake,
    this.comparisonTable,
    required this.learningTip,
    required this.nextLearning,
    required this.relatedStageIds,
  });

  factory ExplanationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return ExplanationModel(
      id: doc.id,
      questionId: d['questionId'] ?? '',
      basicExplanation: d['basicExplanation'] ?? '',
      detailedExplanation: d['detailedExplanation'] ?? '',
      explanationImageUrl: d['explanationImageUrl'],
      keyPoints: (d['keyPoints'] as List? ?? [])
          .map((e) => KeyPoint.fromMap(e as Map<String, dynamic>))
          .toList(),
      videos: (d['videos'] as List? ?? [])
          .map((e) => VideoResource.fromMap(e as Map<String, dynamic>))
          .toList(),
      realWorldExample: d['realWorldExample'],
      funFact: d['funFact'],
      commonMistake: d['commonMistake'],
      comparisonTable: d['comparisonTable'] != null
          ? ComparisonTable.fromMap(
              d['comparisonTable'] as Map<String, dynamic>)
          : null,
      learningTip: d['learningTip'] ?? '',
      nextLearning: d['nextLearning'] ?? '',
      relatedStageIds:
          List<String>.from(d['relatedStageIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'questionId': questionId,
        'basicExplanation': basicExplanation,
        'detailedExplanation': detailedExplanation,
        'explanationImageUrl': explanationImageUrl,
        'keyPoints': keyPoints.map((k) => k.toMap()).toList(),
        'videos': videos.map((v) => v.toMap()).toList(),
        'realWorldExample': realWorldExample,
        'funFact': funFact,
        'commonMistake': commonMistake,
        'comparisonTable': comparisonTable?.toMap(),
        'learningTip': learningTip,
        'nextLearning': nextLearning,
        'relatedStageIds': relatedStageIds,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
