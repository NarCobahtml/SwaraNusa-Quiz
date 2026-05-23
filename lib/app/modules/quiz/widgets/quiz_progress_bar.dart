import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class QuizProgressBar extends StatelessWidget {
  final int questionNumber;
  final int totalQuestions;
  final int timeRemaining;

  const QuizProgressBar({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final isLowTime = timeRemaining <= 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            '$questionNumber/$totalQuestions',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: questionNumber / totalQuestions,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '00:${timeRemaining.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: isLowTime ? AppColors.error : AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
