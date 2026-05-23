import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';
import 'package:swaranusaquiz/app/modules/auth/controllers/auth_error_message.dart';
import 'package:swaranusaquiz/app/utils/app_snackbar.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;
  final emailController = TextEditingController();
  final isLoading = false.obs;

  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showError('Email wajib diisi.');
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _authRepository.sendPasswordReset(email);
      _showSuccess('Link reset password sudah dikirim ke email Anda.');
      Get.back();
    } catch (error) {
      _showError(authErrorMessage(error), title: 'Gagal mengirim email');
    } finally {
      isLoading.value = false;
    }
  }

  void close() {
    Get.back();
  }

  void _showSuccess(String message, {String title = 'Reset password'}) =>
      AppSnackbar.success(title, message);

  void _showError(String message, {String title = 'Reset password'}) =>
      AppSnackbar.error(title, message);

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
