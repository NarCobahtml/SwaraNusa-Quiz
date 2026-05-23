import 'package:get/get.dart';
import 'package:swaranusaquiz/app/modules/result/controllers/quiz_result_controller.dart';
import 'package:swaranusaquiz/app/modules/result/models/quiz_result_summary.dart';

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    final summary = Get.arguments is QuizResultSummary
        ? Get.arguments as QuizResultSummary
        : const QuizResultSummary(
            correctAnswers: 8,
            wrongAnswers: 2,
            totalQuestions: 10,
          );

    Get.lazyPut<QuizResultController>(() => QuizResultController(summary));
  }
}
