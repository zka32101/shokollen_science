import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';

class CertificateScreen extends StatelessWidget {
  final int grade;
  final int correct;
  final int total;

  const CertificateScreen({
    super.key,
    required this.grade,
    required this.correct,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final day = now.day;

    final percent = total > 0 ? (correct / total * 100).round() : 0;

    final String rankLabel;
    final Color rankColor;

    if (percent >= 90) {
      rankLabel = '🌟 理科マスター！';
      rankColor = Colors.orange;
    } else if (percent >= 70) {
      rankLabel = '⭐ よくできました！';
      rankColor = Colors.blue;
    } else if (percent >= 50) {
      rankLabel = '👍 もう少し！';
      rankColor = Colors.green;
    } else {
      rankLabel = '💪 再チャレンジ！';
      rankColor = Colors.grey;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.scienceGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🏆',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '理科 博士 認定証',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Color(0xFFFFA500),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFA500),
                                Color(0xFFFFD700),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '${grade}年生 理科まとめテスト 合格',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '$correct / $total',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.sciencePrimary,
                          ),
                        ),
                        const Text(
                          '問正解',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.textGray,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '正答率: $percent%',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textGray,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: rankColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: rankColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            rankLabel,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: rankColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: AppColors.borderGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$year年$month月$day日 取得',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.sciencePrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'もう一度チャレンジ',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => context.go('/home'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'ホームに戻る',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
