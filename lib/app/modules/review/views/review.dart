import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/data/models/quiz_answer.dart';
import 'package:swaranusaquiz/app/modules/review/controllers/review_answers_controller.dart';
import 'package:swaranusaquiz/app/modules/review/widgets/review_answer_card.dart';
import 'package:swaranusaquiz/app/modules/review/widgets/review_header.dart';

class ReviewAnswersScreen extends StatelessWidget {
  final List<QuizAnswer> answers;
  final VoidCallback? onBackToHome;

  const ReviewAnswersScreen({
    super.key,
    required this.answers,
    this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ReviewAnswersController(answers);
    final items = controller.displayItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ReviewHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    for (var index = 0; index < items.length; index++) ...[
                      if (index > 0) const SizedBox(height: 16),
                      ReviewAnswerCard(item: items[index]),
                    ],
                    const SizedBox(height: 24),
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
