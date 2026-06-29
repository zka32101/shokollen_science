class ProfileModel {
  final String id;
  final String nickname;
  final String avatarEmoji;
  final int gradeLevel; // 3, 4, 5, 6
  final String createdAt; // YYYY-MM-DD

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
