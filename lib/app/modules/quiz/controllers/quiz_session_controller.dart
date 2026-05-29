import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/services/backend_services.dart';
import 'package:swaranusaquiz/app/data/services/user_service.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_config.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_question.dart';
import 'package:swaranusaquiz/app/modules/quiz/repositories/quiz_repository.dart';
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

class QuizSessionController extends GetxController {
  QuizSessionController({
    required this.config,
    QuizRepository? quizRepository,
    QuizEngineService? quizEngine,
  }) : _quizRepository = quizRepository ?? QuizRepository(),
       _quizEngine = quizEngine ?? QuizEngineService.instance;

  final QuizSessionConfig config;
  final QuizRepository _quizRepository;
  final QuizEngineService _quizEngine;

  final phase = QuizSessionPhase.loading.obs;
  final questions = <QuizQuestion>[].obs;
  final currentIndex = 0.obs;
  final timeRemaining = 45.obs;
  final errorMessage = RxnString();

  Timer? _questionTimer;
  Timer? _feedbackTimer;

  int get questionNumber => currentIndex.value + 1;
  int get totalQuestions => questions.length;

  QuizQuestion? get currentQuestion {
    if (questions.isEmpty || currentIndex.value >= questions.length) {
      return null;
    }
    return questions[currentIndex.value];
  }

  Future<void> load() async {
    _cancelTimers();
    phase.value = QuizSessionPhase.loading;
    errorMessage.value = null;
    questions.clear();
    currentIndex.value = 0;

    late final List<QuizQuestion> loadedQuestions;
    try {
      loadedQuestions = await _quizRepository
          .loadQuestions(config)
          .timeout(const Duration(seconds: 15));
      if (isClosed) return;
    } catch (error, stackTrace) {
      debugPrint('Gagal memuat soal dari Firestore: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (isClosed) return;
      phase.value = QuizSessionPhase.error;
      errorMessage.value =
          'Gagal memuat soal dari Firestore. Pastikan data sudah di-import dan koneksi internet aktif.';
      return;
    }

    if (loadedQuestions.isEmpty) {
      phase.value = QuizSessionPhase.error;
      errorMessage.value = 'Belum ada soal untuk level ini.';
      return;
    }

    questions.assignAll(loadedQuestions);
    _quizEngine.start(
      modeId: config.modeId,
      levelId: config.levelId,
      totalQuestions: questions.length,
    );
    _showQuestionAt(0);
  }

  void answer(String selectedAnswer) {
    if (phase.value != QuizSessionPhase.question) return;

    final question = currentQuestion;
    if (question == null) return;

    _questionTimer?.cancel();
    final timeSpent = (question.timeLimitSeconds - timeRemaining.value)
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

    phase.value = isCorrect ? QuizSessionPhase.correct : QuizSessionPhase.wrong;

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 1), () {
      _moveNext();
    });
  }

  Future<void> _moveNext() async {
    if (isClosed) return;
    final nextIndex = currentIndex.value + 1;
    if (nextIndex >= questions.length) {
      await _finish();
      return;
    }
    _showQuestionAt(nextIndex);
  }

  void _showQuestionAt(int index) {
    _cancelTimers();
    currentIndex.value = index;
    timeRemaining.value = currentQuestion?.timeLimitSeconds ?? 45;
    phase.value = QuizSessionPhase.question;
    _startTimer();
  }

  void _startTimer() {
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed || phase.value != QuizSessionPhase.question) {
        timer.cancel();
        return;
      }

      if (timeRemaining.value <= 1) {
        timeRemaining.value = 0;
        answer('');
        return;
      }

      timeRemaining.value -= 1;
    });
  }

  Future<void> _finish() async {
    _cancelTimers();
    phase.value = QuizSessionPhase.finishing;

    QuizSessionSummary summary;
    try {
      summary = await _quizEngine.finish();
      if (Get.isRegistered<UserService>()) {
        await UserService.to.reload();
      }
    } catch (error, stackTrace) {
      debugPrint('Gagal menyimpan hasil kuis: $error');
      debugPrintStack(stackTrace: stackTrace);
      summary = _quizEngine.currentSummary();
    }

    if (isClosed) return;
    Get.offNamed(
      AppRoutes.result,
      arguments: QuizResultSummary(
        correctAnswers: summary.correctAnswers,
        wrongAnswers: summary.wrongAnswers,
        totalQuestions: summary.totalQuestions,
        title: config.title,
        modeId: config.modeId,
        levelId: config.levelId,
      ),
    );
  }

  void _cancelTimers() {
    _questionTimer?.cancel();
    _feedbackTimer?.cancel();
    _questionTimer = null;
    _feedbackTimer = null;
  }

  @override
  void onClose() {
    _cancelTimers();
    super.onClose();
  }
}
