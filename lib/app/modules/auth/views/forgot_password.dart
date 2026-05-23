import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/auth/controllers/forgot_password_controller.dart';
import 'package:swaranusaquiz/app/modules/auth/widgets/auth_primary_button.dart';
import 'package:swaranusaquiz/app/modules/auth/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotPasswordController>();

    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: controller.close,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 30),
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      color: AppColors.primary,
                      size: 50,
                    ),
                  ),
                ),
                const Text(
                  'Lupa Password?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Masukkan email yang terdaftar, lalu kami kirimkan link reset password.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                AuthTextField(
                  controller: controller.emailController,
                  hint: 'contoh@email.com',
                  icon: Icons.email_outlined,
                  borderRadius: 16,
                  showBorder: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 40),
                AuthPrimaryButton(
                  label: controller.isLoading.value
                      ? 'Mengirim...'
                      : 'Kirim Link Reset',
                  onPressed: controller.sendResetEmail,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
