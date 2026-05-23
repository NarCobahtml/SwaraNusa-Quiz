import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';
import 'package:swaranusaquiz/app/modules/profile/controllers/profile_controller.dart';
import 'package:swaranusaquiz/app/modules/profile/widgets/profile_avatar_section.dart';
import 'package:swaranusaquiz/app/modules/profile/widgets/profile_badges_section.dart';
import 'package:swaranusaquiz/app/modules/profile/widgets/profile_rewards_card.dart';
import 'package:swaranusaquiz/app/modules/profile/widgets/profile_stats_section.dart';
import 'package:swaranusaquiz/app/modules/profile/widgets/profile_theme_menu.dart';

class ProfileScreen extends StatelessWidget {
  final bool showNavbar;
  final VoidCallback? onRewardTap;

  const ProfileScreen({super.key, this.showNavbar = true, this.onRewardTap});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final topPadding = MediaQuery.of(context).padding.top;

    return Obx(() {
      return CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: topPadding + 16),
                const Center(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                ProfileAvatarSection(profile: controller.profile),
                const SizedBox(height: 24),
                ProfileStatsSection(profile: controller.profile),
                const SizedBox(height: 15),
                ProfileThemeMenu(
                  isDarkMode: controller.isDarkModeValue,
                  onLightModeChanged: controller.setLightMode,
                ),
                const SizedBox(height: 15),
                ProfileRewardsCard(onTap: onRewardTap),
                const SizedBox(height: 32),
                ProfileBadgesSection(badges: controller.badges),
                const SizedBox(height: 24),
                // Tombol Logout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: controller.isLoggingOut.value
                            ? null
                            : controller.logout,
                        icon: controller.isLoggingOut.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.error,
                                ),
                              )
                            : const Icon(
                                Icons.logout_rounded,
                                color: AppColors.error,
                              ),
                        label: Text(
                          controller.isLoggingOut.value
                              ? 'Keluar...'
                              : 'Keluar',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      );
    });
  }
}
