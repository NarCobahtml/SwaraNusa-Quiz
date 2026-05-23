import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class AuthSocialButton extends StatelessWidget {
  final String label;
  final String assetName;
  final IconData fallbackIcon;
  final VoidCallback? onPressed;

  const AuthSocialButton({
    super.key,
    required this.label,
    required this.assetName,
    this.fallbackIcon = Icons.error,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 51,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: SvgPicture.asset(
                assetName,
                placeholderBuilder: (context) => Icon(
                  fallbackIcon,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
