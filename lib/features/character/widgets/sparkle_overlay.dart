import 'dart:math' as math;
import 'package:flutter/material.dart';

/// MAXキャラ用のきらきらエフェクト（画像が無くてもコードで描画）。
class SparkleOverlay extends StatefulWidget {
  const SparkleOverlay({super.key});

  @override
  State<SparkleOverlay> createState() => _SparkleOverlayState();
}

class _SparkleOverlayState extends State<SparkleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(seconds: 2))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(
          painter: _SparklePainter(_c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double t;
  _SparklePainter(this.t);

  static const _pts = [
    Offset(.15, .2), Offset(.85, .15), Offset(.9, .6), Offset(.1, .7),
    Offset(.5, .05), Offset(.7, .9), Offset(.3, .92),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < _pts.length; i++) {
      final phase = (t + i / _pts.length) % 1.0;
      final a = math.sin(phase * math.pi);
      final r = (size.shortestSide * 0.06) * (0.4 + a);
      paint.color = Colors.amber.withOpacity(0.35 + 0.6 * a);
      final c = Offset(_pts[i].dx * size.width, _pts[i].dy * size.height);
      final path = Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.t != t;
}
