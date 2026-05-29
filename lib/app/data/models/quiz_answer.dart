class QuizAnswer {
  final int questionNumber;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? imagePath;

  QuizAnswer({
    required this.questionNumber,
    required this.userAnswer,
    required this.correctAnswer,
    this.imagePath,
  }) : isCorrect =
           userAnswer.trim().toLowerCase() ==
           correctAnswer.trim().toLowerCase();
}
