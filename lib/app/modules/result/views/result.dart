import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final controller = Get.isRegistered<QuizResultController>()
        ? Get.find<QuizResultController>()
        : QuizResultController(_summaryFromArguments());

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
                Text(
                  controller.completionTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (controller.isDailyQuiz) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _DailyQuizRewardBanner(summary: controller.summary),
                  ),
                ],
                SizedBox(height: controller.isDailyQuiz ? 28 : 90),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      ResultStatCard(
                        icon: Icons.check_circle,
                        iconColor: AppColors.success,
                        label: 'Jawaban Benar',
                        value: controller.correctAnswers.toString(),
                      ),
                      const SizedBox(height: 16),
                      ResultStatCard(
                        icon: Icons.cancel,
                        iconColor: Colors.red,
                        label: 'Jawaban Salah',
                        value: controller.wrongAnswers.toString(),
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
                        onPressed: controller.retryQuiz,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: controller.backToMode,
                        child: Text(
                          controller.backButtonLabel,
                          style: const TextStyle(
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

  QuizResultSummary _summaryFromArguments() {
    if (Get.arguments is QuizResultSummary) {
      return Get.arguments as QuizResultSummary;
    }

    return QuizResultSummary(
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      totalQuestions: totalQuestions,
    );
  }
}

class _DailyQuizRewardBanner extends StatelessWidget {
  final QuizResultSummary summary;

  const _DailyQuizRewardBanner({required this.summary});

  @override
  Widget build(BuildContext context) {
    final isPerfect = summary.scorePercentage >= 100;
    final reward = summary.perfectRewardCoin > 0
        ? summary.perfectRewardCoin
        : 100;
    final String message;
    if (summary.bonusCoin > 0) {
      message = '+${summary.bonusCoin} coin berhasil masuk ke saldo.';
    } else if (isPerfect && summary.rewardAlreadyClaimed) {
      message = 'Reward sempurna hari ini sudah diklaim.';
    } else {
      message = 'Skor 100% untuk klaim $reward coin harian.';
    }

    final Color color;
    if (summary.bonusCoin > 0) {
      color = AppColors.success;
    } else if (isPerfect) {
      color = AppColors.gold;
    } else {
      color = AppColors.primary;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on,
              color: AppColors.textLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
