class ReviewAnswerItem {
  final int questionNumber;
  final String? imagePath;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  const ReviewAnswerItem({
    required this.questionNumber,
    required this.imagePath,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });
}
