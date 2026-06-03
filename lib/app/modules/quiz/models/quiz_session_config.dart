class QuizLevel {
  final String title;
  final String modeId;
  final String levelId;

  const QuizLevel({
    required this.title,
    required this.modeId,
    required this.levelId,
  });

  int get number {
    final parts = levelId.split('_');
    return int.tryParse(parts.last) ?? 1;
  }
}

class QuizSessionConfig extends QuizLevel {
  final bool isDailyQuiz;
  final int questionLimit;
  final int perfectRewardCoin;

  const QuizSessionConfig({
    required super.title,
    required super.modeId,
    required super.levelId,
    this.isDailyQuiz = false,
    this.questionLimit = 10,
    this.perfectRewardCoin = 100,
  });

  const QuizSessionConfig.dailyQuiz()
    : isDailyQuiz = true,
      questionLimit = 10,
      perfectRewardCoin = 100,
      super(
        title: 'Tantangan Harian',
        modeId: 'daily_quiz',
        levelId: 'daily_quiz',
      );
}
