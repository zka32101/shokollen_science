import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 理科コレ内の仮ランキング行（shared_core の GlobalRanking は main に無いためアプリ側で定義）。
class GlobalRanking {
  const GlobalRanking({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.score,
    required this.badges,
  });
  final int rank;
  final String userId;
  final String userName;
  final int score;
  final int badges;
}

final globalRankingProvider = FutureProvider<List<GlobalRanking>>((ref) async {
  return [
    GlobalRanking(rank: 1, userId: 'user_001', userName: 'Takeshi Yamamoto', score: 9200, badges: 41),
    GlobalRanking(rank: 2, userId: 'user_002', userName: 'Yuki Suzuki', score: 8950, badges: 39),
    GlobalRanking(rank: 3, userId: 'user_003', userName: 'Hana Ito', score: 8650, badges: 37),
  ];
});

final userRankProvider = FutureProvider<int>((ref) async {
  return 18;
});
