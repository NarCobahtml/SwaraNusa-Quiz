import 'package:flutter/widgets.dart';

class QuizQuestionData {
  final String title;
  final int questionNumber;
  final int totalQuestions;
  final String imagePath;
  final String correctAnswer;
  final List<String> options;
  final Widget correctPage;
  final Widget wrongPage;

  const QuizQuestionData({
    required this.title,
    required this.questionNumber,
    required this.totalQuestions,
    required this.imagePath,
    required this.correctAnswer,
    required this.options,
    required this.correctPage,
    required this.wrongPage,
  });

  double get progress => questionNumber / totalQuestions;
}
