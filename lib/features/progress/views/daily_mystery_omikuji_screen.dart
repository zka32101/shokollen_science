import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/furigana_text.dart';
import '../data/daily_mysteries_data.dart';
import '../models/daily_mystery.dart';
import '../providers/daily_mystery_provider.dart';

class DailyMysteryOmikujiScreen extends ConsumerStatefulWidget {
  const DailyMysteryOmikujiScreen({super.key});

  @override
  ConsumerState<DailyMysteryOmikujiScreen> createState() =>
      _DailyMysteryOmikujiScreenState();
}

class _DailyMysteryOmikujiScreenState
    extends ConsumerState<DailyMysteryOmikujiScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotation;

  bool _revealed = false;
  bool _showAnswer = false;
  late final DailyMystery _todayMystery;

  @override
  void initState() {
    super.initState();
    _todayMystery = pickTodayMystery();
    _setupAnimation();

    // 今日すでに引いている/答えを見ている場合は、その状態から再開する
    final existingRecord = ref.read(dailyMysteryNotifierProvider);
    if (existingRecord != null) {
      _revealed = true;
      _rotationController.value = 1.0;
      if (existingRecord.answeredAt != null) {
        _showAnswer = true;
      }
    }
  }

  void _setupAnimation() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOut),
    );
  }

  void _startReveal() {
    _rotationController.forward().then((_) {
      ref
          .read(dailyMysteryNotifierProvider.notifier)
          .revealToday(_todayMystery.id);
      setState(() {
        _revealed = true;
      });
    });
  }

  void _revealAnswer() {
    ref
        .read(dailyMysteryNotifierProvider.notifier)
        .answerToday(_todayMystery.id, true);
    setState(() {
      _showAnswer = true;
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📿 今日のふしぎ'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const Text(
                  '🎀 今日のふしぎ 🎀',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sciencePrimary,
                  ),
                ),
                const SizedBox(height: 48),
                // Omikuji animation
                if (!_revealed)
                  _buildOmikujiRotation()
                else
                  _buildRevealedMystery(),
                const SizedBox(height: 48),
                // Buttons
                if (!_revealed)
                  ElevatedButton.icon(
                    onPressed: _startReveal,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('おみくじを引く'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sciencePrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  )
                else ...[
                  if (!_showAnswer)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _revealAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sciencePrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('すぐに答えを見る'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.sciencePrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('後で見る'),
                        ),
                      ],
                    )
                  else
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sciencePrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('ホームに戻る'),
                    ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOmikujiRotation() {
    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotation.value * 6.28,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.sciencePrimary,
                  AppColors.sciencePrimary.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sciencePrimary.withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🤔',
                style: TextStyle(fontSize: 60),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevealedMystery() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.sciencePrimary,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '📖',
                    style: TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FuriganaText(
                      _todayMystery.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('🏷️'),
                    const SizedBox(width: 8),
                    Text(
                      _todayMystery.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '小学${_todayMystery.grade}年',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showAnswer) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '💡',
                      style: TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '答え',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FuriganaText(
                  _todayMystery.answer,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
