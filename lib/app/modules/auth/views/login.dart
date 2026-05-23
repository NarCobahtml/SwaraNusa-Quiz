import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/modules/auth/controllers/login_controller.dart';
import 'package:swaranusaquiz/app/modules/auth/widgets/auth_social_button.dart';
import 'package:swaranusaquiz/app/modules/auth/widgets/auth_text_field.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: width * 0.25,
                height: width * 0.25,
                child: SvgPicture.asset(
                  'assets/icon/logo.svg',
                  semanticsLabel: 'Logo',
                  placeholderBuilder: (context) => const Icon(
                    Icons.music_note,
                    color: AppColors.primary,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selamat Datang di\nSwaraNusa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 55),
              AuthTextField(
                hint: 'contoh@email.com',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                hint: 'Setidaknya 8 karakter',
                controller: controller.passwordController,
                obscure: true,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: controller.openForgotPassword,
                  child: const Text(
                    'Lupa Password?',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textLight,
                            ),
                          )
                        : const Text(
                            'Log In',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: controller.openSignup,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: BorderSide.none,
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.divider)),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    color: AppColors.background,
                    child: const Text(
                      'Atau lanjut dengan',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 25),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: AuthSocialButton(
                        label: 'Facebook',
                        assetName: 'assets/icon/fb.svg',
                        fallbackIcon: Icons.facebook,
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.loginWithFacebook,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AuthSocialButton(
                        label: 'Google',
                        assetName: 'assets/icon/google.svg',
                        fallbackIcon: Icons.g_mobiledata,
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.loginWithGoogle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
