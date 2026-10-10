import 'package:flutter/material.dart';

/// 連続学習カレンダー。学習した日にスタンプ、7/14/30日目にコインを重ねる。
class StreakCalendar extends StatelessWidget {
  final Set<DateTime> studiedDays;
  final DateTime month;

  const StreakCalendar({
    super.key,
    required this.studiedDays,
    required this.month,
  });

  /// 学習日の連続の何日目か（途切れたら1に戻る）。
  static Map<DateTime, int> streakIndex(Set<DateTime> days) {
    final norm = days.map((d) => DateTime(d.year, d.month, d.day)).toList()
      ..sort();
    final res = <DateTime, int>{};
    var run = 0;
    DateTime? prev;
    for (final d in norm) {
      if (prev != null && DateTime(prev.year, prev.month, prev.day + 1) == d) {
        run++;
      } else {
        run = 1;
      }
      res[d] = run;
      prev = d;
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final count = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday % 7; // 日曜始まり
    final idx = streakIndex(studiedDays);
    const heads = ['日', '月', '火', '水', '木', '金', '土'];
    final cells = <Widget>[];
    for (var i = 0; i < lead; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= count; d++) {
      final date = DateTime(month.year, month.month, d);
      final n = idx[date];
      final milestone = n == 7 || n == 14 || n == 30;
      cells.add(
        Stack(
          alignment: Alignment.center,
          children: [
            if (n != null)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Image.asset(
                    milestone
                        ? 'assets/reward/stamp_coin.webp'
                        : 'assets/reward/stamp_ring_rainbow.webp',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            Text(
              '$d',
              style: TextStyle(
                fontSize: 12,
                fontWeight: n != null ? FontWeight.bold : FontWeight.normal,
                color: Colors.brown.shade800,
              ),
            ),
          ],
        ),
      );
    }
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/reward/calendar_frame.webp',
            fit: BoxFit.fill,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${month.year}年${month.month}月',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (final h in heads)
                    Expanded(
                      child: Center(
                        child: Text(h, style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: cells,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> showStreakCalendar(BuildContext context, Set<DateTime> days) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      var month = DateTime.now();
      return StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(
                          () => month = DateTime(month.year, month.month - 1),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'れんぞく学習カレンダー',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(
                          () => month = DateTime(month.year, month.month + 1),
                        ),
                      ),
                    ],
                  ),
                  StreakCalendar(studiedDays: days, month: month),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('とじる'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
