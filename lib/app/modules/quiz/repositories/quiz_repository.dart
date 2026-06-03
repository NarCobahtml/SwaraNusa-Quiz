import 'dart:math';

import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_config.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_question.dart';

class QuizRepository {
  QuizRepository({ContentRepository? contentRepository})
    : _contentRepository = contentRepository ?? ContentRepository();

  final ContentRepository _contentRepository;

  Future<List<QuizQuestion>> loadQuestions(QuizSessionConfig config) async {
    if (config.isDailyQuiz) {
      return _loadDailyQuestions(config);
    }

    final docs = await _contentRepository.loadQuestions(config.levelId);
    final questions = docs
        .map(QuizQuestion.fromDoc)
        .where((question) => question.options.isNotEmpty)
        .where((question) => question.correctAnswer.isNotEmpty)
        .toList()
      ..sort((a, b) => a.questionNumber.compareTo(b.questionNumber));

    return questions;
  }

  Future<List<QuizQuestion>> _loadDailyQuestions(
    QuizSessionConfig config,
  ) async {
    final docs = await _contentRepository.loadAllActiveQuestions();
    final questions = docs
        .map(QuizQuestion.fromDoc)
        .where((question) => question.options.isNotEmpty)
        .where((question) => question.correctAnswer.isNotEmpty)
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    questions.shuffle(Random(_dailySeed()));
    final limit = config.questionLimit <= 0 ? 10 : config.questionLimit;
    final selected = questions.take(limit).toList(growable: false);

    return [
      for (var index = 0; index < selected.length; index++)
        _dailyQuestion(
          selected[index],
          questionNumber: index + 1,
          title: config.title,
        ),
    ];
  }

  QuizQuestion _dailyQuestion(
    QuizQuestion question, {
    required int questionNumber,
    required String title,
  }) {
    return QuizQuestion(
      id: question.id,
      modeId: question.modeId,
      levelId: question.levelId,
      questionNumber: questionNumber,
      title: title.isEmpty ? question.title : title,
      questionText: question.questionText,
      mediaType: question.mediaType,
      mediaUrl: question.mediaUrl,
      options: question.options,
      correctAnswer: question.correctAnswer,
      explanation: question.explanation,
      timeLimitSeconds: question.timeLimitSeconds,
      points: question.points,
    );
  }

  int _dailySeed() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }
}
