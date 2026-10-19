import 'dart:math';

import 'package:flutter/material.dart';

/// 保護者ゲートの問題。画面から切り離して、単体でテストできるようにしてある。
class ParentalGateChallenge {
  ParentalGateChallenge(Random rnd)
      : a = 13 + rnd.nextInt(7), // 13〜19
        b = 6 + rnd.nextInt(4); // 6〜9

  final int a;
  final int b;

  /// 2桁×1桁のかけ算。九九の範囲では解けない問題にしている。
  int get answer => a * b;

  String get question => '$a × $b = ?';

  bool check(String input) => int.tryParse(input.trim()) == answer;
}

/// 連続で間違えたら、しばらくゲートを開かない。アプリを再起動するまで有効(端末内のみ)。
class ParentalGateLockout {
  ParentalGateLockout._();

  static const maxAttempts = 3;
  static const lockDuration = Duration(seconds: 60);

  /// テストで差し替える。
  static DateTime Function() now = DateTime.now;

  static DateTime? _lockedUntil;

  static bool get isLocked {
    final until = _lockedUntil;
    return until != null && now().isBefore(until);
  }

  static int get remainingSeconds {
    final until = _lockedUntil;
    if (until == null) return 0;
    final left = until.difference(now()).inSeconds + 1;
    return left < 0 ? 0 : left;
  }

  static void lock() => _lockedUntil = now().add(lockDuration);

  static void reset() => _lockedUntil = null;
}

/// 購入・外部リンクなどの前に、保護者(大人)であることを確認する計算ゲート。
/// 通れたら true を返す。3回続けて間違えると、60秒間は開かない。
Future<bool> requireParentalGate(BuildContext context) async {
  if (ParentalGateLockout.isLocked) {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔒 しばらくお待ちください'),
        content: Text(
            '答えが続けて違っていました。${ParentalGateLockout.remainingSeconds}秒ほど待ってから、もう一度お試しください。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('とじる')),
        ],
      ),
    );
    return false;
  }
  final passed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ParentalGateDialog(),
  );
  return passed ?? false;
}

class _ParentalGateDialog extends StatefulWidget {
  const _ParentalGateDialog();

  @override
  State<_ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<_ParentalGateDialog> {
  final _rnd = Random();
  late ParentalGateChallenge _challenge;
  final _controller = TextEditingController();
  int _wrong = 0;

  @override
  void initState() {
    super.initState();
    _challenge = ParentalGateChallenge(_rnd);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_challenge.check(_controller.text)) {
      ParentalGateLockout.reset();
      Navigator.of(context).pop(true);
      return;
    }
    _wrong++;
    if (_wrong >= ParentalGateLockout.maxAttempts) {
      ParentalGateLockout.lock();
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _challenge = ParentalGateChallenge(_rnd);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // キーボード表示中は説明文を省いて、「つぎへ」が隠れない高さに収める。
    final compact = MediaQuery.of(context).viewInsets.bottom > 0;
    return AlertDialog(
      // 画面が小さい端末でも、中身がはみ出さずにスクロールできるようにする。
      scrollable: true,
      insetPadding: EdgeInsets.symmetric(horizontal: 28, vertical: compact ? 12 : 24),
      title: const Text('🔒 保護者の方へ確認'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            const Text('これは大人の方が行う操作です。\n下の計算の答えを入力してください。'),
            const SizedBox(height: 12),
          ],
          Text(_challenge.question,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          if (_wrong > 0) ...[
            const SizedBox(height: 8),
            Text('答えが違います(あと${ParentalGateLockout.maxAttempts - _wrong}回)',
                style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.center,
            autofocus: true,
            // マウス・スタイラス操作でも、ボタンを押す前にキーボードが閉じて
            // レイアウトが動かないようにする。
            onTapOutside: (_) {},
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('やめる'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('つぎへ'),
        ),
      ],
    );
  }
}
