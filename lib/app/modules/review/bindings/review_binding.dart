import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/models/quiz_answer.dart';
import 'package:swaranusaquiz/app/modules/review/controllers/review_answers_controller.dart';

class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    final answers = Get.arguments is List<QuizAnswer>
        ? Get.arguments as List<QuizAnswer>
        : const <QuizAnswer>[];

    Get.lazyPut<ReviewAnswersController>(
      () => ReviewAnswersController(answers),
    );
  }
}
