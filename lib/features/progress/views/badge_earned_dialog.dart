import 'package:flutter/material.dart';
import '../models/badge_model.dart';

/// バッジ獲得時に表示するアニメーションダイアログ
class BadgeEarnedDialog extends StatefulWidget {
  final List<BadgeModel> badges;
  const BadgeEarnedDialog({super.key, required this.badges});

  @override
  State<BadgeEarnedDialog> createState() => _BadgeEarnedDialogState();
}

class _BadgeEarnedDialogState extends State<BadgeEarnedDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  int _currentIndex = 0;

  BadgeModel get _current => widget.badges[_currentIndex];
  bool get _hasNext => _currentIndex < widget.badges.length - 1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_hasNext) {
      setState(() => _currentIndex++);
      _ctrl
        ..reset()
        ..forward();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _current.color.withOpacity(0.35),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── バッジアイコン ──
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: _current.color.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _current.color.withOpacity(0.45), width: 3),
                  ),
                  child: Center(
                    child: Text(
                      _current.emoji,
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── ラベル ──
                Text(
                  '🎊 バッジ獲得！',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // ── バッジ名 ──
                Text(
                  _current.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _current.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // ── 説明 ──
                Text(
                  _current.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                  ),
                  textAlign: TextAlign.center,
                ),

                // ── 複数バッジ時のページ表示 ──
                if (widget.badges.length > 1) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.badges.length,
                      (i) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _currentIndex
                              ? _current.color
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // ── ボタン ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _current.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      _hasNext ? '次のバッジを見る →' : 'やったね！',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
