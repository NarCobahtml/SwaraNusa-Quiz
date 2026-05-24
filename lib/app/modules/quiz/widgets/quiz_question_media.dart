import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/modules/quiz/models/quiz_session_question.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class QuizQuestionMedia extends StatefulWidget {
  final QuizSessionQuestion question;

  const QuizQuestionMedia({
    super.key,
    required this.question,
  });

  @override
  State<QuizQuestionMedia> createState() => _QuizQuestionMediaState();
}

class _QuizQuestionMediaState extends State<QuizQuestionMedia> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<dynamic>? _completeSubscription;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _completeSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void didUpdateWidget(covariant QuizQuestionMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      unawaited(_audioPlayer.stop());
      _isPlaying = false;
    }
  }

  @override
  void dispose() {
    _completeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.question.mediaType == QuizMediaType.text) {
      return _TextQuestionCard(text: widget.question.questionText);
    }

    final media = widget.question.mediaType == QuizMediaType.audio
        ? _buildAudioCard()
        : _buildImageCard();

    return Column(
      children: [
        if (widget.question.questionText.isNotEmpty) ...[
          _QuestionPrompt(text: widget.question.questionText),
          const SizedBox(height: 18),
        ],
        media,
      ],
    );
  }

  Widget _buildImageCard() {
    final mediaUrl = widget.question.mediaUrl;
    if (mediaUrl.isEmpty) {
      return const _MediaFrame(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textLight,
          size: 54,
        ),
      );
    }

    return _MediaFrame(
      child: _isNetworkMedia(mediaUrl)
          ? Image.network(
              mediaUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.broken_image,
                  color: AppColors.textLight,
                  size: 54,
                );
              },
            )
          : Image.asset(mediaUrl, fit: BoxFit.cover),
    );
  }

  Widget _buildAudioCard() {
    return GestureDetector(
      onTap: () {
        unawaited(_toggleAudio());
      },
      child: _MediaFrame(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryLight, AppColors.primary],
            ),
          ),
          child: Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.94),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.overlay.withOpacity(0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.primary,
                size: 44,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    final mediaUrl = widget.question.mediaUrl;
    if (mediaUrl.isEmpty) return;

    await _audioPlayer.play(_audioSource(mediaUrl));
    if (mounted) setState(() => _isPlaying = true);
  }

  Source _audioSource(String mediaUrl) {
    if (_isNetworkMedia(mediaUrl)) {
      return UrlSource(mediaUrl);
    }
    return AssetSource(_assetAudioPath(mediaUrl));
  }

  bool _isNetworkMedia(String value) {
    final normalized = value.toLowerCase();
    return normalized.startsWith('http://') || normalized.startsWith('https://');
  }

  String _assetAudioPath(String value) {
    const assetPrefix = 'assets/';
    if (value.startsWith(assetPrefix)) {
      return value.substring(assetPrefix.length);
    }
    return value;
  }
}

class _MediaFrame extends StatelessWidget {
  final Widget child;

  const _MediaFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlay.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}

class _QuestionPrompt extends StatelessWidget {
  final String text;

  const _QuestionPrompt({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textLight,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TextQuestionCard extends StatelessWidget {
  final String text;

  const _TextQuestionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlay.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
