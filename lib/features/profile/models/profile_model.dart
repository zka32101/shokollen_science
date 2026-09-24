class ProfileModel {
  final String id;
  final String nickname;
  final String avatarImagePath;
  final int gradeLevel; // 0=小学未満, 1〜6=小学1〜6年, 7=中学以上
  final String createdAt; // YYYY-MM-DD

  /// 学年表示用ラベル
  String get gradeLabel {
    switch (gradeLevel) {
      case 0:
        return '小学生未満';
      case 7:
        return '中学生以上';
      default:
        return '$gradeLevel年生';
    }
  }

  const ProfileModel({
    required this.id,
    required this.nickname,
    required this.avatarImagePath,
    required this.gradeLevel,
    required this.createdAt,
  });

  /// アバター画像一覧（assets/images/avatars/avatar_01.jpg 〜 avatar_16.jpg）
  /// 元画像の並び: 1.茶色クマ 2.黒猫 3.パンダ 4.キツネ 5.ウサギ 6.トラ 7.ライオン
  /// 8.カエル 9.アヒル 10.ブタ 11.コアラ 12.キリン 13.カンガルー 14.イヌ
  /// 15.アライグマ 16.ナマケモノ
  static const avatarChoices = [
    'assets/images/avatars/avatar_01.jpg',
    'assets/images/avatars/avatar_02.jpg',
    'assets/images/avatars/avatar_03.jpg',
    'assets/images/avatars/avatar_04.jpg',
    'assets/images/avatars/avatar_05.jpg',
    'assets/images/avatars/avatar_06.jpg',
    'assets/images/avatars/avatar_07.jpg',
    'assets/images/avatars/avatar_08.jpg',
    'assets/images/avatars/avatar_09.jpg',
    'assets/images/avatars/avatar_10.jpg',
    'assets/images/avatars/avatar_11.jpg',
    'assets/images/avatars/avatar_12.jpg',
    'assets/images/avatars/avatar_13.jpg',
    'assets/images/avatars/avatar_14.jpg',
    'assets/images/avatars/avatar_15.jpg',
    'assets/images/avatars/avatar_16.jpg',
  ];

  /// 最初の4体のみ無料開放。残りはショップでコイン購入が必要
  static const int freeAvatarCount = 4;

  /// avatarChoices のインデックスに対応するショップアイテムID
  /// （先頭 freeAvatarCount 個は購入不要なので該当なし）
  static const avatarShopItemIds = [
    'avatar_usagi', // avatar_05 ウサギ
    'avatar_tora', // avatar_06 トラ
    'avatar_raion', // avatar_07 ライオン
    'avatar_kaeru', // avatar_08 カエル
    'avatar_ahiru', // avatar_09 アヒル
    'avatar_buta', // avatar_10 ブタ
    'avatar_koala', // avatar_11 コアラ
    'avatar_kirin', // avatar_12 キリン
    'avatar_kangaroo', // avatar_13 カンガルー
    'avatar_inu', // avatar_14 イヌ
    'avatar_araiguma', // avatar_15 アライグマ
    'avatar_namakemono', // avatar_16 ナマケモノ
  ];

  static bool isAvatarFree(int index) => index < freeAvatarCount;

  /// index に対応する購入用アイテムID（無料枠なら null）
  static String? avatarShopItemIdFor(int index) {
    if (isAvatarFree(index)) return null;
    final shopIndex = index - freeAvatarCount;
    if (shopIndex < 0 || shopIndex >= avatarShopItemIds.length) return null;
    return avatarShopItemIds[shopIndex];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'avatarImagePath': avatarImagePath,
        'gradeLevel': gradeLevel,
        'createdAt': createdAt,
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        avatarImagePath: json['avatarImagePath'] as String? ?? avatarChoices[0],
        gradeLevel: (json['gradeLevel'] as num?)?.toInt() ?? 3,
        createdAt: json['createdAt'] as String? ?? '',
      );
}
