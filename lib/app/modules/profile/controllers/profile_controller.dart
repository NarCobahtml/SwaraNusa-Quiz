import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swaranusaquiz/app/data/repositories/firebase_repositories.dart';
import 'package:swaranusaquiz/app/data/services/backend_services.dart';
import 'package:swaranusaquiz/app/data/services/supabase_avatar_service.dart';
import 'package:swaranusaquiz/app/data/services/user_service.dart';
import 'package:swaranusaquiz/app/modules/profile/models/profile_badge.dart';
import 'package:swaranusaquiz/app/modules/profile/models/profile_data.dart';
import 'package:swaranusaquiz/app/routes/app_pages.dart';
import 'package:swaranusaquiz/app/utils/app_snackbar.dart';

class ProfileController extends GetxController {
  ProfileController({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  final UserRepository _userRepository;
  UserService get _userService => UserService.to;

  final isLoggingOut = false.obs;
  final isSaving = false.obs;
  final RxList<ProfileBadge> _badges = <ProfileBadge>[].obs;

  List<ProfileBadge> get badges => _badges;

  ProfileData get profile {
    final user = _userService.currentUser.value;
    if (user == null) {
      return const ProfileData(
        name: '...',
        handle: '@...',
        avatarPath: 'assets/image/user_profile.png',
        quizCompleted: 0,
        correctAnswerPercentage: 0,
        badgesEarned: 0,
      );
    }

    final total = user.correctAnswerCount + user.wrongAnswerCount;
    final correctPct = total > 0
        ? ((user.correctAnswerCount / total) * 100).round()
        : 0;

    return ProfileData(
      name: user.name.isNotEmpty ? user.name : user.username,
      handle: '@${user.username}',
      avatarPath: user.avatarUrl.startsWith('assets')
          ? user.avatarUrl
          : 'assets/image/user_profile.png',
      quizCompleted: user.quizCompleted,
      correctAnswerPercentage: correctPct,
      badgesEarned: _badges.isNotEmpty ? _badges.length : user.badgesEarned,
    );
  }

  @override
  void onInit() {
    super.onInit();
    final user = _userService.currentUser.value;
    if (user != null) {
      _loadBadges(user.uid);
    }
    ever(_userService.currentUser, (user) {
      if (user != null) {
        _loadBadges(user.uid);
      }
    });
  }

  Future<void> _loadBadges(String uid) async {
    try {
      final rawBadges = await _userRepository.getUserBadgesWithDetails(uid);
      _badges.value = rawBadges.map((data) {
        final rawName = data['name']?.toString() ?? '';
        final id = data['id']?.toString() ?? '';
        final name = rawName.isNotEmpty ? rawName : _badgeLabelFromId(id);
        final stars = (data['stars'] as num?)?.toInt() ?? 1;
        final iconUrl = data['iconUrl']?.toString() ?? '';
        return ProfileBadge(stars: stars, label: name, iconUrl: iconUrl);
      }).toList();
    } catch (_) {}
  }

  String _badgeLabelFromId(String id) {
    const labels = {
      'account_created': 'Buat Akun',
      'quiz_completed': 'Kuis Selesai',
      'perfect_score': 'Skor Sempurna',
      'xp_reached': 'XP Tercapai',
      'instrument_collected': 'Kolektor',
      'instrument_mastery': 'Maestro',
    };
    return labels[id] ?? id;
  }

  Future<void> editName(BuildContext context) async {
    final uid = auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final currentName = _userService.currentUser.value?.name ?? '';
    var editedName = currentName;

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Nama'),
        content: TextFormField(
          initialValue: currentName,
          autofocus: false,
          maxLength: 30,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama baru',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => editedName = value,
          onFieldSubmitted: (value) => _closeDialogSafely(ctx, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => _closeDialogSafely(ctx, null),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => _closeDialogSafely(ctx, editedName.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == currentName) return;
    await Future<void>.delayed(const Duration(milliseconds: 120));

    isSaving.value = true;
    try {
      await _userRepository.updateProfile(uid: uid, name: newName);
      await _userService.reload();
      await LeaderboardSyncService.instance.syncUser(uid);
      AppSnackbar.success(
        'Berhasil',
        'Nama berhasil diperbarui.',
      );
    } catch (_) {
      AppSnackbar.error(
        'Gagal',
        'Tidak dapat memperbarui nama. Coba lagi.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> editPhoto(BuildContext context) async {
    final uid = auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Foto Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return;

    isSaving.value = true;
    try {
      // Upload ke Supabase Storage, simpan URL ke Firestore
      final oldAvatarUrl = _userService.currentUser.value?.avatarUrl ?? '';
      final bytes = await picked.readAsBytes();
      final downloadUrl = await SupabaseAvatarService.uploadAvatar(
        uid: uid,
        bytes: bytes,
        contentType: 'image/jpeg',
      );
      await _userRepository.updateProfile(uid: uid, avatarUrl: downloadUrl);
      if (oldAvatarUrl.isNotEmpty &&
          !oldAvatarUrl.startsWith('assets') &&
          oldAvatarUrl != downloadUrl) {
        try {
          await SupabaseAvatarService.deleteAvatarByUrl(oldAvatarUrl);
        } catch (_) {}
      }
      await _userService.reload();
      await LeaderboardSyncService.instance.syncUser(uid);
      AppSnackbar.success(
        'Berhasil',
        'Foto profil berhasil diperbarui.',
      );
    } catch (error) {
      AppSnackbar.error(
        'Gagal',
        error.toString(),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _closeDialogSafely(BuildContext context, Object? result) async {
    FocusScope.of(context).unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(result);
  }

  Future<void> logout() async {
    final context = Get.context;
    if (context == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoggingOut.value = true;
    try {
      _userService.clear();
      if (GoogleSignIn.instance.supportsAuthenticate()) {
        await GoogleSignIn.instance.signOut();
      }
      await auth.FirebaseAuth.instance.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (_) {
      await auth.FirebaseAuth.instance.signOut();
      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoggingOut.value = false;
    }
  }
}
