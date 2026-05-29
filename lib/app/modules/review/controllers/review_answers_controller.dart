import 'package:swaranusaquiz/app/data/models/quiz_answer.dart';
import 'package:swaranusaquiz/app/modules/review/models/review_answer_item.dart';

class ReviewAnswersController {
  final List<QuizAnswer> answers;

  const ReviewAnswersController(this.answers);

  List<ReviewAnswerItem> get displayItems {
    return List<ReviewAnswerItem>.generate(answers.length, (index) {
      final answer = answers[index];
      return ReviewAnswerItem(
        questionNumber: answer.questionNumber,
        imagePath: answer.imagePath,
        userAnswer: answer.userAnswer,
        correctAnswer: answer.correctAnswer,
        isCorrect: answer.isCorrect,
      );
    });
  }
}
