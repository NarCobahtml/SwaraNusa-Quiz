class QuizResultSummary {
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final String title;
  final String modeId;
  final String levelId;
  final bool isDailyQuiz;
  final int questionLimit;
  final int perfectRewardCoin;
  final int bonusCoin;
  final bool rewardAlreadyClaimed;

  const QuizResultSummary({
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
    this.title = '',
    this.modeId = '',
    this.levelId = '',
    this.isDailyQuiz = false,
    this.questionLimit = 10,
    this.perfectRewardCoin = 0,
    this.bonusCoin = 0,
    this.rewardAlreadyClaimed = false,
  });

  int get scorePercentage {
    if (totalQuestions <= 0) return 0;

    final percentage = (correctAnswers / totalQuestions) * 100;
    return percentage.isFinite ? percentage.round() : 0;
  }
}
