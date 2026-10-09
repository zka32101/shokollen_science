import 'package:flutter/material.dart';

/// 称号プレート画像の上に称号名を重ねて表示する。
class TitlePlate extends StatelessWidget {
  const TitlePlate({super.key, required this.name, this.width = 110});

  final String name;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 366 / 768;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: Image.asset('assets/title_plate/plate_rika.webp', fit: BoxFit.fill)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.16, vertical: height * 0.18),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                name,
                maxLines: 1,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
