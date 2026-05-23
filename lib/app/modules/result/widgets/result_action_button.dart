import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

enum ResultActionButtonType { primary, outline }

class ResultActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ResultActionButtonType type;

  const ResultActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ResultActionButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: type == ResultActionButtonType.primary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                shadowColor: Colors.transparent,
              ),
              child: _ButtonLabel(label),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: _ButtonLabel(label),
            ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  final String label;
  const _ButtonLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}
