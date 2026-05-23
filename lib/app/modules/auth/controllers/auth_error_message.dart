import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

String authErrorMessage(Object error) {
  // Handle GoogleSignInException dari google_sign_in v7
  if (error is GoogleSignInException) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.interrupted:
        return 'Login dibatalkan.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Tidak dapat membuka halaman login Google. Coba lagi.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Konfigurasi aplikasi bermasalah. Hubungi developer.';
      default:
        return error.description ?? 'Login Google gagal. Coba lagi nanti.';
    }
  }

  if (error is! FirebaseAuthException) {
    return 'Terjadi kesalahan. Coba lagi nanti.';
  }

  switch (error.code) {
    case 'account-exists-with-different-credential':
      return 'Email ini sudah terdaftar dengan metode login lain.';
    case 'email-already-in-use':
      return 'Email ini sudah digunakan.';
    case 'invalid-credential':
    case 'invalid-email':
    case 'user-not-found':
    case 'wrong-password':
      return 'Email atau password tidak sesuai.';
    case 'network-request-failed':
      return 'Koneksi bermasalah. Periksa internet lalu coba lagi.';
    case 'operation-not-allowed':
      return 'Metode login ini belum aktif di Firebase Console.';
    case 'popup-closed-by-user':
    case 'web-context-cancelled':
      return 'Login dibatalkan.';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    case 'user-disabled':
      return 'Akun ini dinonaktifkan.';
    case 'weak-password':
      return 'Password minimal 6 karakter.';
    default:
      return error.message ?? 'Terjadi kesalahan. Coba lagi nanti.';
  }
}
