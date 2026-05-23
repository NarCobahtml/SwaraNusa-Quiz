import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_feedback_answer.dart';

class QuizCorrectFeedbackBody extends StatelessWidget {
  final String answer;

  const QuizCorrectFeedbackBody({super.key, required this.answer});

  @override
  Widget build(BuildContext context) {
    return QuizFeedbackAnswer(answer: answer);
  }
}

class QuizWrongFeedbackBody extends StatelessWidget {
  final String answer;

  const QuizWrongFeedbackBody({super.key, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Column(
          children: [
            Text(
              'SALAH!',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Jawaban Benar:',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        QuizFeedbackAnswer(answer: answer),
      ],
    );
  }
}
