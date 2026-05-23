import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class AppSnackbar {
  const AppSnackbar._();

  static void success(String title, String message) {
    _show(
      title,
      message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  static void error(String title, String message) {
    _show(
      title,
      message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
    );
  }

  static void _show(
    String title,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: AppColors.textLight,
      icon: Icon(icon, color: AppColors.textLight),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      shouldIconPulse: false,
      snackStyle: SnackStyle.FLOATING,
    );
  }
}
