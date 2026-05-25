import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/modules/quiz/controllers/quiz_session_controller.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_config.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_question.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_answer_button.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_feedback_body.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_header.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_page_layout.dart';
import 'package:swaranusaquiz/app/modules/quiz/widgets/quiz_question_media.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class QuizSessionPage extends StatefulWidget {
  final QuizSessionConfig config;

  const QuizSessionPage({
    super.key,
    required this.config,
  });

  @override
  State<QuizSessionPage> createState() => _QuizSessionPageState();
}

class _QuizSessionPageState extends State<QuizSessionPage> {
  late final QuizSessionController _controller;
  late final String _controllerTag;

  @override
  void initState() {
    super.initState();
    _controllerTag = '${widget.config.levelId}_${identityHashCode(this)}';
    _controller = Get.put(
      QuizSessionController(config: widget.config),
      tag: _controllerTag,
    )..load();
  }

  @override
  void dispose() {
    Get.delete<QuizSessionController>(tag: _controllerTag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final question = _controller.currentQuestion;
        final phase = _controller.phase.value;

        if (phase == QuizSessionPhase.error) {
          return _StatusScaffold(
            title: widget.config.title,
            child: _ErrorState(
              message: _controller.errorMessage.value ?? 'Gagal memuat soal.',
              onRetry: () {
                _controller.load();
              },
            ),
          );
        }

        if (phase == QuizSessionPhase.loading || question == null) {
          return _StatusScaffold(
            title: widget.config.title,
            child: const CircularProgressIndicator(color: AppColors.gold),
          );
        }

        return QuizPageLayout(
          title: question.title.isEmpty ? widget.config.title : question.title,
          questionNumber: _controller.questionNumber,
          totalQuestions: _controller.totalQuestions,
          timeRemaining: _controller.timeRemaining.value,
          question: QuizQuestionMedia(
            key: ValueKey('${question.id}_${phase.name}'),
            question: question,
          ),
          body: _buildBody(question, phase),
        );
      },
    );
  }

  Widget _buildBody(QuizQuestion question, QuizSessionPhase phase) {
    switch (phase) {
      case QuizSessionPhase.question:
        return _AnswerOptions(
          options: question.options,
          onAnswer: _controller.answer,
        );
      case QuizSessionPhase.correct:
        return QuizCorrectFeedbackBody(answer: question.correctAnswer);
      case QuizSessionPhase.wrong:
        return QuizWrongFeedbackBody(answer: question.correctAnswer);
      case QuizSessionPhase.finishing:
        return const CircularProgressIndicator(color: AppColors.gold);
      case QuizSessionPhase.loading:
      case QuizSessionPhase.error:
        return const SizedBox.shrink();
    }
  }
}

class _AnswerOptions extends StatelessWidget {
  final List<String> options;
  final ValueChanged<String> onAnswer;

  const _AnswerOptions({
    required this.options,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: QuizAnswerButton(
              option: option,
              onTap: () => onAnswer(option),
            ),
          ),
      ],
    );
  }
}

class _StatusScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const _StatusScaffold({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            QuizHeader(title: title),
            Expanded(
              child: Center(child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
