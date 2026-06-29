import 'dart:convert';

/// ユーザーの学習進捗データ（SharedPreferences で永続化）
class UserProgress {
  final int totalPoints;
  final int coins; // コイン（ショップで使える）
  final int streakDays;
  final String lastPlayedDate; // 'YYYY-MM-DD'
  final Map<String, int> clearedStages; // stageId -> best score (0-100)
  final List<String> earnedBadgeIds;
  final List<String> purchasedItemIds; // ショップで購入済みのアイテムID
  final int hintsRemaining; // コインで購入したヒントの残り数
  final String activeThemeId; // 適用中テーマID
  final Map<String, List<int>> wrongAnswers; // ステージIDごとの間違えた問題番号リスト
  final Map<String, int> dailyActivity; // 'YYYY-MM-DD' -> その日の正解数

  const UserProgress({
    this.totalPoints = 0,
    this.coins = 0,
    this.streakDays = 0,
    this.lastPlayedDate = '',
    this.clearedStages = const {},
    this.earnedBadgeIds = const [],
    this.purchasedItemIds = const [],
    this.hintsRemaining = 0,
    this.activeThemeId = 'default',
    this.wrongAnswers = const {},
    this.dailyActivity = const {},
  });

  int get clearedCount => clearedStages.length;
  bool get isFirstTime => totalPoints == 0 && clearedCount == 0;

  /// 平均スコア（クリア済みステージがなければ 0）
  int get averageScore {
    if (clearedStages.isEmpty) return 0;
    final sum = clearedStages.values.fold(0, (a, b) => a + b);
    return sum ~/ clearedStages.length;
  }

  bool hasPurchased(String itemId) => purchasedItemIds.contains(itemId);

  UserProgress copyWith({
    int? totalPoints,
    int? coins,
    int? streakDays,
    String? lastPlayedDate,
    Map<String, int>? clearedStages,
    List<String>? earnedBadgeIds,
    List<String>? purchasedItemIds,
    int? hintsRemaining,
    String? activeThemeId,
    Map<String, List<int>>? wrongAnswers,
    Map<String, int>? dailyActivity,
  }) {
    return UserProgress(
      totalPoints: totalPoints ?? this.totalPoints,
      coins: coins ?? this.coins,
      streakDays: streakDays ?? this.streakDays,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      clearedStages: clearedStages ?? this.clearedStages,
      earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
      purchasedItemIds: purchasedItemIds ?? this.purchasedItemIds,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      activeThemeId: activeThemeId ?? this.activeThemeId,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      dailyActivity: dailyActivity ?? this.dailyActivity,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalPoints': totalPoints,
        'coins': coins,
        'streakDays': streakDays,
        'lastPlayedDate': lastPlayedDate,
        'clearedStages': clearedStages,
        'earnedBadgeIds': earnedBadgeIds,
        'purchasedItemIds': purchasedItemIds,
        'hintsRemaining': hintsRemaining,
        'activeThemeId': activeThemeId,
        'wrongAnswers': wrongAnswers.map((k, v) => MapEntry(k, v)),
        'dailyActivity': dailyActivity,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      lastPlayedDate: json['lastPlayedDate'] as String? ?? '',
      clearedStages: Map<String, int>.from(
        ((json['clearedStages'] as Map<String, dynamic>?) ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt())),
      ),
      earnedBadgeIds:
          List<String>.from(json['earnedBadgeIds'] as List? ?? []),
      purchasedItemIds:
          List<String>.from(json['purchasedItemIds'] as List? ?? []),
      hintsRemaining: (json['hintsRemaining'] as num?)?.toInt() ?? 0,
      activeThemeId: json['activeThemeId'] as String? ?? 'default',
      wrongAnswers: ((json['wrongAnswers'] as Map<String, dynamic>?) ?? {}).map(
        (k, v) => MapEntry(k, List<int>.from(v as List? ?? [])),
      ),
      dailyActivity: ((json['dailyActivity'] as Map<String, dynamic>?) ?? {})
          .map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }

  factory UserProgress.fromJsonString(String raw) =>
      UserProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());
}
