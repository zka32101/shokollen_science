import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/incorrect_monster.dart';
import '../../providers/incorrect_monster_provider.dart';
import 'monster_image.dart';

/// モンスター獲得ダイアログ
/// 間違った問題をモンスター化して表示
class MonsterGetDialog extends StatelessWidget {
  final IncorrectMonster monster;
  final VoidCallback? onDismiss;

  const MonsterGetDialog({
    required this.monster,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.pink[50]!, Colors.pink[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タイトル
            Text(
              'このモンスターをあなたのともだちにしよう！',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),

            // モンスター表示
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MonsterImage(monster: monster, size: 64),
                    SizedBox(height: 4),
                    Text(
                      monster.monsterName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // メッセージ
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Text(
                '「正解できるまで、\nずっとともだちだよ！」',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ),
            SizedBox(height: 24),

            // ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDismiss?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'まちがい図鑑をみる',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// モンスター進化ダイアログ
/// 再挑戦して正解した時に表示
class MonsterEvolutionDialog extends ConsumerWidget {
  final IncorrectMonster monster;
  final VoidCallback? onConfirm;

  const MonsterEvolutionDialog({
    required this.monster,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextState = monster.getNextEvolutionState();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.amber[50]!, Colors.amber[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タイトル
            Text(
              '${monster.monsterName}が進化した！',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            SizedBox(height: 24),

            // 進化アニメーション表示
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Before
                  Column(
                    children: [
                      MonsterImage(
                        monster: monster,
                        size: 40,
                        evolutionStateOverride: EvolutionState
                            .values[(monster.correctionsCount - 1).clamp(0, 3)],
                      ),
                      SizedBox(height: 4),
                      Text(
                        EvolutionState
                            .values[
                                (monster.correctionsCount - 1).clamp(0, 3)]
                            .label,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  // Arrow
                  Icon(Icons.arrow_right, size: 32, color: Colors.blue),

                  // After
                  Column(
                    children: [
                      MonsterImage(
                        monster: monster,
                        size: 40,
                        evolutionStateOverride:
                            nextState ?? monster.evolutionState,
                      ),
                      SizedBox(height: 4),
                      Text(
                        nextState?.label ?? monster.evolutionState.label,
                        style: TextStyle(fontSize: 11, color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // 進捗バー
            if (monster.canEvolve())
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'つぎの進化まで',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      Text(
                        '${monster.correctionsCount}/3',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: monster.correctionsCount / 3.0,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(Colors.orange[600]),
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),

            // メッセージ
            if (!monster.canEvolve())
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  '${monster.monsterName}は博士になりました！\nこれ以上進化しません。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),

            // ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // モンスターを進化させる
                  await ref
                      .read(incorrectMonstersProvider.notifier)
                      .evolveMonster(monster.id);

                  if (context.mounted) {
                    Navigator.pop(context);
                    onConfirm?.call();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// モンスター確認ダイアログ（ショート版）
/// 図鑑スクリーンから進化確認時に使用
class MonsterStatusDialog extends ConsumerWidget {
  final IncorrectMonster monster;

  const MonsterStatusDialog({required this.monster});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル
              Text(
                monster.monsterName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // 進化状況
              Center(
                child: Column(
                  children: [
                    MonsterImage(monster: monster, size: 64),
                    SizedBox(height: 8),
                    Text(
                      monster.evolutionState.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // 進捗バー
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('進化度', style: TextStyle(fontSize: 12)),
                  Text('${monster.correctionsCount}/3',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: monster.correctionsCount / 3.0,
                  minHeight: 6,
                ),
              ),
              SizedBox(height: 16),

              // 情報
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow('初回間違い', _formatDate(monster.firstIncorrectDate)),
                    SizedBox(height: 8),
                    _InfoRow('正解回数', '${monster.correctionsCount}回'),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('とじる'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
