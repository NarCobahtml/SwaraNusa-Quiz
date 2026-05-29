class QuizResultSummary {
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final String title;
  final String modeId;
  final String levelId;

  const QuizResultSummary({
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
    this.title = '',
    this.modeId = '',
    this.levelId = '',
  });

  int get scorePercentage {
    if (totalQuestions <= 0) return 0;

    final percentage = (correctAnswers / totalQuestions) * 100;
    return percentage.isFinite ? percentage.round() : 0;
  }
}
