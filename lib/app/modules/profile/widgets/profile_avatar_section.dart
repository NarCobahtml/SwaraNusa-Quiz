import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/data/services/user_service.dart';
import 'package:swaranusaquiz/app/modules/profile/controllers/profile_controller.dart';
import 'package:swaranusaquiz/app/modules/profile/models/profile_data.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class ProfileAvatarSection extends StatelessWidget {
  final ProfileData profile;

  const ProfileAvatarSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Column(
      children: [
        // Avatar dengan tombol edit foto di pojok kanan bawah
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: controller.editPhoto,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 5),
                ),
                child: ClipOval(
                  child: Obx(() {
                    final avatarUrl =
                        UserService.to.currentUser.value?.avatarUrl ?? '';
                    if (avatarUrl.isNotEmpty &&
                        !avatarUrl.startsWith('assets')) {
                      return Image.network(
                        avatarUrl,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const _AvatarPlaceholder(),
                      );
                    }
                    return Image.asset(
                      profile.avatarPath,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _AvatarPlaceholder(),
                    );
                  }),
                ),
              ),
            ),
            // Tombol edit foto — pojok kanan bawah
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: controller.editPhoto,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.textLight,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Nama dengan tombol edit di sebelah kanan
        GestureDetector(
          onTap: controller.editName,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.edit_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.handle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary,
      child: const Center(
        child: Icon(Icons.person, color: AppColors.primary, size: 60),
      ),
    );
  }
}
