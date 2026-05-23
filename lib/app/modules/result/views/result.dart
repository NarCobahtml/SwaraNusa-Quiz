import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/result/controllers/quiz_result_controller.dart';
import 'package:swaranusaquiz/app/modules/result/models/quiz_result_summary.dart';
import 'package:swaranusaquiz/app/modules/result/widgets/result_action_button.dart';
import 'package:swaranusaquiz/app/modules/result/widgets/result_header.dart';
import 'package:swaranusaquiz/app/modules/result/widgets/result_stat_card.dart';
import 'package:swaranusaquiz/app/modules/result/widgets/score_circle.dart';

class QuizResultScreen extends StatelessWidget {
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;

  const QuizResultScreen({
    super.key,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final controller = QuizResultController(
      QuizResultSummary(
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        totalQuestions: totalQuestions,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const ResultHeader(),
                const SizedBox(height: 10),
                ScoreCircle(percentage: controller.scorePercentage),
                const SizedBox(height: 25),
                const Text(
                  'Selamat User!',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 90),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      ResultStatCard(
                        icon: Icons.check_circle,
                        iconColor: AppColors.success,
                        label: 'Jawaban Benar',
                        value: correctAnswers.toString(),
                      ),
                      const SizedBox(height: 16),
                      ResultStatCard(
                        icon: Icons.cancel,
                        iconColor: Colors.red,
                        label: 'Jawaban Salah',
                        value: wrongAnswers.toString(),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      ResultActionButton(
                        label: 'Tinjau Jawaban',
                        onPressed: controller.openReview,
                      ),
                      const SizedBox(height: 12),
                      ResultActionButton(
                        label: 'Main Ulang',
                        type: ResultActionButtonType.outline,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Balik ke Mode',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
