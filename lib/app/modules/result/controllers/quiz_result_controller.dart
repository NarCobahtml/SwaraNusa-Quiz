import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/models/quiz_answer.dart';
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
    Get.toNamed(
      AppRoutes.review,
      arguments: ReviewAnswersData.getSampleData(),
    );
  }
}
