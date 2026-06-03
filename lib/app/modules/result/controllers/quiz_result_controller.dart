import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/models/quiz_answer.dart';
import 'package:swaranusaquiz/app/data/services/backend_services.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_config.dart';
import 'package:swaranusaquiz/app/modules/quiz/views/quiz_session_page.dart';
import 'package:swaranusaquiz/app/routes/app_pages.dart';
import 'package:swaranusaquiz/app/modules/result/models/quiz_result_summary.dart';

class QuizResultController extends GetxController {
  final QuizResultSummary summary;

  QuizResultController(this.summary);

  int get scorePercentage => summary.scorePercentage;

  int get correctAnswers => summary.correctAnswers;
  int get wrongAnswers => summary.wrongAnswers;
  bool get isDailyQuiz => summary.isDailyQuiz;

  String get completionTitle {
    if (!summary.isDailyQuiz) return 'Selamat User!';
    if (summary.bonusCoin > 0) return 'Bonus Harian Diklaim!';
    if (summary.scorePercentage >= 100) return 'Skor Sempurna!';
    return 'Tantangan Selesai';
  }

  String get backButtonLabel {
    return summary.isDailyQuiz ? 'Balik ke Beranda' : 'Balik ke Mode';
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
      arguments: answers,
    );
  }

  void retryQuiz() {
    if (summary.modeId.isEmpty || summary.levelId.isEmpty) return;

    Get.off(
      () => QuizSessionPage(
        config: QuizSessionConfig(
          title: summary.title.isEmpty ? 'Kuis' : summary.title,
          modeId: summary.modeId,
          levelId: summary.levelId,
          isDailyQuiz: summary.isDailyQuiz,
          questionLimit: summary.questionLimit,
          perfectRewardCoin: summary.perfectRewardCoin,
        ),
      ),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 150),
    );
  }

  void backToMode() {
    Get.offAllNamed(
      AppRoutes.mainNavigation,
      arguments: summary.isDailyQuiz ? 0 : 4,
    );
  }
}
