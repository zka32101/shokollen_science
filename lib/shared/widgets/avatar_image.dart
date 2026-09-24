import 'package:flutter/material.dart';

/// プロフィールアバター画像を丸く表示する共通ウィジェット
class AvatarImage extends StatelessWidget {
  final String imagePath;
  final double size;
  final double borderWidth;
  final Color? borderColor;

  const AvatarImage({
    super.key,
    required this.imagePath,
    this.size = 52,
    this.borderWidth = 0,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: borderWidth > 0
              ? Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: borderWidth,
                )
              : null,
        ),
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
