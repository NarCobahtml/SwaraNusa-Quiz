import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class ScoreCircle extends StatelessWidget {
  final int percentage;

  const ScoreCircle({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: Center(
          child: Text(
            '$percentage%',
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 56,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
