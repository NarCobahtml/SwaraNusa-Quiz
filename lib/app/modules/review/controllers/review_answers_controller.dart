import 'package:swaranusaquiz/app/data/models/quiz_answer.dart';
import 'package:swaranusaquiz/app/modules/review/models/review_answer_item.dart';

class ReviewAnswersController {
  final List<QuizAnswer> answers;

  const ReviewAnswersController(this.answers);

  List<ReviewAnswerItem> get displayItems {
    final visibleCount = answers.length < 3 ? 3 : answers.length;

    return List<ReviewAnswerItem>.generate(visibleCount, (index) {
      final answer = index < answers.length ? answers[index] : null;

      return ReviewAnswerItem(
        questionNumber: index + 1,
        imagePath: answer?.imagePath,
        userAnswer: answer?.userAnswer ?? '',
        correctAnswer: answer?.correctAnswer ?? '',
        isCorrect: answer?.isCorrect ?? true,
      );
    });
  }
}
