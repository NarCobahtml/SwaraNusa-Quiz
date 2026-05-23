import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/modules/quiz/views/kuis/kuis_pertanyaan/kuis_pertanyaan2.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_feedback_body.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_page_layout.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_question_image.dart';

class KuisBenar1 extends StatefulWidget {
  const KuisBenar1({super.key});

  @override
  State<KuisBenar1> createState() => _KuisBenar1State();
}

class _KuisBenar1State extends State<KuisBenar1> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const KuisPertanyaan2(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const QuizPageLayout(
      title: 'Tebak Gambar',
      questionNumber: 1,
      totalQuestions: 10,
      timeRemaining: 45,
      question: QuizQuestionImage(imagePath: 'assets/image/gambar_tifa.png'),
      body: QuizCorrectFeedbackBody(answer: 'Tifa'),
    );
  }
}
