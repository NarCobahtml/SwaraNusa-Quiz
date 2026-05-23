import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';
import 'package:swaranusaquiz/app/modules/auth/controllers/auth_error_message.dart';
import 'package:swaranusaquiz/app/routes/app_pages.dart';
import 'package:swaranusaquiz/app/utils/app_snackbar.dart';

class SignUpController extends GetxController {
  SignUpController({
    AuthRepository? authRepository,
    UserRepository? userRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _userRepository = userRepository ?? UserRepository();

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  void back() {
    Get.back();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || username.isEmpty || password.isEmpty) {
      _showError('Semua field wajib diisi.');
      return;
    }
    if (password.length < 6) {
      _showError('Password minimal 6 karakter.');
      return;
    }

    await _runAuthAction(() async {
      final credential = await _authRepository.register(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        _showError('Registrasi gagal. Coba lagi.');
        return;
      }

      await user.updateDisplayName(name);
      await _userRepository.createProfileIfMissing(
        uid: user.uid,
        email: email,
        name: name,
        username: username,
      );
      Get.offAllNamed(AppRoutes.mainNavigation);
      AppSnackbar.success('Registrasi berhasil', 'Akun kamu sudah siap dipakai.');
    }, title: 'Registrasi gagal');
  }

  Future<void> registerWithGoogle() async {
    await _runAuthAction(() async {
      final credential = await _authRepository.signInWithGoogle();
      await _completeSocialRegistration(credential, providerName: 'Google');
    }, title: 'Registrasi gagal');
  }

  Future<void> registerWithFacebook() async {
    await _runAuthAction(() async {
      final credential = await _authRepository.signInWithFacebook();
      await _completeSocialRegistration(credential, providerName: 'Facebook');
    }, title: 'Registrasi gagal');
  }

  Future<void> _runAuthAction(
    Future<void> Function() action, {
    String title = 'Terjadi kesalahan',
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      _showError(authErrorMessage(error), title: title);
    } catch (error) {
      _showError(authErrorMessage(error), title: title);
    } finally {
      isLoading.value = false;
    }
  }

  String _usernameFromEmail(String email) {
    if (!email.contains('@')) return 'user';
    return email.split('@').first;
  }

  Future<void> _completeSocialRegistration(
    UserCredential credential, {
    required String providerName,
  }) async {
    final user = credential.user;
    if (user == null) {
      _showError('Registrasi $providerName gagal. Coba lagi.');
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
    Get.offAllNamed(AppRoutes.mainNavigation);
    AppSnackbar.success('Registrasi berhasil', 'Akun kamu sudah siap dipakai.');
  }

  void _showError(String message, {String title = 'Registrasi gagal'}) {
    AppSnackbar.error(title, message);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
