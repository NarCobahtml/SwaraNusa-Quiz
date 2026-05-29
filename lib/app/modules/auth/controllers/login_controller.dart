import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';
import 'package:swaranusaquiz/app/data/services/backend_services.dart';
import 'package:swaranusaquiz/app/modules/auth/controllers/auth_error_message.dart';
import 'package:swaranusaquiz/app/routes/app_pages.dart';
import 'package:swaranusaquiz/app/utils/app_snackbar.dart';

class LoginController extends GetxController {
  LoginController({
    AuthRepository? authRepository,
    UserRepository? userRepository,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _userRepository = userRepository ?? UserRepository();

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  void openForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Email dan password wajib diisi.');
      return;
    }

    await _runAuthAction(() async {
      final credential = await _authRepository.signIn(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await _userRepository.createProfileIfMissing(
          uid: user.uid,
          email: user.email ?? email,
          name: user.displayName ?? _usernameFromEmail(email),
          username: _usernameFromEmail(email),
        );
        await LeaderboardSyncService.instance.syncUser(user.uid);
      }
      Get.offAllNamed(AppRoutes.mainNavigation);
      // Delay agar AppSnackbarHost di halaman baru sempat mount
      await Future.delayed(const Duration(milliseconds: 300));
      AppSnackbar.success('Login berhasil', 'Selamat datang kembali.');
    });
  }

  Future<void> loginWithGoogle() async {
    await _runAuthAction(() async {
      final credential = await _authRepository.signInWithGoogle();
      await _completeSocialLogin(credential, providerName: 'Google');
    });
  }

  Future<void> loginWithFacebook() async {
    await _runAuthAction(() async {
      final credential = await _authRepository.signInWithFacebook();
      await _completeSocialLogin(credential, providerName: 'Facebook');
    });
  }

  void openSignup() {
    Get.toNamed(AppRoutes.signup);
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await action();
    } catch (error) {
      _showError(authErrorMessage(error));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _completeSocialLogin(
    firebase_auth.UserCredential credential, {
    required String providerName,
  }) async {
    final user = credential.user;
    if (user == null) {
      _showError('Login $providerName gagal. Coba lagi.');
      return;
    }

    final email = user.email ?? '';
    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : 'Pengguna SwaraNusa';
    await _userRepository.createProfileIfMissing(
      uid: user.uid,
      email: email,
      name: name,
      username: _usernameFromEmail(email),
    );
    await LeaderboardSyncService.instance.syncUser(user.uid);
    Get.offAllNamed(AppRoutes.mainNavigation);
    // Delay agar AppSnackbarHost di halaman baru sempat mount
    await Future.delayed(const Duration(milliseconds: 300));
    AppSnackbar.success('Login berhasil', 'Selamat datang kembali.');
  }

  String _usernameFromEmail(String email) {
    if (!email.contains('@')) return 'user';
    return email.split('@').first;
  }

  void _showError(String message) {
    AppSnackbar.error('Login gagal', message);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
