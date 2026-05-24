import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';
import 'package:swaranusaquiz/app/data/services/backend_services.dart';
import 'package:swaranusaquiz/app/modules/quiz/data/quiz_fallback_questions.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_config.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_question.dart';
import 'package:swaranusaquiz/app/modules/result/models/quiz_result_summary.dart';
import 'package:swaranusaquiz/app/routes/app_routes.dart';

enum QuizSessionPhase {
  loading,
  question,
  correct,
  wrong,
  finishing,
  error,
}

class QuizSessionController extends ChangeNotifier {
  QuizSessionController({
    required this.config,
    ContentRepository? contentRepository,
    QuizEngineService? quizEngine,
  }) : _contentRepository = contentRepository ?? ContentRepository(),
       _quizEngine = quizEngine ?? QuizEngineService.instance;

  final QuizSessionConfig config;
  final ContentRepository _contentRepository;
  final QuizEngineService _quizEngine;

  final List<QuizSessionQuestion> _questions = [];
  Timer? _questionTimer;
  Timer? _feedbackTimer;
  bool _disposed = false;

  QuizSessionPhase _phase = QuizSessionPhase.loading;
  int _currentIndex = 0;
  int _timeRemaining = 45;
  String? _errorMessage;

  QuizSessionPhase get phase => _phase;
  List<QuizSessionQuestion> get questions => List.unmodifiable(_questions);
  int get currentIndex => _currentIndex;
  int get questionNumber => _currentIndex + 1;
  int get totalQuestions => _questions.length;
  int get timeRemaining => _timeRemaining;
  String? get errorMessage => _errorMessage;

  QuizSessionQuestion? get currentQuestion {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return null;
    return _questions[_currentIndex];
  }

  Future<void> load() async {
    _cancelTimers();
    _phase = QuizSessionPhase.loading;
    _errorMessage = null;
    _questions.clear();
    _currentIndex = 0;
    _safeNotify();

    final fallbackQuestions = QuizFallbackQuestions.forConfig(config);
    Object? loadError;

    try {
      final docs = await _contentRepository.loadQuestions(config.levelId);
      _questions.addAll(
        docs
            .map(QuizSessionQuestion.fromDoc)
            .where((question) => question.options.isNotEmpty)
            .where((question) => question.correctAnswer.isNotEmpty),
      );
    } catch (error) {
      loadError = error;
    }

    if (_disposed) return;

    if (_questions.isEmpty) {
      _questions.addAll(fallbackQuestions);
    }

    if (_questions.isEmpty) {
      _phase = QuizSessionPhase.error;
      _errorMessage = loadError == null
          ? 'Belum ada soal untuk level ini.'
          : 'Gagal memuat soal: $loadError';
      _safeNotify();
      return;
    }

    _questions.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));
    _quizEngine.start(
      modeId: config.modeId,
      levelId: config.levelId,
      totalQuestions: _questions.length,
    );
    _showQuestionAt(0);
  }

  void answer(String selectedAnswer) {
    if (_phase != QuizSessionPhase.question) return;

    final question = currentQuestion;
    if (question == null) return;

    _questionTimer?.cancel();
    final timeSpent = (question.timeLimitSeconds - _timeRemaining)
        .clamp(0, question.timeLimitSeconds)
        .toInt();
    final isCorrect = _quizEngine.checkAnswer(
      questionId: question.id,
      questionNumber: question.questionNumber > 0
          ? question.questionNumber
          : questionNumber,
      selectedAnswer: selectedAnswer,
      correctAnswer: question.correctAnswer,
      points: question.points,
      timeSpentSeconds: timeSpent,
      mediaUrl: question.mediaUrl,
      mediaType: question.mediaType.name,
    );

    _phase = isCorrect ? QuizSessionPhase.correct : QuizSessionPhase.wrong;
    _safeNotify();

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 1), () {
      _moveNext();
    });
  }

  Future<void> _moveNext() async {
    if (_disposed) return;
    final nextIndex = _currentIndex + 1;
    if (nextIndex >= _questions.length) {
      await _finish();
      return;
    }
    _showQuestionAt(nextIndex);
  }

  void _showQuestionAt(int index) {
    _cancelTimers();
    _currentIndex = index;
    final question = currentQuestion;
    _timeRemaining = question?.timeLimitSeconds ?? 45;
    _phase = QuizSessionPhase.question;
    _safeNotify();
    _startTimer();
  }

  void _startTimer() {
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed || _phase != QuizSessionPhase.question) {
        timer.cancel();
        return;
      }

      if (_timeRemaining <= 1) {
        _timeRemaining = 0;
        _safeNotify();
        answer('');
        return;
      }

      _timeRemaining -= 1;
      _safeNotify();
    });
  }

  Future<void> _finish() async {
    _cancelTimers();
    _phase = QuizSessionPhase.finishing;
    _safeNotify();

    QuizSessionSummary summary;
    try {
      summary = await _quizEngine.finish();
    } catch (_) {
      summary = _quizEngine.currentSummary();
    }

    if (_disposed) return;
    Get.offNamed(
      AppRoutes.result,
      arguments: QuizResultSummary(
        correctAnswers: summary.correctAnswers,
        wrongAnswers: summary.wrongAnswers,
        totalQuestions: summary.totalQuestions,
      ),
    );
  }

  void _cancelTimers() {
    _questionTimer?.cancel();
    _feedbackTimer?.cancel();
    _questionTimer = null;
    _feedbackTimer = null;
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTimers();
    super.dispose();
  }
}
