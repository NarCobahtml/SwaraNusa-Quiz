import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class AuthTextField extends StatelessWidget {
  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final IconData? icon;
  final bool isOtp;
  final Color fillColor;
  final double borderRadius;
  final bool showBorder;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const AuthTextField({
    super.key,
    required this.hint,
    this.obscure = false,
    this.controller,
    this.icon,
    this.isOtp = false,
    this.fillColor = AppColors.surface,
    this.borderRadius = 12,
    this.showBorder = false,
    this.style,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(color: AppColors.divider, width: 1)
            : null,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType ??
            (isOtp ? TextInputType.number : TextInputType.emailAddress),
        textInputAction: textInputAction,
        style: style ??
            TextStyle(
              color: AppColors.textDark,
              fontSize: isOtp ? 16 : null,
              letterSpacing: isOtp ? 2.0 : 0.0,
            ),
        textAlign: isOtp ? TextAlign.center : TextAlign.start,
        decoration: InputDecoration(
          prefixIcon: isOtp || icon == null
              ? null
              : Icon(icon, color: AppColors.textMuted),
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
