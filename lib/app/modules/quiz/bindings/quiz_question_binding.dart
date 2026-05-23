import 'package:get/get.dart';
import 'package:swaranusaquiz/app/modules/quiz/controllers/quiz_question_controller.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_question_data.dart';
import 'package:swaranusaquiz/app/modules/quiz/views/kuis/kuis_benar/kuis_benar1.dart';
import 'package:swaranusaquiz/app/modules/quiz/views/kuis/kuis_salah/kuis_salah1.dart';

class QuizQuestionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizQuestionController>(
      () => QuizQuestionController(
        question: const QuizQuestionData(
          title: 'Tebak Gambar',
          questionNumber: 1,
          totalQuestions: 10,
          imagePath: 'assets/image/gambar_tifa.png',
          correctAnswer: 'Tifa',
          options: ['Tifa', 'Kolintang', 'Gamelan', 'Angklung'],
          correctPage: KuisBenar1(),
          wrongPage: KuisSalah1(),
        ),
      ),
    );
  }
}
