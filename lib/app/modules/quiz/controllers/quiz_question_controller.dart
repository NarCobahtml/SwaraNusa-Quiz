import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_question_data.dart';

class QuizQuestionController extends ChangeNotifier {
  final QuizQuestionData question;
  final int initialSeconds;

  QuizQuestionController({
    required this.question,
    this.initialSeconds = 45,
  }) : _timeRemaining = initialSeconds;

  int _timeRemaining;
  bool _isTimerActive = true;

  int get timeRemaining => _timeRemaining;

  void start(BuildContext context) {
    _tick(Navigator.of(context));
  }

  void _tick(NavigatorState navigator) {
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isTimerActive) return;

      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
        _tick(navigator);
      } else {
        _isTimerActive = false;
        _pushReplacement(navigator, question.wrongPage);
      }
    });
  }

  void checkAnswer(BuildContext context, String selectedAnswer) {
    _isTimerActive = false;
    final destination = selectedAnswer == question.correctAnswer
        ? question.correctPage
        : question.wrongPage;

    _pushReplacement(Navigator.of(context), destination);
  }

  void openWrongAnswer(BuildContext context) {
    _isTimerActive = false;
    _pushReplacement(Navigator.of(context), question.wrongPage);
  }

  void stop() {
    _isTimerActive = false;
  }

  void _pushReplacement(NavigatorState navigator, Widget destination) {
    navigator.pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
