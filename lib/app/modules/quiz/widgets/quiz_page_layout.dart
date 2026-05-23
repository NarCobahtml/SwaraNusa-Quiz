import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_header.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_progress_bar.dart';

class QuizPageLayout extends StatelessWidget {
  final String title;
  final int questionNumber;
  final int totalQuestions;
  final int timeRemaining;
  final Widget question;
  final Widget body;

  const QuizPageLayout({
    super.key,
    required this.title,
    required this.questionNumber,
    required this.totalQuestions,
    required this.timeRemaining,
    required this.question,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            QuizHeader(title: title),
            QuizProgressBar(
              questionNumber: questionNumber,
              totalQuestions: totalQuestions,
              timeRemaining: timeRemaining,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    question,
                    const SizedBox(height: 40),
                    body,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
