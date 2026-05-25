import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_config.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_question.dart';

class QuizRepository {
  QuizRepository({ContentRepository? contentRepository})
    : _contentRepository = contentRepository ?? ContentRepository();

  final ContentRepository _contentRepository;

  Future<List<QuizQuestion>> loadQuestions(QuizSessionConfig config) async {
    final docs = await _contentRepository.loadQuestions(config.levelId);
    final questions = docs
        .map(QuizQuestion.fromDoc)
        .where((question) => question.options.isNotEmpty)
        .where((question) => question.correctAnswer.isNotEmpty)
        .toList()
      ..sort((a, b) => a.questionNumber.compareTo(b.questionNumber));

    return questions;
  }
}
