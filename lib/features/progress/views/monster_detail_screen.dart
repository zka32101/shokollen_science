import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/incorrect_monster_provider.dart';
import 'widgets/monster_dialogs.dart';
import 'widgets/monster_image.dart';

/// モンスター詳細スクリーン
class MonsterDetailScreen extends ConsumerWidget {
  final String monsterId;

  const MonsterDetailScreen({required this.monsterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monsterAsync = ref.watch(specificMonsterProvider(monsterId));

    return Scaffold(
      appBar: AppBar(
        title: Text('モンスター詳細'),
        elevation: 0,
      ),
      body: monsterAsync.when(
        data: (monster) {
          if (monster == null) {
            return Center(
              child: Text('モンスターが見つかりません'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー: 進化状況
                _MonsterHeader(monster: monster),

                SizedBox(height: 24),

                // 進化ゲージ
                _EvolutionProgress(monster: monster),

                SizedBox(height: 24),

                // 問題情報
                _MonsterInfo(monster: monster),

                SizedBox(height: 24),

                // 正解履歴
                _CorrectionHistory(monster: monster),

                SizedBox(height: 24),

                // 再挑戦ボタン
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.refresh),
                      label: Text('このもんだいに再ちょうせん'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // 削除ボタン
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteDialog(context, ref, monsterId),
                      icon: Icon(Icons.delete_outline),
                      label: Text('このモンスターを削除'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('エラーが発生しました: $err'),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String monsterId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('モンスターを削除しますか？'),
        content: Text('削除すると復活しません。よろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(incorrectMonstersProvider.notifier)
                  .deleteMonster(monsterId);
              if (context.mounted) {
                Navigator.pop(context); // ダイアログを閉じる
                Navigator.pop(context); // 詳細画面を閉じる
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('削除'),
          ),
        ],
      ),
    );
  }
}

/// ヘッダー: モンスター表示と進化段階
class _MonsterHeader extends StatelessWidget {
  final dynamic monster;

  const _MonsterHeader({required this.monster});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getHeaderGradient(monster.evolutionState),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // モンスター画像
          MonsterImage(monster: monster, size: 100),
          SizedBox(height: 12),

          // モンスター名
          Text(
            monster.monsterName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),

          // 段階
          Text(
            monster.evolutionState.label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getHeaderGradient(dynamic state) {
    return switch (state) {
      _ when state.toString().contains('baby') =>
        [Colors.blue[200]!, Colors.blue[600]!],
      _ when state.toString().contains('juvenile') =>
        [Colors.purple[200]!, Colors.purple[600]!],
      _ when state.toString().contains('adult') =>
        [Colors.green[200]!, Colors.green[600]!],
      _ => [Colors.amber[200]!, Colors.amber[600]!],
    };
  }
}

/// 進化プログレス
class _EvolutionProgress extends StatelessWidget {
  final dynamic monster;

  const _EvolutionProgress({required this.monster});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '進化度',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${monster.correctionsCount}/3',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: monster.correctionsCount / 3.0,
                  minHeight: 8,
                ),
              ),
              SizedBox(height: 12),
              if (monster.canEvolve())
                Text(
                  'あと${monster.correctionsNeededForNextEvolve()}回正解で進化します！',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                  ),
                )
              else
                Text(
                  '完全に進化しました！これ以上進化しません。',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// モンスター情報
class _MonsterInfo extends StatelessWidget {
  final dynamic monster;

  const _MonsterInfo({required this.monster});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'もんだいじょうほう',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 12),
              _InfoRow('ステージ', monster.stageId),
              SizedBox(height: 8),
              _InfoRow('もんだい番号', '${monster.questionNumber}'),
              SizedBox(height: 8),
              _InfoRow(
                '初回間違い',
                DateFormat('yyyy-MM-dd HH:mm').format(monster.firstIncorrectDate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 正解履歴
class _CorrectionHistory extends StatelessWidget {
  final dynamic monster;

  const _CorrectionHistory({required this.monster});

  @override
  Widget build(BuildContext context) {
    if (monster.correctionDates.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'せいかい履歴',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < monster.correctionDates.length; i++) ...[
                    _CorrectionItem(
                      index: i + 1,
                      date: monster.correctionDates[i],
                    ),
                    if (i < monster.correctionDates.length - 1)
                      SizedBox(height: 8),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 正解アイテム
class _CorrectionItem extends StatelessWidget {
  final int index;
  final DateTime date;

  const _CorrectionItem({
    required this.index,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green[100],
          ),
          child: Center(
            child: Text(
              '✓',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '第$index回 正解',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(date),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 情報行（ラベル + 値）
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
