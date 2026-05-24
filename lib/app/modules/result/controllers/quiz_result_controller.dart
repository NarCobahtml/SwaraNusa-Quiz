import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/models/quiz_answer.dart';
import 'package:swaranusaquiz/app/data/services/backend_services.dart';
import 'package:swaranusaquiz/app/routes/app_pages.dart';
import 'package:swaranusaquiz/app/modules/result/models/quiz_result_summary.dart';

class QuizResultController extends GetxController {
  final QuizResultSummary summary;

  QuizResultController(this.summary);

  int get scorePercentage {
    if (summary.totalQuestions <= 0) return 0;

    final percentage =
        (summary.correctAnswers / summary.totalQuestions) * 100;
    return percentage.isFinite ? percentage.toInt() : 0;
  }

  void openReview() {
    final answers = QuizEngineService.instance.answers.map((answer) {
      return QuizAnswer(
        questionNumber: answer.questionNumber,
        userAnswer: answer.userAnswer.isEmpty
            ? 'Tidak menjawab'
            : answer.userAnswer,
        correctAnswer: answer.correctAnswer,
        imagePath: answer.mediaType == 'image' && answer.mediaUrl.isNotEmpty
            ? answer.mediaUrl
            : null,
      );
    }).toList();

    Get.toNamed(
      AppRoutes.review,
      arguments: answers.isEmpty ? ReviewAnswersData.getSampleData() : answers,
    );
  }
}
