import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/modules/quiz/controllers/quiz_question_controller.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_question_data.dart';
import 'package:swaranusaquiz/app/modules/quiz/views/kuis/kuis_benar/kuis_benar1.dart';
import 'package:swaranusaquiz/app/modules/quiz/views/kuis/kuis_salah/kuis_salah1.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_answer_button.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_page_layout.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_question_image.dart';

class KuisPertanyaan1 extends StatefulWidget {
  const KuisPertanyaan1({super.key});

  @override
  State<KuisPertanyaan1> createState() => _KuisPertanyaan1State();
}

class _KuisPertanyaan1State extends State<KuisPertanyaan1> {
  late final QuizQuestionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuizQuestionController(
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
    )..start(context);
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _controller.question;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return QuizPageLayout(
          title: question.title,
          questionNumber: question.questionNumber,
          totalQuestions: question.totalQuestions,
          timeRemaining: _controller.timeRemaining,
          question: QuizQuestionImage(imagePath: question.imagePath),
          body: Column(
            children: [
              for (final option in question.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: QuizAnswerButton(
                    option: option,
                    onTap: () => _controller.checkAnswer(context, option),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
