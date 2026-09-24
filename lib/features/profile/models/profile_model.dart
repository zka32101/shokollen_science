class ProfileModel {
  final String id;
  final String nickname;
  final String avatarEmoji;
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
    required this.avatarEmoji,
    required this.gradeLevel,
    required this.createdAt,
  });

  static const avatarChoices = [
    '🐻', '🐱', '🐸', '🦊', '🐧', '🦁', '🐨', '🐼',
    '🐰', '🐹', '🦋', '🐬',
  ];

  /// 最初の4体のみ無料開放。残りはショップでコイン購入が必要
  static const int freeAvatarCount = 4;

  /// avatarChoices のインデックスに対応するショップアイテムID
  /// （先頭 freeAvatarCount 個は購入不要なので該当なし）
  static const avatarShopItemIds = [
    'avatar_penguin', // 🐧
    'avatar_lion', // 🦁
    'avatar_koala', // 🐨
    'avatar_panda', // 🐼
    'avatar_rabbit', // 🐰
    'avatar_hamster', // 🐹
    'avatar_butterfly', // 🦋
    'avatar_dolphin', // 🐬
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
        'avatarEmoji': avatarEmoji,
        'gradeLevel': gradeLevel,
        'createdAt': createdAt,
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        avatarEmoji: json['avatarEmoji'] as String? ?? '🐻',
        gradeLevel: (json['gradeLevel'] as num?)?.toInt() ?? 3,
        createdAt: json['createdAt'] as String? ?? '',
      );
}
