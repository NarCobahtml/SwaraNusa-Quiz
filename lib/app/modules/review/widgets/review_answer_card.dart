import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/modules/quiz/services/quiz_media_service.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/review/models/review_answer_item.dart';

class ReviewAnswerCard extends StatelessWidget {
  final ReviewAnswerItem item;

  const ReviewAnswerCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soal ${item.questionNumber}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                _AnswerImage(imagePath: item.imagePath),
                const SizedBox(height: 12),
                _AnswerLine(
                  label: item.questionNumber <= 6
                      ? 'Jawabanmu: '
                      : 'Your answer: ',
                  value: item.userAnswer,
                  valueColor: item.isCorrect
                      ? AppColors.gold
                      : Colors.red.shade400,
                ),
                if (!item.isCorrect) ...[
                  const SizedBox(height: 4),
                  _AnswerLine(
                    label: item.questionNumber <= 6
                        ? 'Jawaban Benar: '
                        : 'Correct answer: ',
                    value: item.correctAnswer,
                    valueColor: AppColors.success,
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _AnswerStatusIcon(isCorrect: item.isCorrect),
          ),
        ],
      ),
    );
  }
}

class _AnswerImage extends StatelessWidget {
  final String? imagePath;
  static const _mediaService = QuizMediaService();

  const _AnswerImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: path != null && path.isNotEmpty
          ? _mediaService.isNetworkUrl(path)
              ? Image.network(
                  path,
                  width: 130,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const _ImageFallback(width: 150, height: 125),
                )
              : Image.asset(
                  path,
                  width: 130,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const _ImageFallback(width: 150, height: 125),
                )
          : const _ImageFallback(width: 130, height: 90),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final double width;
  final double height;
  const _ImageFallback({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image, color: AppColors.textMuted),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _AnswerLine(
      {required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerStatusIcon extends StatelessWidget {
  final bool isCorrect;
  const _AnswerStatusIcon({required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.success : Colors.red.shade400,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCorrect ? Icons.check : Icons.close,
        color: AppColors.textLight,
        size: 18,
      ),
    );
  }
}
