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
  const QuizSessionConfig({
    required super.title,
    required super.modeId,
    required super.levelId,
  });
}
